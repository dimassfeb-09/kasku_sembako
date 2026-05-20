import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  final String id;
  final String name;
  final String? phone;
  final String? notes;
  final double debtAmount;

  const CustomerEntity({
    required this.id,
    required this.name,
    this.phone,
    this.notes,
    required this.debtAmount,
  });

  CustomerEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? notes,
    double? debtAmount,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      debtAmount: debtAmount ?? this.debtAmount,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, notes, debtAmount];
}
