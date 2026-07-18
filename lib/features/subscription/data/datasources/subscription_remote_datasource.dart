import 'package:dio/dio.dart';
import '../../../../core/network/api_error_mapper.dart';
import '../models/subscription_status_model.dart';

abstract class SubscriptionRemoteDataSource {
  Future<SubscriptionStatusModel> verifyPurchase({
    required String productId,
    required String purchaseToken,
  });
  Future<SubscriptionStatusModel> getStatus();
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final Dio dio;

  SubscriptionRemoteDataSourceImpl({required this.dio});

  @override
  Future<SubscriptionStatusModel> verifyPurchase({
    required String productId,
    required String purchaseToken,
  }) async {
    try {
      final response = await dio.post(
        '/subscriptions/verify',
        data: {'productId': productId, 'purchaseToken': purchaseToken},
      );
      return SubscriptionStatusModel.fromJson(
        response.data as Map<String, dynamic>,
        verifiedAt: DateTime.now(),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<SubscriptionStatusModel> getStatus() async {
    try {
      final response = await dio.get('/subscriptions/status');
      return SubscriptionStatusModel.fromJson(
        response.data as Map<String, dynamic>,
        verifiedAt: DateTime.now(),
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Exception _mapDioException(DioException e) => mapDioException(
    e,
    codeMessages: const {
      'TOKEN_MISSING': 'Silakan masuk ke akun toko terlebih dahulu.',
      'TOKEN_INVALID': 'Silakan masuk ke akun toko terlebih dahulu.',
      'UNAUTHORIZED': 'Silakan masuk ke akun toko terlebih dahulu.',
      'PURCHASE_TOKEN_TAKEN': 'Pembelian ini sudah terdaftar pada akun lain.',
      'VALIDATION_FAILED': 'Permintaan tidak valid.',
    },
    fallback: 'Gagal memverifikasi langganan.',
  );
}
