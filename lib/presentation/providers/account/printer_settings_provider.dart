import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_pos/core/utilities/console_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

import '../../../core/constants/constants.dart';
import '../../../core/services/printer/printer_service.dart';
import '../../widgets/app_snack_bar.dart';

class PrinterSettingsProvider extends ChangeNotifier {
  final PrinterService printerService;
  final SharedPreferences sharedPreferences;

  StreamSubscription<PrinterConnectionState>? _stateSubscription;

  PrinterSettingsProvider({
    required this.printerService,
    required this.sharedPreferences,
  }) {
    _stateSubscription = printerService.stateStream.listen((_) {
      notifyListeners();
    });
  }

  final Set<PrinterConnectionType> _selectedTypes = {
    PrinterConnectionType.usb,
    PrinterConnectionType.bluetooth,
    PrinterConnectionType.ble,
    PrinterConnectionType.network,
  };

  bool _isScanning = false;

  List<PrinterDevice> get printers => printerService.printers;
  bool get isScanning => _isScanning;
  Set<PrinterConnectionType> get selectedTypes => _selectedTypes;

  PaperSize get paperSize => printerService.paperSize;

  void setPaperSize(PaperSize size) {
    printerService.setPaperSize(size);
    notifyListeners();
  }

  int get selectedPrinterIndex {
    if (printerService.selectedPrinter == null) return -1;
    final selectedId = printerService.getDeviceId(printerService.selectedPrinter!);
    return printerService.printers.indexWhere(
      (p) => printerService.getDeviceId(p) == selectedId,
    );
  }

  void toggleConnectionType(PrinterConnectionType type) {
    if (_selectedTypes.contains(type)) {
      if (_selectedTypes.length > 1) _selectedTypes.remove(type);
    } else {
      _selectedTypes.add(type);
    }
    notifyListeners();
  }

  Future<void> getAndSelectPrinter() async {
    _isScanning = true;
    notifyListeners();

    final selectedDeviceId = sharedPreferences.getString(Constants.selectedDeviceIdKey);

    final result = await printerService.scanPrinters(
      types: _selectedTypes,
      selectedDeviceId: selectedDeviceId,
      onDeviceStream: _onDeviceStream,
    );

    _isScanning = false;
    notifyListeners();

    if (result.isFailure) {
      AppSnackBar.showError(result.error.toString());
    }
  }

  void _onDeviceStream(List<PrinterDevice> printers) {
    cl("[PrinterSettingsProvider].onDeviceStream: ${printers.map((e) => e.name).toList()}");
    notifyListeners();
  }

  Future<void> onSelectPrinter(PrinterDevice printer) async {
    final deviceId = printerService.getDeviceId(printer);
    await printerService.selectPrinter(printer);
    sharedPreferences.setString(Constants.selectedDeviceIdKey, deviceId);
    sharedPreferences.setString(Constants.selectedConnectionTypeKey, printer.connectionType.name);
    notifyListeners();
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    super.dispose();
  }

  String getDeviceSubtitle(PrinterDevice device) {
    return switch (device) {
      NetworkPrinterDevice d => '${d.host}:${d.port}',
      BlePrinterDevice d => d.deviceId,
      BluetoothPrinterDevice d => d.address,
      UsbPrinterDevice d => d.identifier,
      _ => device.connectionType.name,
    };
  }
}
