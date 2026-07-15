import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? color;

  const CategoryEntity({required this.id, required this.name, this.color});

  @override
  List<Object?> get props => [id, name, color];
}
