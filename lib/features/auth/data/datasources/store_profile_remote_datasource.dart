import 'package:dio/dio.dart';

class StoreProfileModel {
  final String? id;
  final String? userId;
  final String ownerName;
  final String businessName;
  final String businessCategory;
  final String phone;
  final String address;

  const StoreProfileModel({
    this.id,
    this.userId,
    required this.ownerName,
    required this.businessName,
    required this.businessCategory,
    required this.phone,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
    'ownerName': ownerName,
    'businessName': businessName,
    'businessCategory': businessCategory,
    'phone': phone,
    'address': address,
  };

  factory StoreProfileModel.fromJson(Map<String, dynamic> json) =>
      StoreProfileModel(
        id: json['id'] as String?,
        userId: json['userID'] as String? ?? json['user_id'] as String?,
        ownerName: json['ownerName'] as String? ?? json['owner_name'] as String? ?? '',
        businessName: json['businessName'] as String? ?? json['business_name'] as String? ?? '',
        businessCategory: json['businessCategory'] as String? ?? json['business_category'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        address: json['address'] as String? ?? '',
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
    await dio.put('/api/store-profile', data: profile.toJson());
  }

  @override
  Future<StoreProfileModel?> get() async {
    final response = await dio.get('/api/store-profile');
    final data = response.data;
    if (data is Map && data['profile'] == null) return null;
    return StoreProfileModel.fromJson(data['profile'] as Map<String, dynamic>);
  }
}
