import 'package:equatable/equatable.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

abstract class PrinterEvent extends Equatable {
  const PrinterEvent();
  @override
  List<Object?> get props => [];
}

class ScanPrintersEvent extends PrinterEvent {}

class ConnectPrinterEvent extends PrinterEvent {
  final String macAddress;
  const ConnectPrinterEvent(this.macAddress);
  @override
  List<Object?> get props => [macAddress];
}

class DisconnectPrinterEvent extends PrinterEvent {}

class PrintTestEvent extends PrinterEvent {}

class PrintReceiptEvent extends PrinterEvent {
  final dynamic
  transaction; // Using dynamic here to avoid complex imports if not needed, or TransactionEntity
  const PrintReceiptEvent(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

abstract class PrinterState extends Equatable {
  const PrinterState();
  @override
  List<Object?> get props => [];
}

class PrinterInitial extends PrinterState {}

class PrinterLoading extends PrinterState {}

class PrinterLoaded extends PrinterState {
  final List<BluetoothInfo> devices;
  final String? connectedMacAddress;
  final bool bluetoothOn;

  const PrinterLoaded(this.devices, this.connectedMacAddress, {this.bluetoothOn = true});

  @override
  List<Object?> get props => [devices, connectedMacAddress, bluetoothOn];
}

class PrinterError extends PrinterState {
  final String message;
  const PrinterError(this.message);
  @override
  List<Object?> get props => [message];
}

class PrinterSuccess extends PrinterState {
  final String message;
  const PrinterSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
