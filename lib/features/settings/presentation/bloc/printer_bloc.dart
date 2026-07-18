import 'dart:convert';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../../../core/services/printer_service.dart';
import '../../domain/entities/printer_config.dart';
import 'printer_event_state.dart';

class PrinterBloc extends Bloc<PrinterEvent, PrinterState> {
  final PrinterService printerService;
  final FlutterSecureStorage secureStorage;

  List<BluetoothInfo> _devices = [];
  List<PrinterConfig> _printers = [];

  PrinterBloc({required this.printerService, required this.secureStorage})
    : super(PrinterInitial()) {
    on<ScanPrintersEvent>(_onScanPrinters);
    on<ConnectPrinterEvent>(_onConnectPrinter);
    on<RemovePrinterEvent>(_onRemovePrinter);
    on<PrintTestEvent>(_onPrintTest);
    on<PrintReceiptEvent>(_onPrintReceipt);
  }

  Future<bool> _bluetoothEnabled() async =>
      await PrintBluetoothThermal.bluetoothEnabled;

  Future<List<BluetoothInfo>> _pairedBluetooths() async =>
      await PrintBluetoothThermal.pairedBluetooths;

  Future<bool> _connect(String mac) async =>
      await PrintBluetoothThermal.connect(macPrinterAddress: mac);

  Future<bool> _disconnectNow() async => await PrintBluetoothThermal.disconnect;

  Future<List<PrinterConfig>> _loadPrinters() async {
    final json = await secureStorage.read(key: 'PRINTERS');
    if (json == null || json.isEmpty) return [];
    final list = jsonDecode(json) as List;
    return list
        .map((e) => PrinterConfig.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _savePrinters(List<PrinterConfig> printers) async {
    final json = jsonEncode(printers.map((p) => p.toJson()).toList());
    await secureStorage.write(key: 'PRINTERS', value: json);
  }

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
      _printers = await _loadPrinters();
      emit(PrinterLoaded(_devices, _printers, bluetoothOn: enabled));
    } catch (e) {
      emit(PrinterLoaded(_devices, _printers, bluetoothOn: false));
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
        await _disconnectNow();
        final config = PrinterConfig(
          macAddress: event.macAddress,
          label: event.label,
          role: event.role,
        );
        _printers = [
          ..._printers.where((p) => p.macAddress != event.macAddress),
          config,
        ];
        await _savePrinters(_printers);
        emit(const PrinterSuccess('Printer terhubung'));
      } else {
        emit(const PrinterError('Gagal menghubungkan printer'));
      }
      emit(PrinterLoaded(_devices, _printers));
    } catch (e) {
      emit(PrinterError(e.toString()));
      emit(PrinterLoaded(_devices, _printers));
    }
  }

  Future<void> _onRemovePrinter(
    RemovePrinterEvent event,
    Emitter<PrinterState> emit,
  ) async {
    _printers = _printers
        .where((p) => p.macAddress != event.macAddress)
        .toList();
    await _savePrinters(_printers);
    emit(PrinterLoaded(_devices, _printers));
  }

  Future<void> _sendToPrinter(String mac, List<int> bytes) async {
    final connected = await PrintBluetoothThermal.connectionStatus;
    if (connected) await _disconnectNow();
    await _connect(mac);
    await PrintBluetoothThermal.writeBytes(bytes);
    await _disconnectNow();
  }

  Future<void> _onPrintTest(
    PrintTestEvent event,
    Emitter<PrinterState> emit,
  ) async {
    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      final bytes =
          generator.text(
            'TEST PRINTER BERHASIL',
            styles: const PosStyles(align: PosAlign.center, bold: true),
          ) +
          generator.feed(2);

      if (event.macAddress != null) {
        await _sendToPrinter(event.macAddress!, bytes);
      } else {
        await PrintBluetoothThermal.writeBytes(bytes);
      }
      emit(const PrinterSuccess('Test print berhasil dikirim'));
    } catch (e) {
      emit(PrinterError('Gagal print: ${e.toString()}'));
    }
    emit(PrinterLoaded(_devices, _printers));
  }

  Future<void> _onPrintReceipt(
    PrintReceiptEvent event,
    Emitter<PrinterState> emit,
  ) async {
    try {
      final storeName = await secureStorage.read(key: 'STORE_NAME');
      final storeAddress = await secureStorage.read(key: 'STORE_ADDRESS');
      final storePhone = await secureStorage.read(key: 'STORE_PHONE');
      final storeLogoPath = await secureStorage.read(key: 'STORE_LOGO_PATH');
      final receiptHeader = await secureStorage.read(key: 'RECEIPT_HEADER');
      final receiptFooter = await secureStorage.read(key: 'RECEIPT_FOOTER');
      final paperSize = await secureStorage.read(key: 'PAPER_SIZE') ?? '58';
      final printLogo = await secureStorage.read(key: 'PRINT_LOGO') ?? 'true';
      final watermarkEnabled =
          await secureStorage.read(key: 'WATERMARK_ENABLED') ?? 'true';

      final bytes = await printerService.buildReceiptBytes(
        event.transaction,
        storeName: storeName,
        storeAddress: storeAddress,
        storePhone: storePhone,
        storeLogoPath: storeLogoPath,
        receiptHeader: receiptHeader,
        receiptFooter: receiptFooter,
        paperSize: paperSize,
        printLogo: printLogo == 'true',
        watermarkEnabled: watermarkEnabled == 'true',
      );

      if (event.macAddress != null) {
        await _sendToPrinter(event.macAddress!, bytes);
      } else {
        await PrintBluetoothThermal.writeBytes(bytes);
      }
      emit(const PrinterSuccess('Struk berhasil dicetak'));
    } catch (e) {
      emit(PrinterError('Gagal mencetak struk: ${e.toString()}'));
    }
  }
}
