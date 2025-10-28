import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../utilities/console_logger.dart';

class PingService {
  Process? _process;

  late String _host;
  late int? _count;
  late int _interval;
  late int _maxPingLatencyTolerance;
  late int _pingLatencyToleranceCount;
  late int _maxLines;

  bool _isProcessStarted = false;

  final List<int> _pingLatencies = [];
  final List<String> _pingLines = [];

  final List<Function(List<int> latencies, List<String> lines)> _listeners = [];
  final List<Function(bool isConnected)> _connectionStatusListeners = [];

  bool _previousStatus = false;

  bool get isConnected {
    if (_pingLatencies.isEmpty) {
      return false; // No latencies to check, assume not connected
    }

    if (_pingLatencies.length < _pingLatencyToleranceCount) {
      // If fewer than [_pingLatencyToleranceCount] latencies, check the last one
      final lastLatency = _pingLatencies.last;
      return lastLatency != -1 && lastLatency <= _maxPingLatencyTolerance;
    }

    // Check the last [_pingLatencyToleranceCount] latencies
    final lastLatencies = _pingLatencies.sublist(
      _pingLatencies.length - _pingLatencyToleranceCount,
    );

    final hasBadLatency = lastLatencies.every(
      (latency) => latency == -1 || latency > _maxPingLatencyTolerance,
    );

    return !hasBadLatency;
  }

  Future<void> startPing({
    String host = '8.8.8.8',
    int? count,
    int interval = 1,
    int maxPingLatencyTolerance = 400,
    int pingLatencyToleranceCount = 3,
    int maxLines = 100,
  }) async {
    _host = host;
    _count = count;
    _interval = interval;
    _maxPingLatencyTolerance = maxPingLatencyTolerance;
    _pingLatencyToleranceCount = count != null && count < pingLatencyToleranceCount ? count : pingLatencyToleranceCount;
    _maxLines = maxLines;

    if (_process != null) return;
    if (_isProcessStarted) return;

    _runPingProcess();
  }

  Future<void> _runPingProcess() async {
    _isProcessStarted = true;

    try {
      _process = await Process.start(
        'ping',
        [..._arguments, _host],
        environment: {'LANG': 'en_US'},
      );

      _process?.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen(_pingListener);

      _process?.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen(_pingListener);

      int? exitCode = await _process?.exitCode;
      cl('Ping process stopped. exitCode: $exitCode');
    } catch (e) {
      throw Exception('Error starting ping process: $e');
    } finally {
      // Always cleanup, whether success or error
      _process = null;
      _isProcessStarted = false;
    }
  }

  void _pingListener(String line) {
    // Parse output data
    PingData data = parsePingLine(line);

    if (_pingLines.length > _maxLines) {
      _pingLines.removeAt(0);
    }

    if (_pingLatencies.length > _maxLines) {
      _pingLatencies.removeAt(0);
    }

    _pingLines.add(line);

    if (data.response != null || data.error != null) {
      _pingLatencies.add(data.response?.time?.inMilliseconds ?? -1);
    }

    // Check if the status has changed
    if (_previousStatus != isConnected) {
      _previousStatus = isConnected;
      cl("[PingService].isConnected: $isConnected");
      // Notify connection status listeners
      for (var e in _connectionStatusListeners) {
        e.call(isConnected);
      }
    }

    _notifyListeners();
  }

  // Register a listener
  void addListener(Function(List<int> latencies, List<String> lines) listener) {
    if (_listeners.contains(listener)) return;
    _listeners.add(listener);
    listener(_pingLatencies, _pingLines);
  }

  // Unregister the listener
  void removeListener(Function(List<int> latencies, List<String> lines) listener) {
    _listeners.remove(listener);
  }

  // Unregister all listeners
  void clearListeners() {
    _listeners.clear();
  }

  // Notify the listener with the latest data
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener(_pingLatencies, _pingLines);
    }
  }

  // Register a connection status listener
  void addConnectionStatusListener(Function(bool isConnected) listener) {
    if (_connectionStatusListeners.contains(listener)) return;
    _connectionStatusListeners.add(listener);
    listener(isConnected);
  }

  // Unregister the connection status listener
  void removeConnectionStatusListener(Function(bool isConnected) listener) {
    _connectionStatusListeners.remove(listener);
  }

  // Unregister all connection status listeners
  void clearConnectionStatusListeners() {
    _connectionStatusListeners.clear();
  }

  // Force stop ping process
  void stopPing() {
    _process?.kill(ProcessSignal.sigint);
    _process = null;
    _isProcessStarted = false;
  }

  PingData parsePingLine(String line) {
    final windowsResponseRgx = RegExp(
      r'Reply from (?<ip>[\d\.]+): bytes=(?<bytes>\d+) time[=<](?<time>\d+)ms TTL=(?<ttl>\d+)',
    );
    final linuxBasedResponseRgx = RegExp(
      r'^(\d+)\s+bytes\s+from\s+([0-9.]+):\s+icmp_seq=(\d+)\s+ttl=(\d+)\s+time[=<]([0-9.]+)\s+ms$',
    );
    final errorRgx = RegExp(
      r'expired|exceeded|no answer|no reply|timed out|could not|failure|unreachable|unknown|not known|timeout',
      caseSensitive: false,
    );

    final response = Platform.isWindows ? windowsResponseRgx.firstMatch(line) : linuxBasedResponseRgx.firstMatch(line);
    if (response != null) {
      String ip;
      String bytes;
      String time;
      String ttl;

      if (Platform.isWindows) {
        ip = response.namedGroup('ip')!;
        bytes = response.namedGroup('bytes')!;
        time = response.namedGroup('time')!;
        ttl = response.namedGroup('ttl')!;
      } else {
        // Linux response regex does not use named groups, so use indices
        bytes = response.group(1)!;
        ip = response.group(2)!;
        ttl = response.group(4)!;
        time = response.group(5)!;
      }

      final res = PingResponse(
        ip: ip,
        bytes: int.tryParse(bytes) ?? 0,
        time: Duration(milliseconds: (double.tryParse(time) ?? 0).round()),
        ttl: int.tryParse(ttl) ?? 0,
      );

      return PingData(response: res);
    }

    final error = errorRgx.firstMatch(line);
    if (error != null) {
      return PingData(error: line);
    }

    // Return empty for other
    return PingData();
  }

  // Command arguments
  // Based on supported platform ping command argument
  // On Windows, use '-4' flag to use ipv4 addresses, '-6' for ipv6 addresses
  // On Android/Linux based platform, use 'ping' to use ipv4 addresses, 'ping6' for ipv6 addresses
  List<String> get _arguments {
    if (Platform.isAndroid || Platform.isMacOS || Platform.isLinux) {
      final args = ['-i', '$_interval'];

      if (_count != null) {
        args.addAll(['-c', '$_count']);
      }

      return args;
    }

    if (Platform.isWindows) {
      final args = ['-4'];

      if (_count != null) {
        args.addAll(['-n', '$_count']);
      }

      return args;
    }

    return [];
  }

  // Dispose and cleanup everything
  void dispose() {
    stopPing();
    clearListeners();
    clearConnectionStatusListeners();
    _pingLatencies.clear();
    _pingLines.clear();
    _previousStatus = false;
  }
}

class PingData {
  final PingResponse? response;
  final String? error;

  PingData({
    this.response,
    this.error,
  });
}

class PingResponse {
  final String? ip;
  final int? bytes;
  final Duration? time;
  final int? ttl;

  PingResponse({
    this.ip,
    this.bytes,
    this.time,
    this.ttl,
  });
}
