import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unified_esc_pos_printer/unified_esc_pos_printer.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/themes/app_sizes.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_drop_down.dart';
import '../../widgets/app_icon_button.dart';
import '../../widgets/app_snack_bar.dart';

class PrinterSettingsScreen extends ConsumerStatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  ConsumerState<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends ConsumerState<PrinterSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(printerSettingsControllerProvider).getAndSelectPrinter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer Settings'),
        titleSpacing: 0,
      ),
      body: const _PrinterSettingsBody(),
    );
  }
}

class _PrinterSettingsBody extends StatelessWidget {
  const _PrinterSettingsBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _SettingsRow(),
          SizedBox(height: AppSizes.padding * 1.5),
          _DevicesHeader(),
          SizedBox(height: AppSizes.padding),
          _PrinterList(),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _ConnectionTypeDropDown()),
        SizedBox(width: AppSizes.padding),
        Expanded(child: _PaperSizeSelector()),
      ],
    );
  }
}

class _PaperSizeSelector extends ConsumerWidget {
  const _PaperSizeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paperSize = ref.watch(printerSettingsControllerProvider.select((p) => p.paperSize));
    final isScanning = ref.watch(printerSettingsControllerProvider.select((p) => p.isScanning));
    final isConnecting = ref.watch(printerSettingsControllerProvider.select((p) => p.isConnecting));
    final isDisconnecting = ref.watch(printerSettingsControllerProvider.select((p) => p.isDisconnecting));

    final isBusy = isScanning || isConnecting || isDisconnecting;

    return AppDropDown<PaperSize>(
      labelText: 'Paper Size',
      selectedValue: paperSize,
      enabled: !isBusy,
      dropdownItems: PaperSize.values.map((size) {
        return DropdownMenuItem<PaperSize>(
          value: size,
          child: Text(_label(size)),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;
        ref.read(printerSettingsControllerProvider).setPaperSize(value);
      },
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

class _ConnectionTypeDropDown extends ConsumerWidget {
  const _ConnectionTypeDropDown();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTypes = ref.watch(printerSettingsControllerProvider.select((p) => p.selectedTypes));
    final isScanning = ref.watch(printerSettingsControllerProvider.select((p) => p.isScanning));
    final isConnecting = ref.watch(printerSettingsControllerProvider.select((p) => p.isConnecting));
    final isDisconnecting = ref.watch(printerSettingsControllerProvider.select((p) => p.isDisconnecting));

    final isBusy = isScanning || isConnecting || isDisconnecting;

    return AppDropDown<PrinterConnectionType>.multi(
      labelText: 'Connection Types',
      hintText: 'Select connection types',
      enabled: !isBusy,
      selectedValues: selectedTypes,
      dropdownItems: PrinterConnectionType.values.map((type) {
        return DropdownMenuItem<PrinterConnectionType>(
          value: type,
          child: Row(
            children: [
              Icon(_icon(type), size: 18),
              const SizedBox(width: 8),
              Text(_label(type)),
            ],
          ),
        );
      }).toList(),
      selectedValuesTextBuilder: _selectedLabel,
      onChanged: (type) {
        if (type == null) return;
        ref.read(printerSettingsControllerProvider).toggleConnectionType(type);
      },
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

  String _selectedLabel(Set<PrinterConnectionType> selectedTypes) {
    if (selectedTypes.length == PrinterConnectionType.values.length) {
      return 'All connection types';
    }

    return selectedTypes.map(_label).join(', ');
  }
}

class _DevicesHeader extends ConsumerWidget {
  const _DevicesHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isScanning = ref.watch(printerSettingsControllerProvider.select((p) => p.isScanning));
    final isConnecting = ref.watch(printerSettingsControllerProvider.select((p) => p.isConnecting));
    final isDisconnecting = ref.watch(printerSettingsControllerProvider.select((p) => p.isDisconnecting));
    final hasSelectedPrinter = ref.watch(printerSettingsControllerProvider.select((p) => p.selectedPrinterIndex != -1));

    final isBusy = isScanning || isConnecting || isDisconnecting;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Available Devices',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: AppSizes.padding / 1.5),
            if (isScanning || isDisconnecting)
              const SizedBox(
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
              enabled: !isBusy,
              onTap: () {
                ref.read(printerSettingsControllerProvider).getAndSelectPrinter();
              },
            ),
            const SizedBox(width: 4),
            AppIconButton(
              icon: Icons.link_off,
              iconSize: 18,
              enabled: hasSelectedPrinter && !isBusy,
              onTap: () {
                ref.read(printerSettingsControllerProvider).disconnectPrinter();
              },
            ),
            const SizedBox(width: 4),
            AppIconButton(
              icon: Icons.print_outlined,
              iconSize: 18,
              enabled: hasSelectedPrinter && !isConnecting,
              onTap: () async {
                final result = await ref.read(printerServiceProvider).testPrint();

                if (result.isFailure) {
                  AppSnackBar.showError(result.error.toString());
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _PrinterList extends ConsumerWidget {
  const _PrinterList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(printerSettingsControllerProvider);

    final printers = ref.watch(printerSettingsControllerProvider.select((p) => p.printers));
    final isScanning = ref.watch(printerSettingsControllerProvider.select((p) => p.isScanning));
    final isConnecting = ref.watch(printerSettingsControllerProvider.select((p) => p.isConnecting));
    final selectedPrinterIndex = ref.watch(printerSettingsControllerProvider.select((p) => p.selectedPrinterIndex));

    if (printers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSizes.padding * 2),
        child: Center(
          child: Text(
            isScanning ? 'Scanning for printers...' : '(No printer detected)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      );
    }

    return Column(
      spacing: AppSizes.padding,
      children: List.generate(
        printers.length,
        (i) {
          final printer = printers[i];
          final isLoading = provider.isConnectingPrinter(printer);

          return _PrinterButton(
            printer: printer,
            isSelected: selectedPrinterIndex == i || isLoading,
            isLoading: isLoading,
            enabled: !isConnecting || isLoading,
            subtitle: provider.getDeviceSubtitle(printer),
            onTap: () => provider.onSelectPrinter(printer),
          );
        },
      ),
    );
  }
}

class _PrinterButton extends StatelessWidget {
  final PrinterDevice printer;
  final bool isSelected;
  final bool isLoading;
  final bool enabled;
  final String subtitle;
  final VoidCallback onTap;

  const _PrinterButton({
    required this.printer,
    required this.isSelected,
    required this.isLoading,
    required this.enabled,
    required this.subtitle,
    required this.onTap,
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
      enabled: enabled,
      buttonColor: isSelected
          ? Theme.of(context).colorScheme.surfaceContainer
          : Theme.of(context).colorScheme.surfaceContainerLowest,
      borderColor: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
      onTap: onTap,
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
          if (isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 2.0),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          else if (isSelected)
            Icon(
              Icons.check_circle,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    );
  }
}
