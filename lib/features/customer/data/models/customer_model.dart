import '../../../../core/database/app_database.dart';
import '../../domain/entities/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id,
    required super.name,
    super.phone,
    super.notes,
    required super.debtAmount,
  });

  factory CustomerModel.fromDrift(Customer customer) {
    return CustomerModel(
      id: customer.id,
      name: customer.name,
      phone: customer.phone,
      notes: customer.notes,
      debtAmount: customer.debtAmount,
    );
  }
}
