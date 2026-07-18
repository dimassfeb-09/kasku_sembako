import 'package:dio/dio.dart';
import '../../../../core/network/api_error_mapper.dart';

class StoreProfileModel {
  final String? id;
  final String? userId;
  final String ownerName;
  final String businessName;
  final String businessCategory;
  final String phone;
  final String address;
  final String businessEmail;

  const StoreProfileModel({
    this.id,
    this.userId,
    required this.ownerName,
    required this.businessName,
    required this.businessCategory,
    required this.phone,
    required this.address,
    this.businessEmail = '',
  });

  Map<String, dynamic> toJson() => {
    'ownerName': ownerName,
    'businessName': businessName,
    'businessCategory': businessCategory,
    'phone': phone,
    'address': address,
    'businessEmail': businessEmail,
  };

  factory StoreProfileModel.fromJson(Map<String, dynamic> json) =>
      StoreProfileModel(
        id: json['id'] as String?,
        userId: json['userID'] as String? ?? json['user_id'] as String?,
        ownerName:
            json['ownerName'] as String? ?? json['owner_name'] as String? ?? '',
        businessName:
            json['businessName'] as String? ??
            json['business_name'] as String? ??
            '',
        businessCategory:
            json['businessCategory'] as String? ??
            json['business_category'] as String? ??
            '',
        phone: json['phone'] as String? ?? '',
        address: json['address'] as String? ?? '',
        businessEmail:
            json['businessEmail'] as String? ??
            json['business_email'] as String? ??
            '',
      );
}

abstract class StoreProfileRemoteDataSource {
  Future<void> save(StoreProfileModel profile);
  Future<StoreProfileModel?> get();
}

class StoreProfileRemoteDataSourceImpl implements StoreProfileRemoteDataSource {
  final Dio dio;

  StoreProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> save(StoreProfileModel profile) async {
    try {
      await dio.put('/api/store-profile', data: profile.toJson());
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<StoreProfileModel?> get() async {
    try {
      final response = await dio.get('/api/store-profile');
      final data = response.data;
      if (data is! Map) return null;

      // The server answers "user exists, no profile yet" with 200
      // {"profile": null}. That envelope must map to null - reading it as the
      // profile itself yields a model with every field blank, which callers
      // then mistake for a completed setup.
      if (data.containsKey('profile')) {
        final profile = data['profile'];
        return profile is Map
            ? StoreProfileModel.fromJson(profile.cast<String, dynamic>())
            : null;
      }

      // Tolerate an unwrapped {...} body.
      return StoreProfileModel.fromJson(data.cast<String, dynamic>());
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
      'VALIDATION_FAILED': 'Data profil toko tidak valid.',
    },
    fallback: 'Gagal memuat profil toko.',
  );
}
