import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_pos/app/services/connectivity/connectivity_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'connectivity_service_test.mocks.dart';

// Define the classes that you want to mock
@GenerateMocks([Connectivity, http.Client])
void main() {
  // Declaring the mock objects
  late MockConnectivity mockConnectivity;
  late MockClient mockClient;

  // Grouping the tests related to ConnectivityService
  group('$ConnectivityService', () {
    // Setting up the mock objects before all tests
    setUp(() async {
      mockConnectivity = MockConnectivity();
      mockClient = MockClient();

      // Assigning the mock objects to the ConnectivityService
      ConnectivityService.connectivity = mockConnectivity;
      ConnectivityService.client = mockClient;
    });

    // Grouping the tests related to instance creation
    group('instance', () {
      // Testing if mockConnectivity returns an instance of Connectivity
      test('mockConnectivity should returns an instance', () async {
        expect(mockConnectivity, isA<Connectivity>());
      });
      // Testing if mockClient returns an instance of HttpClient
      test('mockClient should returns an instance', () async {
        expect(mockClient, isA<http.Client>());
      });
    });

    // Grouping the tests related to the initialization of NetworkChecker
    group('initNetworkChecker', () {
      // Setting up the mock responses for the methods
      setUpAll(() {
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => Stream<List<ConnectivityResult>>.value([ConnectivityResult.mobile]));
        when(mockClient.get(any)).thenAnswer((_) async => http.Response('', 200));
        ConnectivityService.initNetworkChecker();
      });

      // Testing if ConnectivityService.isConnected returns true
      test('Call ConnectivityService.isConnected after init and should return true', () async {
        expect(ConnectivityService.isConnected, true);
      });
    });

    // Grouping the tests related to NetworkChecker errors
    group('NetworkCheker Error Tests', () {
      // Setting up the mock responses for the methods
      setUpAll(() {
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => Stream<List<ConnectivityResult>>.value([ConnectivityResult.mobile]));
        when(mockClient.get(any)).thenAnswer((_) async => http.Response('', 201));
        ConnectivityService.initNetworkChecker();
      });

      // Testing if ConnectivityService.isConnected returns false
      test('Call ConnectivityService.isConnected after init and should return false', () async {
        expect(ConnectivityService.isConnected, false);
      });
    });
  });
}
