import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/sparkle_background.dart';
import '../../config/constants.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const String _productId = AppConstants.productSingleFortune;
  static const String _usersCol = AppConstants.usersCollection;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  List<ProductDetails> _products = [];
  bool _billingAvailable = false;
  bool _loadingProducts = true;
  bool _purchasing = false;
  String _statusMsg = '';
  Timer? _purchaseTimeout;

  @override
  void initState() {
    super.initState();
    // autoConsume: true kullanıyoruz — plugin Google Play'e consume çağrısını kendisi yapar
    // Biz sadece krediyi yazarız
    _sub = _iap.purchaseStream.listen(_onPurchases, onError: (e) {
      debugPrint('[PAY] stream error: $e');
      _resetPurchasing();
    });
    _initBilling();
  }

  @override
  void dispose() {
    _purchaseTimeout?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  // ── Billing başlat ───────────────────────────────────────────────────────
  Future<void> _initBilling() async {
    try {
      final available = await _iap.isAvailable();
      debugPrint('[PAY] billing available = $available');
      if (!mounted) return;
      setState(() => _billingAvailable = available);
      if (!available) {
        setState(() {
          _loadingProducts = false;
          _statusMsg = 'Google Play Billing şu an kullanılamıyor.';
        });
        return;
      }
      await _loadProducts();
    } catch (e) {
      debugPrint('[PAY] initBilling error: $e');
      if (mounted) setState(() => _loadingProducts = false);
    }
  }

  Future<void> _loadProducts() async {
    debugPrint('[PAY] querying product: $_productId');
    try {
      final res = await _iap.queryProductDetails({_productId});
      debugPrint('[PAY] products found = ${res.productDetails.length}');
      debugPrint('[PAY] notFoundIDs = ${res.notFoundIDs}');
      if (mounted) {
        setState(() {
          _products = res.productDetails;
          _loadingProducts = false;
          if (res.productDetails.isEmpty) {
            _statusMsg = 'Ürün bulunamadı. (ID: $_productId)';
          }
        });
      }
    } catch (e) {
      debugPrint('[PAY] queryProductDetails error: $e');
      if (mounted) setState(() => _loadingProducts = false);
    }
  }

  // ── İdempotency: token daha önce işlendi mi? ────────────────────────────
  Future<bool> _isAlreadyProcessed(String uid, String token) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_usersCol)
          .doc(uid)
          .get();
      final list = List<String>.from(
          (doc.data()?['processedPurchases'] as List?)?.cast<String>() ?? []);
      final result = list.contains(token);
      debugPrint('[PAY] already owned = $result  token=$token');
      return result;
    } catch (e) {
      debugPrint('[PAY] _isAlreadyProcessed error: $e');
      return false;
    }
  }

  Future<void> _markProcessed(String uid, String token) async {
    try {
      await FirebaseFirestore.instance.collection(_usersCol).doc(uid).set(
          {'processedPurchases': FieldValue.arrayUnion([token])},
          SetOptions(merge: true));
      debugPrint('[PAY] token marked processed: $token');
    } catch (e) {
      debugPrint('[PAY] _markProcessed error: $e');
    }
  }

  // ── Purchase stream — tek giriş noktası ─────────────────────────────────
  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      debugPrint(
          '[PAY] purchase status = ${p.status}  id=${p.productID}  token=${p.purchaseID}  pendingComplete=${p.pendingCompletePurchase}');

      if (p.productID != _productId) continue;

      switch (p.status) {
        case PurchaseStatus.pending:
          _setStatus('Ödeme bekleniyor…');
          break;

        case PurchaseStatus.purchased:
          // autoConsume:true ile plugin zaten consume etti
          // Bizim işimiz sadece kredi vermek
          _purchaseTimeout?.cancel();
          if (mounted) setState(() => _purchasing = true);
          _setStatus('Ödeme onaylandı, kredi ekleniyor…');
          debugPrint('[PAY] start — delivering credit for purchased');
          await _giveCredit(p);
          debugPrint('[PAY] end — purchased flow complete');
          break;

        case PurchaseStatus.restored:
          _purchaseTimeout?.cancel();
          final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
          final token = p.purchaseID ?? '';
          debugPrint('[PAY] restored — uid=$uid  token=$token');
          if (uid.isEmpty || token.isEmpty) break;
          final done = await _isAlreadyProcessed(uid, token);
          if (!done) {
            if (mounted) setState(() => _purchasing = true);
            await _giveCredit(p);
          } else {
            debugPrint('[PAY] restored token already processed — skip');
            if (p.pendingCompletePurchase) await _iap.completePurchase(p);
          }
          break;

        case PurchaseStatus.error:
          _purchaseTimeout?.cancel();
          debugPrint(
              '[PAY] error code=${p.error?.code}  msg=${p.error?.message}');
          _setStatus('Ödeme hatası: ${p.error?.message ?? "Bilinmeyen hata"}');
          if (p.pendingCompletePurchase) await _iap.completePurchase(p);
          _resetPurchasing();
          break;

        case PurchaseStatus.canceled:
          _purchaseTimeout?.cancel();
          debugPrint('[PAY] purchase canceled');
          _setStatus('Ödeme iptal edildi.');
          _resetPurchasing();
          break;
      }
    }
  }

  // ── Kredi ver ────────────────────────────────────────────────────────────
  Future<void> _giveCredit(PurchaseDetails p) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final token = p.purchaseID ?? '';

    debugPrint('[PAY] current uid = $uid');
    debugPrint('[PAY] token = $token');
    debugPrint('[PAY] writing to $_usersCol/$uid');

    if (uid.isEmpty) {
      _setStatus('Oturum hatası. Lütfen tekrar giriş yapın.');
      _resetPurchasing();
      if (p.pendingCompletePurchase) await _iap.completePurchase(p);
      return;
    }

    // Çift kredi önlemi
    if (token.isNotEmpty) {
      final done = await _isAlreadyProcessed(uid, token);
      if (done) {
        debugPrint('[PAY] already owned = true — skip credit');
        if (p.pendingCompletePurchase) await _iap.completePurchase(p);
        _resetPurchasing();
        return;
      }
    }

    // Firestore'a kredi yaz
    bool written = false;
    for (int i = 1; i <= 3; i++) {
      try {
        await FirebaseFirestore.instance
            .collection(_usersCol)
            .doc(uid)
            .set({'krediler': FieldValue.increment(1)}, SetOptions(merge: true));
        written = true;
        debugPrint('[PAY] credit write success attempt=$i');
        break;
      } catch (e) {
        debugPrint('[PAY] credit write error = $e  attempt=$i');
        if (i < 3) await Future.delayed(const Duration(seconds: 2));
      }
    }

    if (!written) {
      _setStatus(
          'Kredi eklenemedi. "Satın Almaları Geri Yükle" butonuna basın.');
      _resetPurchasing();
      if (p.pendingCompletePurchase) await _iap.completePurchase(p);
      return;
    }

    if (token.isNotEmpty) await _markProcessed(uid, token);

    // pendingCompletePurchase hâlâ true ise tamamla
    // (autoConsume:true ile normalde false gelir ama garanti için)
    if (p.pendingCompletePurchase) {
      try {
        await _iap.completePurchase(p);
        debugPrint('[PAY] completePurchase OK');
      } catch (e) {
        debugPrint('[PAY] completePurchase error (non-critical): $e');
      }
    }

    // Güncel krediyi oku ve UI'ya yansıt
    int newCredits = 1;
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_usersCol)
          .doc(uid)
          .get();
      newCredits = (doc.data()?['krediler'] as num?)?.toInt() ?? newCredits;
    } catch (_) {}

    debugPrint('[PAY] entitlement granted — uid=$uid  newCredits=$newCredits');

    if (mounted) {
      try {
        context.read<AuthProvider>().forceSetCredits(newCredits);
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Fal hakkınız eklendi! Devam edebilirsiniz.'),
          backgroundColor: Color(0xFF1B8C3E),
          duration: Duration(seconds: 3),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) Navigator.pop(context);
    }

    _resetPurchasing();
  }

  // ── Restore: ITEM_ALREADY_OWNED ve manuel geri yükleme ──────────────────
  // queryPastPurchases → unconsumed purchase bul → elle consume et → kredi ver
  Future<void> _restorePurchases() async {
    debugPrint('[PAY] start restore');
    _setStatus('Satın almalar kontrol ediliyor…');

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    debugPrint('[PAY] current uid = $uid');
    if (uid.isEmpty) {
      _setStatus('Oturum hatası.');
      return;
    }

    try {
      final android =
          _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final resp = await android.queryPastPurchases();
      debugPrint('[PAY] queryPastPurchases total = ${resp.pastPurchases.length}');

      final relevant =
          resp.pastPurchases.where((p) => p.productID == _productId).toList();
      debugPrint('[PAY] relevant stuck purchases = ${relevant.length}');

      if (relevant.isEmpty) {
        _setStatus('Bekleyen satın alma bulunamadı.');
        return;
      }

      for (final p in relevant) {
        final token = p.purchaseID ?? '';
        debugPrint('[PAY] stuck — token=$token  pendingComplete=${p.pendingCompletePurchase}');

        final done =
            token.isNotEmpty ? await _isAlreadyProcessed(uid, token) : false;
        debugPrint('[PAY] already owned = $done');

        if (!done) {
          // Kredi yaz
          bool written = false;
          for (int i = 1; i <= 3; i++) {
            try {
              await FirebaseFirestore.instance
                  .collection(_usersCol)
                  .doc(uid)
                  .set({'krediler': FieldValue.increment(1)},
                      SetOptions(merge: true));
              written = true;
              debugPrint('[PAY] credit write success (restore attempt $i)');
              break;
            } catch (e) {
              debugPrint('[PAY] credit write error = $e  attempt=$i');
              if (i < 3) await Future.delayed(const Duration(seconds: 2));
            }
          }

          if (!written) {
            _setStatus('Kredi eklenemedi.');
            return;
          }

          if (token.isNotEmpty) await _markProcessed(uid, token);
          debugPrint('[PAY] entitlement granted via restore — uid=$uid');
        }

        // Consume et: android.consumePurchase ile gerçekten owned listesinden çıkar
        debugPrint('[PAY] consume start — token=$token');
        bool consumed = false;
        if (p is GooglePlayPurchaseDetails) {
          try {
            await android.consumePurchase(p);
            consumed = true;
            debugPrint('[PAY] consume end — success (android.consumePurchase)');
          } catch (e) {
            debugPrint('[PAY] consume error: $e');
          }
        }
        if (!consumed) {
          try {
            await _iap.completePurchase(p);
            debugPrint('[PAY] consume end — completePurchase fallback');
          } catch (e) {
            debugPrint('[PAY] completePurchase fallback error: $e');
          }
        }

        if (!done && mounted) {
          try {
            final doc = await FirebaseFirestore.instance
                .collection(_usersCol)
                .doc(uid)
                .get();
            final nc = (doc.data()?['krediler'] as num?)?.toInt() ?? 1;
            context.read<AuthProvider>().forceSetCredits(nc);
          } catch (_) {}

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Fal hakkınız eklendi!'),
              backgroundColor: Color(0xFF1B8C3E),
              duration: Duration(seconds: 3),
            ),
          );
          await Future.delayed(const Duration(milliseconds: 400));
          if (mounted) Navigator.pop(context);
        } else if (done) {
          _setStatus('Bu satın alma daha önce işlendi.');
        }
      }
    } catch (e) {
      debugPrint('[PAY] restore error: $e');
      _setStatus('Hata: $e');
    }

    debugPrint('[PAY] end restore');
  }

  // ── Satın alma başlat ────────────────────────────────────────────────────
  Future<void> _buy() async {
    debugPrint('[PAY] start — buy button pressed');
    if (_purchasing) return;

    if (!_billingAvailable) {
      _setStatus('Google Play Billing kullanılamıyor.');
      return;
    }

    if (_products.isEmpty) {
      await _loadProducts();
      if (_products.isEmpty) {
        _setStatus('Ürün bulunamadı. (ID: $_productId)');
        return;
      }
    }

    debugPrint(
        '[PAY] product id=${_products.first.id}  price=${_products.first.price}');

    setState(() {
      _purchasing = true;
      _statusMsg = 'Ödeme başlatılıyor…';
    });

    _purchaseTimeout = Timer(const Duration(seconds: 30), () {
      debugPrint('[PAY] purchase timeout');
      _setStatus('Ödeme ekranı açılamadı. Lütfen tekrar deneyin.');
      _resetPurchasing();
    });

    try {
      // autoConsume: true — plugin Google Play'e consume çağrısını kendi yapar
      // Bu sayede satın alma tamamlandıktan sonra ürün "owned" listesinden çıkar
      // ve aynı kullanıcı tekrar satın alabilir
      await _iap.buyConsumable(
        purchaseParam:
            GooglePlayPurchaseParam(productDetails: _products.first),
        autoConsume: true,
      );
      debugPrint('[PAY] buyConsumable called — waiting for stream event');
    } catch (e) {
      _purchaseTimeout?.cancel();
      final s = e.toString().toLowerCase();
      debugPrint('[PAY] buyConsumable exception: $e');

      if (s.contains('item_already_owned') || s.contains('already_owned')) {
        debugPrint('[PAY] already owned — starting restore');
        _setStatus('Önceki ödeme bulundu, kontrol ediliyor…');
        _resetPurchasing();
        await _restorePurchases();
      } else if (s.contains('user_cancel') || s.contains('cancel')) {
        _setStatus('Ödeme iptal edildi.');
        _resetPurchasing();
      } else {
        _setStatus('Hata: $e');
        _resetPurchasing();
      }
    }
  }

  void _resetPurchasing() {
    if (mounted) setState(() => _purchasing = false);
  }

  void _setStatus(String msg) {
    debugPrint('[PAY] status: $msg');
    if (mounted) setState(() => _statusMsg = msg);
  }

  // ── UI ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SparkleBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed:
                          _purchasing ? null : () => Navigator.pop(context),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Fal Hakkı Al',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Text('🔮', style: TextStyle(fontSize: 72)),
                      const SizedBox(height: 16),
                      const Text(
                        '1 Fal Hakkı',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kahve, Tarot veya El falı baktır.\nUzun, detaylı ve kişiye özel yorum.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (_statusMsg.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.15)),
                          ),
                          child: Text(
                            _statusMsg,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed:
                              (_purchasing || _loadingProducts) ? null : _buy,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            disabledBackgroundColor:
                                AppTheme.primary.withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                          ),
                          child: _purchasing
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'İşleniyor…',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  _loadingProducts
                                      ? 'Yükleniyor…'
                                      : _products.isNotEmpty
                                          ? '${_products.first.price} Öde'
                                          : '25 ₺ Öde',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _purchasing ? null : _restorePurchases,
                        child: Text(
                          'Satın Almaları Geri Yükle',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Billing: ${_billingAvailable ? "✓" : "✗"}  '
                        'Ürün: ${_products.isNotEmpty ? "✓ ${_products.first.price}" : "yok"}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ödeme Google Play hesabınız üzerinden gerçekleşir.\nSatın alma sonrası iade yapılmaz.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 11,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
