import 'package:equatable/equatable.dart';
import '../../domain/entities/home_metrics.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeMetricsLoading extends HomeState {}

class HomeMetricsLoaded extends HomeState {
  final HomeMetrics metrics;

  const HomeMetricsLoaded(this.metrics);

  @override
  List<Object?> get props => [metrics];
}

class HomeMetricsError extends HomeState {
  final String message;

  const HomeMetricsError(this.message);

  @override
  List<Object?> get props => [message];
}
