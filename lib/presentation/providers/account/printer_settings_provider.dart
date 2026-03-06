import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

import '../../../core/constants/constants.dart';
import '../../../core/services/printer/printer_service.dart';
import '../../widgets/app_snack_bar.dart';

class PrinterSettingsProvider extends ChangeNotifier {
  final PrinterService printerService;
  final SharedPreferences sharedPreferences;
  final Set<PrinterConnectionType> _selectedTypes = {
    PrinterConnectionType.usb,
    PrinterConnectionType.bluetooth,
    PrinterConnectionType.ble,
    PrinterConnectionType.network,
  };

  PrinterSettingsProvider({
    required this.printerService,
    required this.sharedPreferences,
  }) : _paperSize = printerService.paperSize;

  bool _isScanning = false;
  String? _connectingDeviceId;
  bool _isDisconnecting = false;
  List<PrinterDevice> _printers = const [];
  PaperSize _paperSize;

  List<PrinterDevice> get printers => _printers;
  bool get isScanning => _isScanning;
  bool get isConnecting => _connectingDeviceId != null;
  bool get isDisconnecting => _isDisconnecting;
  Set<PrinterConnectionType> get selectedTypes => Set.unmodifiable(_selectedTypes);

  PaperSize get paperSize => _paperSize;

  void setPaperSize(PaperSize size) {
    if (_paperSize == size) return;

    printerService.setPaperSize(size);
    _paperSize = size;
    notifyListeners();
  }

  int get selectedPrinterIndex {
    if (printerService.selectedPrinter == null) return -1;
    final selectedId = printerService.getDeviceId(printerService.selectedPrinter!);
    return _printers.indexWhere(
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
    if (_isScanning || _isDisconnecting) return;

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
    if (_hasSamePrinters(printers)) return;

    _printers = List.unmodifiable(printers);
    notifyListeners();
  }

  Future<void> onSelectPrinter(PrinterDevice printer) async {
    final deviceId = printerService.getDeviceId(printer);
    if (_connectingDeviceId == deviceId || _isDisconnecting) return;

    _connectingDeviceId = deviceId;
    notifyListeners();

    final result = await printerService.selectPrinter(printer);
    _connectingDeviceId = null;

    if (result.isFailure) {
      notifyListeners();
      AppSnackBar.showError(result.error.toString());
      return;
    }

    sharedPreferences.setString(Constants.selectedDeviceIdKey, deviceId);
    sharedPreferences.setString(Constants.selectedConnectionTypeKey, printer.connectionType.name);
    notifyListeners();
  }

  Future<void> disconnectPrinter() async {
    if (_isDisconnecting || _connectingDeviceId != null) return;

    _isDisconnecting = true;
    notifyListeners();

    final result = await printerService.disconnectPrinter();
    _isDisconnecting = false;

    if (result.isFailure) {
      notifyListeners();
      AppSnackBar.showError(result.error.toString());
      return;
    }

    await sharedPreferences.remove(Constants.selectedDeviceIdKey);
    await sharedPreferences.remove(Constants.selectedConnectionTypeKey);
    notifyListeners();
    AppSnackBar.show('Printer disconnected');
  }

  bool isConnectingPrinter(PrinterDevice device) {
    return _connectingDeviceId == printerService.getDeviceId(device);
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

  bool _hasSamePrinters(List<PrinterDevice> printers) {
    if (_printers.length != printers.length) return false;

    for (int i = 0; i < printers.length; i++) {
      if (printerService.getDeviceId(_printers[i]) != printerService.getDeviceId(printers[i])) {
        return false;
      }
    }

    return true;
  }
}
