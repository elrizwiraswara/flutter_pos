import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/constants/constants.dart';
import '../../widgets/app_snack_bar.dart';
import 'printer_settings_state.dart';

final printerSettingsNotifierProvider = NotifierProvider.autoDispose<PrinterSettingsNotifier, PrinterSettingsState>(
  PrinterSettingsNotifier.new,
);

class PrinterSettingsNotifier extends AutoDisposeNotifier<PrinterSettingsState> {
  @override
  PrinterSettingsState build() {
    final printerService = ref.watch(printerServiceProvider);
    return PrinterSettingsState(
      paperSize: printerService.paperSize,
      selectedTypes: {
        PrinterConnectionType.usb,
        PrinterConnectionType.bluetooth,
        PrinterConnectionType.ble,
        PrinterConnectionType.network,
      },
    );
  }

  void setPaperSize(PaperSize size) {
    if (state.paperSize == size) return;

    ref.read(printerServiceProvider).setPaperSize(size);
    state = state.copyWith(paperSize: size);
  }

  int get selectedPrinterIndex {
    final printerService = ref.read(printerServiceProvider);
    if (printerService.selectedPrinter == null) return -1;
    final selectedId = printerService.getDeviceId(printerService.selectedPrinter!);
    return state.printers.indexWhere(
      (p) => printerService.getDeviceId(p) == selectedId,
    );
  }

  bool get isConnecting => state.connectingDeviceId != null;

  void toggleConnectionType(PrinterConnectionType type) {
    final types = Set<PrinterConnectionType>.from(state.selectedTypes);
    if (types.contains(type)) {
      if (types.length > 1) types.remove(type);
    } else {
      types.add(type);
    }
    state = state.copyWith(selectedTypes: types);
  }

  Future<void> getAndSelectPrinter() async {
    if (state.isScanning || state.isDisconnecting) return;

    final printerService = ref.read(printerServiceProvider);
    final sharedPreferences = ref.read(sharedPreferencesProvider);

    state = state.copyWith(isScanning: true);

    final selectedDeviceId = sharedPreferences.getString(Constants.selectedDeviceIdKey);

    final result = await printerService.scanPrinters(
      types: state.selectedTypes,
      selectedDeviceId: selectedDeviceId,
      onDeviceStream: _onDeviceStream,
    );

    state = state.copyWith(isScanning: false);

    if (result.isFailure) {
      AppSnackBar.showError(result.error.toString());
    }
  }

  void _onDeviceStream(List<PrinterDevice> printers) {
    if (_hasSamePrinters(printers)) return;

    state = state.copyWith(printers: List.unmodifiable(printers));
  }

  Future<void> onSelectPrinter(PrinterDevice printer) async {
    final printerService = ref.read(printerServiceProvider);
    final sharedPreferences = ref.read(sharedPreferencesProvider);

    final deviceId = printerService.getDeviceId(printer);
    if (state.connectingDeviceId == deviceId || state.isDisconnecting) return;

    state = state.copyWith(connectingDeviceId: deviceId);

    final result = await printerService.selectPrinter(printer);
    state = state.copyWith(connectingDeviceId: null);

    if (result.isFailure) {
      AppSnackBar.showError(result.error.toString());
      return;
    }

    sharedPreferences.setString(Constants.selectedDeviceIdKey, deviceId);
    sharedPreferences.setString(Constants.selectedConnectionTypeKey, printer.connectionType.name);
  }

  Future<void> disconnectPrinter() async {
    if (state.isDisconnecting || state.connectingDeviceId != null) return;

    final printerService = ref.read(printerServiceProvider);
    final sharedPreferences = ref.read(sharedPreferencesProvider);

    state = state.copyWith(isDisconnecting: true);

    final result = await printerService.disconnectPrinter();
    state = state.copyWith(isDisconnecting: false);

    if (result.isFailure) {
      AppSnackBar.showError(result.error.toString());
      return;
    }

    await sharedPreferences.remove(Constants.selectedDeviceIdKey);
    await sharedPreferences.remove(Constants.selectedConnectionTypeKey);
    AppSnackBar.show('Printer disconnected');
  }

  bool isConnectingPrinter(PrinterDevice device) {
    final printerService = ref.read(printerServiceProvider);
    return state.connectingDeviceId == printerService.getDeviceId(device);
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
    final current = state.printers;
    if (current.length != printers.length) return false;

    final printerService = ref.read(printerServiceProvider);
    for (int i = 0; i < printers.length; i++) {
      if (printerService.getDeviceId(current[i]) != printerService.getDeviceId(printers[i])) {
        return false;
      }
    }

    return true;
  }
}
