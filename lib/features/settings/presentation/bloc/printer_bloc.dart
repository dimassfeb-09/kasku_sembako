import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
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

  Future<bool> _bluetoothEnabled() async =>
    await PrintBluetoothThermal.bluetoothEnabled;

  Future<List<BluetoothInfo>> _pairedBluetooths() async =>
    await PrintBluetoothThermal.pairedBluetooths;

  Future<bool> _connect(String mac) async =>
    await PrintBluetoothThermal.connect(macPrinterAddress: mac);

  Future<bool> _disconnect() async =>
    await PrintBluetoothThermal.disconnect;

  Future<bool> get _connectionStatus =>
    PrintBluetoothThermal.connectionStatus;

  Future<void> _onScanPrinters(
    ScanPrintersEvent event,
    Emitter<PrinterState> emit,
  ) async {
    emit(PrinterLoading());
    try {
      final enabled = await _bluetoothEnabled();
      if (enabled) {
        _devices = await _pairedBluetooths();
      } else {
        _devices = [];
      }
      _connectedMac = await secureStorage.read(key: 'DEFAULT_PRINTER_MAC');

      if (_connectedMac != null && enabled) {
        final connected = await _connectionStatus;
        if (!connected) await _connect(_connectedMac!);
      }

      emit(PrinterLoaded(_devices, _connectedMac, bluetoothOn: enabled));
    } catch (e) {
      emit(PrinterLoaded(_devices, _connectedMac, bluetoothOn: false));
    }
  }

  Future<void> _onConnectPrinter(
    ConnectPrinterEvent event,
    Emitter<PrinterState> emit,
  ) async {
    emit(PrinterLoading());
    try {
      final success = await _connect(event.macAddress);
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
    await _disconnect();
    _connectedMac = null;
    await secureStorage.delete(key: 'DEFAULT_PRINTER_MAC');
    emit(PrinterLoaded(_devices, _connectedMac));
  }

  Future<void> _onPrintTest(
    PrintTestEvent event,
    Emitter<PrinterState> emit,
  ) async {
    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      final bytes = generator.text(
        'TEST PRINTER BERHASIL',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      ) + generator.feed(2);
      await PrintBluetoothThermal.writeBytes(bytes);
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
      final receiptHeader = await secureStorage.read(key: 'RECEIPT_HEADER');
      final receiptFooter = await secureStorage.read(key: 'RECEIPT_FOOTER');

      await printerService.printReceipt(
        event.transaction,
        storeName: storeName,
        storeAddress: storeAddress,
        storePhone: storePhone,
        receiptHeader: receiptHeader,
        receiptFooter: receiptFooter,
      );
      emit(const PrinterSuccess('Struk berhasil dicetak'));
    } catch (e) {
      emit(PrinterError('Gagal mencetak struk: ${e.toString()}'));
    }
  }
}
