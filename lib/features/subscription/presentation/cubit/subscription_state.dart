import 'package:equatable/equatable.dart';
import '../../domain/entities/subscription_status_entity.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();
  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionStatusLoading extends SubscriptionState {
  final SubscriptionStatusEntity? previous;
  const SubscriptionStatusLoading({this.previous});
  @override
  List<Object?> get props => [previous];
}

class SubscriptionStatusLoaded extends SubscriptionState {
  final SubscriptionStatusEntity status;
  const SubscriptionStatusLoaded(this.status);
  @override
  List<Object?> get props => [status];
}

class SubscriptionPurchaseInProgress extends SubscriptionState {
  final SubscriptionStatusEntity status;
  const SubscriptionPurchaseInProgress(this.status);
  @override
  List<Object?> get props => [status];
}

class SubscriptionError extends SubscriptionState {
  final String message;
  final SubscriptionStatusEntity? previous;
  const SubscriptionError(this.message, {this.previous});
  @override
  List<Object?> get props => [message, previous];
}
