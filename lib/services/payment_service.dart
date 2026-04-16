import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import '../config/constants.dart';
import 'firestore_service.dart';

class PaymentService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // İşlenmiş purchase token'ları — aynı purchase'ı 2 kez işlememek için
  final Set<String> _processedTokens = {};

  static const Set<String> _productIds = {
    AppConstants.productSingleFortune,
  };

  Future<bool> isAvailable() => _iap.isAvailable();

  Future<List<ProductDetails>> getProducts() async {
    final available = await _iap.isAvailable();
    if (!available) {
      debugPrint('[IAP] Store not available');
      return [];
    }
    final response = await _iap.queryProductDetails(_productIds);
    if (response.error != null) {
      debugPrint('[IAP] Query error: ${response.error?.message}');
    }
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('[IAP] Not found IDs: ${response.notFoundIDs}');
    }
    debugPrint('[IAP] Products found: ${response.productDetails.length}');
    return response.productDetails;
  }

  void listenToPurchases(
    String uid,
    VoidCallback onSuccess,
    Function(String) onError,
  ) {
    _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen(
      (purchases) => _handlePurchases(purchases, uid, onSuccess, onError),
      onError: (e) {
        debugPrint('[IAP] stream error: $e');
      },
    );
  }

  Future<void> _handlePurchases(
    List<PurchaseDetails> purchases,
    String uid,
    VoidCallback onSuccess,
    Function(String) onError,
  ) async {
    for (final purchase in purchases) {
      final token = purchase.purchaseID ?? purchase.productID;
      debugPrint(
          '[IAP] Received → status=${purchase.status}  id=${purchase.productID}  token=$token');

      switch (purchase.status) {
        case PurchaseStatus.pending:
          // Bekleniyor — kullanıcıya bilgi ver ama bekle
          debugPrint('[IAP] Purchase pending...');
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // Başarılı ödeme — kredi teslim et
          await _handleSuccessfulPurchase(purchase, uid, token, onSuccess);
          break;

        case PurchaseStatus.error:
          debugPrint('[IAP] Purchase error: ${purchase.error?.message}');
          // Purchase'ı tamamla ki takılı kalmasın
          await _safeCompletePurchase(purchase);
          onError('Ödeme başarısız. Lütfen tekrar deneyin.');
          break;

        case PurchaseStatus.canceled:
          // Kullanıcı iptal etti — para çekilmedi, sadece bilgi ver
          debugPrint('[IAP] Purchase canceled by user');
          // canceled purchase'ı da tamamla (stream'den temizle)
          await _safeCompletePurchase(purchase);
          onError('Ödeme iptal edildi.');
          break;
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(
    PurchaseDetails purchase,
    String uid,
    String token,
    VoidCallback onSuccess,
  ) async {
    // Aynı purchase'ı 2 kez işleme
    if (_processedTokens.contains(token)) {
      debugPrint('[IAP] Already processed: $token');
      await _safeCompletePurchase(purchase);
      return;
    }

    // Önce Google'a "teslim aldım" bil (consume/acknowledge)
    await _safeCompletePurchase(purchase);

    // Sonra kredi ekle
    final safeUid = uid.isNotEmpty
        ? uid
        : (FirebaseAuth.instance.currentUser?.uid ?? '');

    if (safeUid.isEmpty) {
      debugPrint('[IAP] UID boş! Kredi eklenemedi.');
      // UID yoksa purchase'ı işlenmiş say ama callback'i çağır
      // Kullanıcı credentials restore edince tekrar deneyebilir
    } else {
      try {
        await _firestoreService.addCredits(safeUid, 1);
        _processedTokens.add(token);
        debugPrint('[IAP] ✅ Credit +1 delivered to $safeUid');
      } catch (e) {
        debugPrint('[IAP] Firestore credit error: $e — retrying...');
        // Retry bir kez daha
        try {
          await Future.delayed(const Duration(seconds: 2));
          await _firestoreService.addCredits(safeUid, 1);
          _processedTokens.add(token);
          debugPrint('[IAP] ✅ Credit +1 delivered on retry');
        } catch (e2) {
          debugPrint('[IAP] Retry failed: $e2');
          // Firestore'a yazamadık ama para alındı
          // onSuccess yine de çağrılır — refreshUser ile Firestore güncellenebilir
        }
      }
    }

    // Her durumda başarı callback'ini çağır
    onSuccess();
  }

  Future<void> _safeCompletePurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      try {
        await _iap.completePurchase(purchase);
        debugPrint('[IAP] completePurchase OK');
      } catch (e) {
        debugPrint('[IAP] completePurchase error: $e');
      }
    }
  }

  Future<bool> buyProduct(ProductDetails product) async {
    try {
      PurchaseParam purchaseParam;

      if (Platform.isAndroid) {
        purchaseParam = GooglePlayPurchaseParam(
          productDetails: product,
        );
      } else {
        purchaseParam = PurchaseParam(productDetails: product);
      }

      final result = await _iap.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
      debugPrint('[IAP] buyConsumable result: $result');
      return result;
    } catch (e) {
      debugPrint('[IAP] buyProduct error: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
      debugPrint('[IAP] Manual restore triggered');
    } catch (e) {
      debugPrint('[IAP] Restore error: $e');
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
