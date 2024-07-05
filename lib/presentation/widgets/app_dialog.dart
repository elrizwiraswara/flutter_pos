import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos/app/routes/app_routes.dart';
import 'package:flutter_pos/app/themes/app_sizes.dart';
import 'package:flutter_pos/presentation/widgets/app_progress_indicator.dart';

import 'app_button.dart';

class AppDialog {
  static Future<dynamic> show({
    String? title,
    Widget? child,
    String? text,
    EdgeInsets? padding,
    String? leftButtonText,
    String? rightButtonText,
    Function()? onTapLeftButton,
    Function()? onTapRightButton,
    bool? dismissible,
    bool? showButtons,
    bool? enableRightButton,
    bool? enableLeftButton,
    double? elevation,
  }) async {
    return await showDialog(
      context: AppRoutes.router.configuration.navigatorKey.currentContext!,
      barrierDismissible: dismissible ?? true,
      builder: (context) {
        return PopScope(
          canPop: dismissible ?? true,
          child: AppDialogWidget(
            title: title,
            text: text,
            padding: padding,
            rightButtonText: rightButtonText,
            leftButtonText: leftButtonText,
            onTapLeftButton: onTapLeftButton,
            onTapRightButton: onTapRightButton,
            dismissible: dismissible ?? true,
            enableRightButton: enableRightButton ?? true,
            enableLeftButton: enableLeftButton ?? true,
            elevation: elevation,
            child: child,
          ),
        );
      },
    );
  }

  static Future<void> showErrorDialog({
    String? title,
    String? message,
    String? error,
    String buttonText = 'Close',
    Function()? onTapButton,
  }) async {
    return await showDialog(
      context: AppRoutes.router.configuration.navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AppDialogWidget(
            title: title ?? 'Oops!',
            leftButtonText: buttonText,
            onTapLeftButton: onTapButton,
            child: Column(
              children: [
                Text(
                  message ?? 'Something went wrong, please contact your system administrator or try restart the app',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.padding),
                    child: Text(
                      error.toString().length > 35 ? error.toString().substring(0, 35) : error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> showDialogProgress({
    bool dismissible = false,
  }) async {
    showDialog(
      context: AppRoutes.router.configuration.navigatorKey.currentContext!,
      builder: (context) {
        return AppDialogWidget(
          dismissible: kDebugMode ? true : dismissible,
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: const AppProgressIndicator(),
        );
      },
    );
  }

  static void closeDialog() {
    AppRoutes.router.pop();
  }
}

// Default Dialog
class AppDialogWidget extends StatelessWidget {
  final String? title;
  final Widget? child;
  final String? text;
  final EdgeInsets? padding;
  final String? leftButtonText;
  final String? rightButtonText;
  final bool dismissible;
  final bool enableRightButton;
  final bool enableLeftButton;
  final double? elevation;
  final Color? backgroundColor;
  final Function()? onTapLeftButton;
  final Function()? onTapRightButton;

  const AppDialogWidget({
    super.key,
    this.title,
    this.child,
    this.text,
    this.padding,
    this.rightButtonText,
    this.leftButtonText,
    this.onTapLeftButton,
    this.onTapRightButton,
    this.dismissible = true,
    this.enableRightButton = true,
    this.enableLeftButton = true,
    this.elevation,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: dismissible,
      child: Dialog(
        elevation: elevation,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 512),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                dialogTitle(context),
                dialogBody(context),
                dialogButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dialogTitle(BuildContext context) {
    return title != null
        ? Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            child: Text(
              title!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          )
        : const SizedBox.shrink();
  }

  Widget dialogBody(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSizes.padding),
      alignment: Alignment.center,
      child: text != null
          ? Text(
              text!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            )
          : child ?? const SizedBox.shrink(),
    );
  }

  Widget dialogButtons(BuildContext context) {
    return leftButtonText == null && rightButtonText == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: <Widget>[
                leftButtonText != null
                    ? Expanded(
                        child: AppButton(
                          text: leftButtonText!,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.padding,
                            horizontal: AppSizes.padding / 2,
                          ),
                          onTap: () async {
                            if (enableLeftButton) {
                              if (onTapLeftButton != null) {
                                onTapLeftButton!();
                              } else {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
                leftButtonText != null && rightButtonText != null
                    ? Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        height: 18,
                        width: 1,
                        color: Theme.of(context).colorScheme.outline,
                      )
                    : const SizedBox.shrink(),
                rightButtonText != null
                    ? Expanded(
                        child: AppButton(
                          text: rightButtonText!,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.padding,
                            horizontal: AppSizes.padding / 2,
                          ),
                          onTap: () async {
                            if (enableRightButton) {
                              if (onTapRightButton != null) {
                                onTapRightButton!();
                              } else {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                        ),
                      )
                    : const SizedBox.shrink()
              ],
            ),
          );
  }
}
