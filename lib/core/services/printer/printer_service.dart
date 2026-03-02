import 'dart:async';

import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

import '../../../domain/entities/transaction_entity.dart';
import '../../common/result.dart';
import '../../constants/constants.dart';
import '../../utilities/console_logger.dart';
import '../../utilities/currency_formatter.dart';
import '../../utilities/date_time_formatter.dart';

class PrinterService {
  final PrinterManager _manager = PrinterManager();
  final SharedPreferences _sharedPreferences;

  PrinterService({required SharedPreferences sharedPreferences}) : _sharedPreferences = sharedPreferences;

  List<PrinterDevice> printers = [];
  PrinterDevice? selectedPrinter;

  PrinterConnectionState get connectionState => _manager.state;
  Stream<PrinterConnectionState> get stateStream => _manager.stateStream;
  bool get isConnected => _manager.isConnected;

  PaperSize get paperSize {
    final saved = _sharedPreferences.getString(Constants.selectedPaperSizeKey);
    return switch (saved) {
      'mm72' => PaperSize.mm72,
      'mm80' => PaperSize.mm80,
      _ => PaperSize.mm58,
    };
  }

  void setPaperSize(PaperSize size) {
    final key = switch (size) {
      PaperSize.mm58 => 'mm58',
      PaperSize.mm72 => 'mm72',
      PaperSize.mm80 => 'mm80',
    };
    _sharedPreferences.setString(Constants.selectedPaperSizeKey, key);
  }

  Future<Result<void>> scanPrinters({
    Set<PrinterConnectionType> types = const {
      PrinterConnectionType.usb,
      PrinterConnectionType.bluetooth,
      PrinterConnectionType.ble,
      PrinterConnectionType.network,
    },
    String? selectedDeviceId,
    Function(List<PrinterDevice>)? onDeviceStream,
  }) async {
    final permissions = await checkPermissions();
    if (permissions.isFailure) return Result.failure(error: permissions.error!);

    try {
      printers = [];
      final stream = _manager.scanAll(
        timeout: const Duration(seconds: 5),
        types: types,
      );

      await for (final devices in stream) {
        for (final device in devices) {
          if (!printers.any((p) => getDeviceId(p) == getDeviceId(device))) {
            printers.add(device);
          }
        }

        onDeviceStream?.call(printers);

        if (selectedDeviceId != null) {
          final match = printers.where((d) => getDeviceId(d) == selectedDeviceId).firstOrNull;
          if (match != null && selectedPrinter == null) {
            await selectPrinter(match);
          } else if (match != null) {
            // Update reference to the new scan instance without reconnecting
            selectedPrinter = match;
          }
        }
      }

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e.toString());
    }
  }

  Future<void> selectPrinter(PrinterDevice device) async {
    selectedPrinter = device;
    cl('[PrinterService].selectPrinter: ${device.name} (${device.connectionType.name})');

    try {
      if (_manager.isConnected) await _manager.disconnect();
      await _manager.connect(device, timeout: const Duration(seconds: 10));
    } catch (e) {
      cl('[PrinterService].selectPrinter connection error: $e');
    }
  }

  Future<Result<void>> printTicket(Ticket ticket) async {
    if (selectedPrinter == null) {
      return Result.failure(error: 'Printer is not selected yet!');
    }

    try {
      if (!_manager.isConnected) {
        await _manager.connect(selectedPrinter!, timeout: const Duration(seconds: 10));
      }

      await _manager.printTicket(ticket);
      return Result.success(data: null);
    } on PrinterException catch (e) {
      return Result.failure(error: e.message);
    } catch (e) {
      return Result.failure(error: e.toString());
    }
  }

  Future<Result<void>> printData(List<int> bytes) async {
    if (selectedPrinter == null) {
      return Result.failure(error: 'Printer is not selected yet!');
    }

    try {
      if (!_manager.isConnected) {
        await _manager.connect(selectedPrinter!, timeout: const Duration(seconds: 10));
      }

      await _manager.printBytes(bytes);
      return Result.success(data: null);
    } on PrinterException catch (e) {
      return Result.failure(error: e.message);
    } catch (e) {
      return Result.failure(error: e.toString());
    }
  }

  Future<Result<void>> printTransaction(TransactionEntity transaction) async {
    try {
      final ticket = await Ticket.create(paperSize);

      ticket.text(
        'FLUTTER POS',
        styles: const TextStyles(
          bold: true,
          align: PrintAlign.center,
          height: TextSize.size2,
          width: TextSize.size2,
        ),
      );
      ticket.text(
        'https://github.com/elrizwiraswara/flutter_pos',
        styles: TextStyles(
          align: PrintAlign.center,
          fontType: FontType.fontB,
        ),
      );

      ticket.emptyLines();

      final date = DateTimeFormatter.slashDateShortedYearWithClock(
        transaction.createdAt ?? DateTime.now().toIso8601String(),
      );

      ticket.text('Date: $date');
      ticket.text('Trx. ID: #${transaction.id}');
      ticket.text('Customer: ${transaction.customerName ?? '-'}');
      ticket.text('Created by: ${transaction.createdBy?.name ?? '-'}');

      ticket.separator();

      ticket.row([
        PrintColumn(
          text: 'Item',
          flex: 2,
          styles: const TextStyles(bold: true),
        ),
        PrintColumn(
          text: 'Qty',
          flex: 1,
          styles: const TextStyles(bold: true, align: PrintAlign.center),
        ),
        PrintColumn(
          text: 'Price',
          flex: 2,
          styles: const TextStyles(bold: true, align: PrintAlign.right),
        ),
        PrintColumn(
          text: 'Subtotal',
          flex: 2,
          styles: const TextStyles(bold: true, align: PrintAlign.right),
        ),
      ]);
      ticket.separator();

      if (transaction.orderedProducts != null) {
        for (final product in transaction.orderedProducts!) {
          ticket.row([
            PrintColumn(
              text: product.name,
              flex: 2,
            ),
            PrintColumn(
              text: '${product.quantity}',
              flex: 1,
              styles: const TextStyles(align: PrintAlign.center),
            ),
            PrintColumn(
              text: CurrencyFormatter.format(product.price),
              flex: 2,
              styles: const TextStyles(align: PrintAlign.right),
            ),
            PrintColumn(
              text: CurrencyFormatter.format(product.price * product.quantity),
              flex: 2,
              styles: const TextStyles(align: PrintAlign.right),
            ),
          ]);
        }
      }

      ticket.separator();

      ticket.row([
        PrintColumn(
          text: 'Total',
          flex: 2,
          styles: const TextStyles(bold: true),
        ),
        PrintColumn(
          text: CurrencyFormatter.format(transaction.totalAmount),
          flex: 1,
          styles: const TextStyles(bold: true, align: PrintAlign.right),
        ),
      ]);
      ticket.row([
        PrintColumn(
          text: 'Pay (${transaction.paymentMethod})',
          flex: 2,
        ),
        PrintColumn(
          text: CurrencyFormatter.format(transaction.receivedAmount),
          flex: 1,
          styles: const TextStyles(align: PrintAlign.right),
        ),
      ]);
      ticket.row([
        PrintColumn(
          text: 'Change',
          flex: 2,
        ),
        PrintColumn(
          text: CurrencyFormatter.format(transaction.returnAmount),
          flex: 1,
          styles: const TextStyles(align: PrintAlign.right),
        ),
      ]);

      ticket.emptyLines();
      ticket.qrcode('${transaction.id}', size: QRSize.size3);
      ticket.emptyLines();
      ticket.text('Thank you for your purchase!', styles: const TextStyles(align: PrintAlign.center));
      ticket.text('Yatta!', styles: const TextStyles(align: PrintAlign.center));
      ticket.cut(linesBefore: 2);

      return await printTicket(ticket);
    } catch (e) {
      return Result.failure(error: e.toString());
    }
  }

  Future<Result<void>> testPrint() async {
    try {
      final ticket = await Ticket.create(paperSize);

      ticket.row([
        PrintColumn(
          text: 'top left',
          flex: 1,
        ),
        PrintColumn(
          text: 'top right',
          flex: 1,
          styles: const TextStyles(align: PrintAlign.right),
        ),
      ]);

      ticket.emptyLines(3);

      ticket.text(
        'FLUTTER POS PRINT TEST OK',
        styles: const TextStyles(
          bold: true,
          align: PrintAlign.center,
        ),
      );
      await ticket.textRaster(
        'ありがとうございます',
        align: PrintAlign.center,
      );

      ticket.emptyLines(3);

      ticket.row([
        PrintColumn(
          text: 'bottom left',
          flex: 1,
        ),
        PrintColumn(
          text: 'bottom right',
          flex: 1,
          styles: const TextStyles(align: PrintAlign.right),
        ),
      ]);

      ticket.feed(4);
      ticket.cut();

      return await printTicket(ticket);
    } catch (e) {
      return Result.failure(error: e.toString());
    }
  }

  Future<Result<void>> checkPermissions() async {
    final isBluetoothScanGranted = await Permission.bluetoothScan.request();
    if (isBluetoothScanGranted.isDenied) {
      return Result.failure(error: 'Bluetooth scan permission is not granted!');
    }

    final isBluetoothConnectGranted = await Permission.bluetoothConnect.request();
    if (isBluetoothConnectGranted.isDenied) {
      return Result.failure(error: 'Bluetooth connect permission is not granted!');
    }

    return Result.success(data: null);
  }

  String getDeviceId(PrinterDevice device) {
    return switch (device) {
      NetworkPrinterDevice d => '${d.host}:${d.port}',
      BlePrinterDevice d => d.deviceId,
      BluetoothPrinterDevice d => d.address,
      UsbPrinterDevice d => d.identifier,
      _ => device.name,
    };
  }

  Future<void> dispose() async {
    await _manager.dispose();
  }
}
