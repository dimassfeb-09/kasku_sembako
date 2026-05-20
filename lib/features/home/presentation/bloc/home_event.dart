import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeMetricsEvent extends HomeEvent {
  final String? userId;
  final bool isAdmin;

  const LoadHomeMetricsEvent({required this.userId, required this.isAdmin});

  @override
  List<Object?> get props => [userId, isAdmin];
}
