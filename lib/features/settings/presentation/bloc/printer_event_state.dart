import 'package:equatable/equatable.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../domain/entities/printer_config.dart';

abstract class PrinterEvent extends Equatable {
  const PrinterEvent();
  @override
  List<Object?> get props => [];
}

class ScanPrintersEvent extends PrinterEvent {}

class ConnectPrinterEvent extends PrinterEvent {
  final String macAddress;
  final String label;
  final String role;
  const ConnectPrinterEvent(
    this.macAddress, {
    this.label = '',
    this.role = 'receipt',
  });
  @override
  List<Object?> get props => [macAddress, label, role];
}

class RemovePrinterEvent extends PrinterEvent {
  final String macAddress;
  const RemovePrinterEvent(this.macAddress);
  @override
  List<Object?> get props => [macAddress];
}

class PrintTestEvent extends PrinterEvent {
  final String? macAddress;
  const PrintTestEvent({this.macAddress});
  @override
  List<Object?> get props => [macAddress];
}

class PrintReceiptEvent extends PrinterEvent {
  final dynamic transaction;
  final String? macAddress;
  const PrintReceiptEvent(this.transaction, {this.macAddress});
  @override
  List<Object?> get props => [transaction, macAddress];
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
  final List<PrinterConfig> printers;
  final bool bluetoothOn;

  const PrinterLoaded(this.devices, this.printers, {this.bluetoothOn = true});

  PrinterConfig? get defaultPrinter =>
      printers.isNotEmpty ? printers.first : null;

  @override
  List<Object?> get props => [devices, printers, bluetoothOn];
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
