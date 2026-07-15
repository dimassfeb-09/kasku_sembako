import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';

/// The ONLY file in this codebase that imports `in_app_purchase`/
/// `in_app_purchase_android`. Keeping Play Billing types confined here is
/// what lets `SubscriptionRepository` stay platform-neutral (see its doc
/// comment) — if Apple IAP is ever added, only this file (or a sibling
/// implementing the same abstract methods) needs to change.
abstract class BillingLocalDataSource {
  Stream<List<PurchaseDetails>> get purchaseStream;
  Future<ProductDetails> queryProProduct();
  Future<void> buyPro(ProductDetails product);
  Future<void> completePurchase(PurchaseDetails purchase);
  Future<void> restorePurchases();
}

class BillingLocalDataSourceImpl implements BillingLocalDataSource {
  final InAppPurchase _iap = InAppPurchase.instance;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  @override
  Future<ProductDetails> queryProProduct() async {
    final available = await _iap.isAvailable();
    if (!available) {
      throw const ServerException(
        'Google Play Billing tidak tersedia di perangkat ini.',
      );
    }

    final response = await _iap.queryProductDetails({
      AppConstants.proMonthlyProductId,
    });
    if (response.error != null) {
      throw ServerException(response.error!.message);
    }
    if (response.productDetails.isEmpty) {
      throw const ServerException(
        'Produk langganan Pro tidak ditemukan di Play Store.',
      );
    }
    return response.productDetails.first;
  }

  @override
  Future<void> buyPro(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  @override
  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }
}
