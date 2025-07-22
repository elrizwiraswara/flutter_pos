import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

import '../../utilities/console_log.dart';

class ConnectivityService {
  /// Make [ConnectivityService] to be singleton
  static final ConnectivityService _instance = ConnectivityService._();

  factory ConnectivityService() => _instance;

  ConnectivityService._();

  static Connectivity connectivity = Connectivity();

  static http.Client client = http.Client();

  static String host = 'google.com';

  static bool _isConnected = true;
  static bool get isConnected => _isConnected;

  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  static void initNetworkChecker({Function(bool)? onHasInternet}) {
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
        _isConnected = false;
      }

      if (onHasInternet != null) {
        onHasInternet(_isConnected);
      }

      cl('[ConnectivityService].isConnected = $_isConnected ');
    });
  }

  static Future<void> _checkInternetConnection() async {
    var response = await client.get(Uri.http(host));

    if (response.statusCode == 200) {
      _isConnected = true;
    } else {
      _isConnected = false;
    }
  }

  static void cancelSubs() {
    _subscription?.cancel();
    _subscription = null;
  }

  // Only for testing
  // Bypass connection status using this func
  static void setTestIsConnected(bool value) {
    // Ensure this func only can be run in debug mode and completely removed in release mode
    assert(
      () {
        _isConnected = value;
        return true;
      }(),
      "[ConnectivityService].setTestIsConnected should only be used in unit tests.",
    );
  }
}
