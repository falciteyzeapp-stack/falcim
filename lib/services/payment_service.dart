import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../config/constants.dart';
import 'firestore_service.dart';

class PaymentService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  static const Set<String> _productIds = {
    AppConstants.productSingleFortune,
    AppConstants.productWeeklyPremium,
    AppConstants.productMonthlyPremium,
  };

  Future<List<ProductDetails>> getProducts() async {
    final available = await _iap.isAvailable();
    if (!available) return [];
    final response = await _iap.queryProductDetails(_productIds);
    return response.productDetails;
  }

  void listenToPurchases(String uid, VoidCallback onSuccess, Function(String) onError) {
    _subscription = _iap.purchaseStream.listen(
      (purchases) => _handlePurchases(purchases, uid, onSuccess, onError),
      onError: (e) => onError('Satın alma akışı hatası'),
    );
  }

  Future<void> _handlePurchases(
    List<PurchaseDetails> purchases,
    String uid,
    VoidCallback onSuccess,
    Function(String) onError,
  ) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _deliverProduct(purchase, uid);
        await _iap.completePurchase(purchase);
        onSuccess();
      } else if (purchase.status == PurchaseStatus.error) {
        onError('Ödeme başarısız. Bilgiler eşleşmiyor veya işlem tamamlanamadı.');
      } else if (purchase.status == PurchaseStatus.canceled) {
        onError('Ödeme iptal edildi.');
      }
    }
  }

  Future<void> _deliverProduct(PurchaseDetails purchase, String uid) async {
    final productId = purchase.productID;
    if (productId == AppConstants.productSingleFortune) {
      await _firestoreService.addCredits(uid, 1);
    } else if (productId == AppConstants.productWeeklyPremium) {
      final until = DateTime.now().add(const Duration(days: 7));
      await _firestoreService.setPremium(uid, until);
    } else if (productId == AppConstants.productMonthlyPremium) {
      final until = DateTime.now().add(const Duration(days: 30));
      await _firestoreService.setPremium(uid, until);
    }
  }

  Future<bool> buyProduct(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } else {
      return _iap.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void dispose() {
    _subscription?.cancel();
  }
}
