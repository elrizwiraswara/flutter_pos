import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../../utilities/console_log.dart';

// Network Checker Service
// v.4.0.0
// by Elriz Wiraswara

class ConnectivityService {
  /// Make [ConnectivityService] to be singleton
  static final ConnectivityService _instance = ConnectivityService._();

  factory ConnectivityService() => _instance;

  ConnectivityService._();

  static Connectivity connectivity = Connectivity();

  static http.Client client = http.Client();

  static String host = 'google.com';

  static bool isConnected = false;

  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  static Future<void> initNetworkChecker({Function(bool)? onHasInternet}) async {
    if (_subscription != null) cancelSubs();

    _subscription = connectivity.onConnectivityChanged.listen((results) async {
      var internetConnectivityList = [
        ConnectivityResult.mobile,
        ConnectivityResult.wifi,
        ConnectivityResult.ethernet,
        ConnectivityResult.vpn,
      ];

      if (results.every((e) => internetConnectivityList.contains(e))) {
        await _checkInternetConnection();
      } else {
        isConnected = false;
      }

      if (onHasInternet != null) {
        onHasInternet(isConnected);
      }

      cl('[NetworkCheckerService].isConnected = $isConnected ');
    });
  }

  static Future<void> _checkInternetConnection() async {
    var response = await client.get(Uri.http(host));

    if (response.statusCode == 200) {
      isConnected = true;
    } else {
      isConnected = false;
    }
  }

  static void cancelSubs() {
    _subscription?.cancel();
    _subscription = null;
  }
}
