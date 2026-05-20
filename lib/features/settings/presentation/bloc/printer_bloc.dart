import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../../../core/services/printer_service.dart';
import 'printer_event_state.dart';

class PrinterBloc extends Bloc<PrinterEvent, PrinterState> {
  final PrinterService printerService;
  final FlutterSecureStorage secureStorage;

  List<BluetoothInfo> _devices = [];
  String? _connectedMac;

  PrinterBloc({required this.printerService, required this.secureStorage})
    : super(PrinterInitial()) {
    on<ScanPrintersEvent>(_onScanPrinters);
    on<ConnectPrinterEvent>(_onConnectPrinter);
    on<DisconnectPrinterEvent>(_onDisconnectPrinter);
    on<PrintTestEvent>(_onPrintTest);
    on<PrintReceiptEvent>(_onPrintReceipt);
  }

  Future<void> _onScanPrinters(
    ScanPrintersEvent event,
    Emitter<PrinterState> emit,
  ) async {
    emit(PrinterLoading());
    try {
      _devices = await printerService.getPairedDevices();
      _connectedMac = await secureStorage.read(key: 'DEFAULT_PRINTER_MAC');

      // Auto connect to default printer if exists
      if (_connectedMac != null) {
        final isConnected = await printerService.isConnected;
        if (!isConnected) {
          await printerService.connect(_connectedMac!);
        }
      }

      emit(PrinterLoaded(_devices, _connectedMac));
    } catch (e) {
      emit(PrinterError(e.toString()));
    }
  }

  Future<void> _onConnectPrinter(
    ConnectPrinterEvent event,
    Emitter<PrinterState> emit,
  ) async {
    emit(PrinterLoading());
    try {
      final success = await printerService.connect(event.macAddress);
      if (success) {
        _connectedMac = event.macAddress;
        await secureStorage.write(
          key: 'DEFAULT_PRINTER_MAC',
          value: _connectedMac,
        );
        emit(const PrinterSuccess('Printer terhubung'));
      } else {
        emit(const PrinterError('Gagal menghubungkan printer'));
      }
      emit(PrinterLoaded(_devices, _connectedMac));
    } catch (e) {
      emit(PrinterError(e.toString()));
      emit(PrinterLoaded(_devices, _connectedMac));
    }
  }

  Future<void> _onDisconnectPrinter(
    DisconnectPrinterEvent event,
    Emitter<PrinterState> emit,
  ) async {
    emit(PrinterLoading());
    await printerService.disconnect();
    _connectedMac = null;
    await secureStorage.delete(key: 'DEFAULT_PRINTER_MAC');
    emit(PrinterLoaded(_devices, _connectedMac));
  }

  Future<void> _onPrintTest(
    PrintTestEvent event,
    Emitter<PrinterState> emit,
  ) async {
    try {
      await printerService.printTest();
      emit(const PrinterSuccess('Print test berhasil dikirim'));
    } catch (e) {
      emit(PrinterError('Gagal print: ${e.toString()}'));
    }
  }

  Future<void> _onPrintReceipt(
    PrintReceiptEvent event,
    Emitter<PrinterState> emit,
  ) async {
    try {
      final storeName = await secureStorage.read(key: 'STORE_NAME');
      final storeAddress = await secureStorage.read(key: 'STORE_ADDRESS');
      final storePhone = await secureStorage.read(key: 'STORE_PHONE');

      await printerService.printReceipt(
        event.transaction,
        storeName: storeName,
        storeAddress: storeAddress,
        storePhone: storePhone,
      );
      emit(const PrinterSuccess('Struk berhasil dicetak'));
    } catch (e) {
      emit(PrinterError('Gagal mencetak struk: ${e.toString()}'));
    }
  }
}
