import 'package:flutter/material.dart';
import 'package:flutter_pos/app/di/dependency_injection.dart';
import 'package:flutter_pos/presentation/widgets/app_button.dart';
import 'package:flutter_pos/presentation/widgets/app_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

import '../../../core/services/printer/printer_service.dart';
import '../../../core/themes/app_sizes.dart';
import '../../providers/account/printer_settings_provider.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      di<PrinterSettingsProvider>().getAndSelectPrinter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer Settings'),
        titleSpacing: 0,
      ),
      body: Consumer<PrinterSettingsProvider>(
        builder: (context, model, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ConnectionTypeFilter(model: model),
                const SizedBox(height: AppSizes.padding),
                _PaperSizeSelector(model: model),
                const SizedBox(height: AppSizes.padding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Available Devices',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: AppSizes.padding / 1.5),
                        if (model.isScanning)
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        AppIconButton(
                          icon: Icons.refresh,
                          iconSize: 18,
                          enabled: !model.isScanning,
                          onTap: () {
                            di<PrinterSettingsProvider>().getAndSelectPrinter();
                          },
                        ),
                        const SizedBox(width: 4),
                        AppIconButton(
                          icon: Icons.print_outlined,
                          iconSize: 18,
                          enabled: model.selectedPrinterIndex != -1,
                          onTap: () {
                            di<PrinterService>().testPrint();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.padding),
                if (model.printers.isNotEmpty)
                  Column(
                    spacing: AppSizes.padding,
                    children: List.generate(
                      model.printers.length,
                      (i) => _PrinterButton(
                        printer: model.printers[i],
                        isSelected: model.selectedPrinterIndex == i,
                        subtitle: model.getDeviceSubtitle(model.printers[i]),
                      ),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(AppSizes.padding * 2),
                    child: Center(
                      child: Text(
                        model.isScanning ? 'Scanning for printers...' : '(No printer detected)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PaperSizeSelector extends StatelessWidget {
  final PrinterSettingsProvider model;

  const _PaperSizeSelector({required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Paper Size',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PaperSize.values.map((size) {
            final isSelected = model.paperSize == size;
            return ChoiceChip(
              label: Text(_label(size)),
              selected: isSelected,
              onSelected: (_) => model.setPaperSize(size),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _label(PaperSize size) {
    return switch (size) {
      PaperSize.mm58 => '58mm',
      PaperSize.mm72 => '72mm',
      PaperSize.mm80 => '80mm',
    };
  }
}

class _ConnectionTypeFilter extends StatelessWidget {
  final PrinterSettingsProvider model;

  const _ConnectionTypeFilter({required this.model});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PrinterConnectionType.values.map((type) {
        final isSelected = model.selectedTypes.contains(type);
        return FilterChip(
          label: Text(_label(type)),
          avatar: Icon(_icon(type), size: 18),
          selected: isSelected,
          showCheckmark: false,
          onSelected: (_) => model.toggleConnectionType(type),
        );
      }).toList(),
    );
  }

  String _label(PrinterConnectionType type) {
    return switch (type) {
      PrinterConnectionType.usb => 'USB',
      PrinterConnectionType.bluetooth => 'Bluetooth',
      PrinterConnectionType.ble => 'BLE',
      PrinterConnectionType.network => 'Network',
    };
  }

  IconData _icon(PrinterConnectionType type) {
    return switch (type) {
      PrinterConnectionType.usb => Icons.usb,
      PrinterConnectionType.bluetooth => Icons.bluetooth,
      PrinterConnectionType.ble => Icons.bluetooth_searching,
      PrinterConnectionType.network => Icons.wifi,
    };
  }
}

class _PrinterButton extends StatelessWidget {
  final PrinterDevice printer;
  final bool isSelected;
  final String subtitle;

  const _PrinterButton({
    required this.printer,
    required this.isSelected,
    required this.subtitle,
  });

  IconData _connectionIcon(PrinterConnectionType type) {
    return switch (type) {
      PrinterConnectionType.usb => Icons.usb,
      PrinterConnectionType.bluetooth => Icons.bluetooth,
      PrinterConnectionType.ble => Icons.bluetooth_searching,
      PrinterConnectionType.network => Icons.wifi,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      buttonColor: isSelected
          ? Theme.of(context).colorScheme.surfaceContainer
          : Theme.of(context).colorScheme.surfaceContainerLowest,
      borderColor: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _connectionIcon(printer.connectionType),
                size: 36,
              ),
              const SizedBox(width: AppSizes.padding),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    printer.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          if (isSelected)
            Icon(
              Icons.check_circle,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
      onTap: () {
        di<PrinterSettingsProvider>().onSelectPrinter(printer);
      },
    );
  }
}
