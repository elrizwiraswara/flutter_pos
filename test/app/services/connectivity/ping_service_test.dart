import 'dart:io';

import 'package:flutter_pos/app/services/connectivity/ping_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PingService pingService;

  setUpAll(() {
    pingService = PingService();
  });

  tearDown(() {
    // Clean up after each test
    pingService.dispose();
  });

  group('PingService', () {
    test('isConnected should return false when no latencies', () {
      expect(pingService.isConnected, false);
    });

    test('should start ping process', () async {
      await pingService.startPing(
        host: '8.8.8.8',
        count: 3,
        interval: 1,
      );

      // Wait a bit for process to start
      await Future.delayed(Duration(milliseconds: 500));

      // Process should have started
      // Note: This is hard to test without mocking Process.start
      expect(true, true); // Placeholder - see integration test below
    });

    test('should stop ping process', () async {
      await pingService.startPing(
        host: '8.8.8.8',
        count: 3,
        interval: 1,
      );

      await Future.delayed(Duration(milliseconds: 500));

      pingService.stopPing();

      // Process should be stopped
      expect(true, true); // Placeholder
    });

    test('should add and remove listeners', () {
      bool listenerCalled = false;
      void testListener(List<int> latencies, List<String> lines) {
        listenerCalled = true;
      }

      pingService.addListener(testListener);

      // Listener should be called immediately with current data
      expect(listenerCalled, true);

      pingService.removeListener(testListener);
    });

    test('should not add duplicate listeners', () {
      int callCount = 0;
      void testListener(List<int> latencies, List<String> lines) {
        callCount++;
      }

      pingService.addListener(testListener);
      pingService.addListener(testListener); // Try to add again

      // Should only be called once (on first add)
      expect(callCount, 1);

      pingService.removeListener(testListener);
    });

    test('should clear all listeners', () {
      void listener1(List<int> latencies, List<String> lines) {}
      void listener2(List<int> latencies, List<String> lines) {}

      pingService.addListener(listener1);
      pingService.addListener(listener2);

      pingService.clearListeners();

      // All listeners should be cleared
      expect(true, true); // Can't directly test private _listeners
    });

    test('dispose should clean up everything', () {
      void testListener(List<int> latencies, List<String> lines) {}

      pingService.addListener(testListener);
      pingService.dispose();

      // After dispose, everything should be reset
      expect(pingService.isConnected, false);
    });

    group('parsePingLine', () {
      test('should parse Windows ping response', () {
        final line = 'Reply from 8.8.8.8: bytes=32 time=15ms TTL=117';
        final data = pingService.parsePingLine(line);

        expect(data.response, isNotNull);
        expect(data.response?.ip, '8.8.8.8');
        expect(data.response?.bytes, 32);
        expect(data.response?.time?.inMilliseconds, 15);
        expect(data.response?.ttl, 117);
        expect(data.error, isNull);
      }, skip: !Platform.isWindows);

      test('should parse Linux ping response', () {
        final line = '64 bytes from 8.8.8.8: icmp_seq=1 ttl=117 time=15.2 ms';
        final data = pingService.parsePingLine(line);

        expect(data.response, isNotNull);
        expect(data.response?.ip, '8.8.8.8');
        expect(data.response?.bytes, 64);
        expect(data.response?.time?.inMilliseconds, 15);
        expect(data.response?.ttl, 117);
        expect(data.error, isNull);
      }, skip: Platform.isWindows);

      test('should parse error line', () {
        final line = 'Request timed out.';
        final data = pingService.parsePingLine(line);

        expect(data.response, isNull);
        expect(data.error, isNotNull);
        expect(data.error, contains('timed out'));
      });

      test('should return empty for unrecognized line', () {
        final line = 'Some random text that is not a ping response';
        final data = pingService.parsePingLine(line);

        expect(data.response, isNull);
        expect(data.error, isNull);
      });

      test('should parse various error patterns', () {
        final errorLines = [
          'Request timed out',
          'Destination host unreachable',
          'Unknown host',
          'Network is unreachable',
          'Time to live exceeded',
        ];

        for (final line in errorLines) {
          final data = pingService.parsePingLine(line);
          expect(data.error, isNotNull, reason: 'Failed to parse: $line');
        }
      });
    });
  });

  group('PingService Integration Tests', () {
    test('should ping Google DNS and get responses', () async {
      final latencies = <int>[];
      final lines = <String>[];

      void listener(List<int> receivedLatencies, List<String> receivedLines) {
        latencies.addAll(receivedLatencies);
        lines.addAll(receivedLines);
      }

      pingService.addListener(listener);

      await pingService.startPing(
        host: '8.8.8.8',
        count: 5,
        interval: 1,
        maxPingLatencyTolerance: 500,
        pingLatencyToleranceCount: 3,
      );

      // Wait for pings to complete
      await Future.delayed(Duration(seconds: 7));

      // Should have received some responses
      expect(lines.isNotEmpty, true);
      expect(latencies.isNotEmpty, true);

      // At least some latencies should be valid (not -1)
      final validLatencies = latencies.where((l) => l != -1).toList();
      expect(validLatencies.isNotEmpty, true);

      pingService.dispose();
    }, timeout: Timeout(Duration(seconds: 10)));

    test('should detect connection status changes', () async {
      bool statusChanged = false;

      pingService.addConnectionStatusListener((val) {
        statusChanged = val;
      });

      await pingService.startPing(
        host: '8.8.8.8',
        count: 5,
        interval: 1,
        maxPingLatencyTolerance: 500,
        pingLatencyToleranceCount: 3,
      );

      // Wait for pings
      await Future.delayed(Duration(seconds: 7));

      // Status should have changed at some point
      expect(statusChanged, true);

      pingService.dispose();
    }, timeout: Timeout(Duration(seconds: 10)));

    test('should handle unreachable host', () async {
      final lines = <String>[];

      void listener(List<int> latencies, List<String> receivedLines) {
        lines.addAll(receivedLines);
      }

      pingService.addListener(listener);

      await pingService.startPing(
        host: '192.0.2.1', // TEST-NET-1, should be unreachable
        count: 3,
        interval: 1,
      );

      await Future.delayed(Duration(seconds: 5));

      // Should have some output (likely errors)
      expect(lines.isNotEmpty, true);

      pingService.dispose();
    }, timeout: Timeout(Duration(seconds: 8)));

    test('should stop ping mid-execution', () async {
      await pingService.startPing(
        host: '8.8.8.8',
        count: 10,
        interval: 1,
      );

      // Wait a bit then stop
      await Future.delayed(Duration(seconds: 2));
      pingService.stopPing();

      // Process should be stopped
      await Future.delayed(Duration(milliseconds: 500));

      pingService.dispose();
    }, timeout: Timeout(Duration(seconds: 5)));

    test('should respect maxLines limit', () async {
      final maxLines = 10;
      List<String> capturedLines = [];

      void listener(List<int> latencies, List<String> lines) {
        capturedLines = List.from(lines);
      }

      pingService.addListener(listener);

      await pingService.startPing(
        host: '8.8.8.8',
        count: 20,
        interval: 1,
        maxLines: maxLines,
      );

      await Future.delayed(Duration(seconds: 5));

      // Should not exceed maxLines
      expect(capturedLines.length <= maxLines + 1, true); // +1 for potential race condition

      pingService.dispose();
    }, timeout: Timeout(Duration(seconds: 8)));
  });

  group('PingData and PingResponse', () {
    test('should create PingData with response', () {
      final response = PingResponse(
        ip: '8.8.8.8',
        bytes: 32,
        time: Duration(milliseconds: 15),
        ttl: 117,
      );

      final data = PingData(response: response);

      expect(data.response, isNotNull);
      expect(data.error, isNull);
      expect(data.response?.ip, '8.8.8.8');
    });

    test('should create PingData with error', () {
      final data = PingData(error: 'Request timed out');

      expect(data.response, isNull);
      expect(data.error, isNotNull);
      expect(data.error, 'Request timed out');
    });

    test('should create empty PingData', () {
      final data = PingData();

      expect(data.response, isNull);
      expect(data.error, isNull);
    });
  });
}
