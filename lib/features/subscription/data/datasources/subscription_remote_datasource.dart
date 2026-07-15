import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
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

  Exception _mapDioException(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkException('Tidak dapat terhubung ke server.');
    }
    if (e.response?.statusCode == 401) {
      return const ServerException(
        'Silakan masuk ke akun toko terlebih dahulu.',
      );
    }
    if (e.response?.statusCode == 409) {
      return const ServerException(
        'Pembelian ini sudah terdaftar pada akun lain.',
      );
    }
    return ServerException(e.message ?? 'Gagal memverifikasi langganan.');
  }
}
