import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

class PrinterSettingsState {
  final bool isScanning;
  final String? connectingDeviceId;
  final bool isDisconnecting;
  final List<PrinterDevice> printers;
  final PaperSize paperSize;
  final Set<PrinterConnectionType> selectedTypes;

  const PrinterSettingsState({
    this.isScanning = false,
    this.connectingDeviceId,
    this.isDisconnecting = false,
    this.printers = const [],
    required this.paperSize,
    required this.selectedTypes,
  });

  PrinterSettingsState copyWith({
    bool? isScanning,
    String? connectingDeviceId,
    bool? isDisconnecting,
    List<PrinterDevice>? printers,
    PaperSize? paperSize,
    Set<PrinterConnectionType>? selectedTypes,
  }) {
    return PrinterSettingsState(
      isScanning: isScanning ?? this.isScanning,
      connectingDeviceId: connectingDeviceId ?? this.connectingDeviceId,
      isDisconnecting: isDisconnecting ?? this.isDisconnecting,
      printers: printers ?? this.printers,
      paperSize: paperSize ?? this.paperSize,
      selectedTypes: selectedTypes ?? this.selectedTypes,
    );
  }
}
