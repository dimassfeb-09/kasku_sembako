import '../../../../core/database/app_database.dart';
import '../../domain/entities/wholesale_price_entity.dart';

class WholesalePriceModel extends WholesalePriceEntity {
  const WholesalePriceModel({
    required super.id,
    required super.productId,
    required super.minQty,
    required super.price,
  });

  factory WholesalePriceModel.fromDrift(WholesalePrice price) {
    return WholesalePriceModel(
      id: price.id,
      productId: price.productId,
      minQty: price.minQty,
      price: price.price,
    );
  }
}
