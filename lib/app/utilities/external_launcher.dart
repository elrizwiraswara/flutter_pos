import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

// External launcher
class ExternalLauncher {
  ExternalLauncher._();

  static void openUrl(String url) async {
    Uri uri;

    if (!url.contains("http")) {
      uri = Uri.parse("http://$url");
    } else {
      uri = Uri.parse(url);
    }

    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  static void openWhatsApp({
    required String phone,
    required String message,
  }) async {
    var androidUrl = "whatsapp://send?phone=$phone&text=$message";
    var iosUrl = "https://wa.me/$phone?text=${Uri.parse(message)}";

    try {
      if (Platform.isIOS) {
        await launchUrl(Uri.parse(iosUrl));
      } else {
        await launchUrl(Uri.parse(androidUrl));
      }
    } on Exception {
      throw Exception('WhatsApp is not installed.');
    }
  }

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    if (!await launchUrl(Uri.parse(googleUrl))) {
      throw Exception('Could open map url $googleUrl');
    }
  }
}
