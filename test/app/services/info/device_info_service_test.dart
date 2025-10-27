import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_pos/app/services/info/device_info_service.dart';
import 'package:flutter_pos/app/utilities/platform_wrapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'device_info_service_test.mocks.dart';

@GenerateMocks([DeviceInfoPlugin, AndroidDeviceInfo, IosDeviceInfo, PlatformWrapper])
void main() {
  late MockDeviceInfoPlugin mockDeviceInfo;
  late MockAndroidDeviceInfo mockAndroidInfo;
  late MockIosDeviceInfo mockIosInfo;
  late MockPlatformWrapper mockPlatform;

  setUp(() {
    mockDeviceInfo = MockDeviceInfoPlugin();
    mockAndroidInfo = MockAndroidDeviceInfo();
    mockIosInfo = MockIosDeviceInfo();
    mockPlatform = MockPlatformWrapper();
  });

  group('DeviceInfoService - Android', () {
    test('should detect physical Android device', () async {
      // Arrange
      when(mockPlatform.isAndroid).thenReturn(true);
      when(mockPlatform.isIOS).thenReturn(false);
      when(mockAndroidInfo.isPhysicalDevice).thenReturn(true);
      when(mockDeviceInfo.androidInfo).thenAnswer((_) async => mockAndroidInfo);

      // Act
      final service = DeviceInfoService(mockDeviceInfo, platform: mockPlatform);
      final isPhysicalDevice = await service.checkDeviceType();

      // Assert
      expect(isPhysicalDevice, true);
      verify(mockDeviceInfo.androidInfo).called(1);
      verify(mockPlatform.isAndroid).called(1);
    });

    test('should detect Android emulator', () async {
      // Arrange
      when(mockPlatform.isAndroid).thenReturn(true);
      when(mockPlatform.isIOS).thenReturn(false);
      when(mockAndroidInfo.isPhysicalDevice).thenReturn(false);
      when(mockDeviceInfo.androidInfo).thenAnswer((_) async => mockAndroidInfo);

      // Act
      final service = DeviceInfoService(mockDeviceInfo, platform: mockPlatform);
      final isPhysicalDevice = await service.checkDeviceType();

      // Assert
      expect(isPhysicalDevice, false);
      verify(mockDeviceInfo.androidInfo).called(1);
    });

    test('should not call iosInfo on Android', () async {
      // Arrange
      when(mockPlatform.isAndroid).thenReturn(true);
      when(mockPlatform.isIOS).thenReturn(false);
      when(mockAndroidInfo.isPhysicalDevice).thenReturn(true);
      when(mockDeviceInfo.androidInfo).thenAnswer((_) async => mockAndroidInfo);

      // Act
      final service = DeviceInfoService(mockDeviceInfo, platform: mockPlatform);
      await service.checkDeviceType();

      // Assert
      verifyNever(mockDeviceInfo.iosInfo);
    });
  });

  group('DeviceInfoService - iOS', () {
    test('should detect physical iOS device', () async {
      // Arrange
      when(mockPlatform.isAndroid).thenReturn(false);
      when(mockPlatform.isIOS).thenReturn(true);
      when(mockIosInfo.isPhysicalDevice).thenReturn(true);
      when(mockDeviceInfo.iosInfo).thenAnswer((_) async => mockIosInfo);

      // Act
      final service = DeviceInfoService(mockDeviceInfo, platform: mockPlatform);
      final isPhysicalDevice = await service.checkDeviceType();

      // Assert
      expect(isPhysicalDevice, true);
      verify(mockDeviceInfo.iosInfo).called(1);
      verify(mockPlatform.isIOS).called(1);
    });

    test('should detect iOS simulator', () async {
      // Arrange
      when(mockPlatform.isAndroid).thenReturn(false);
      when(mockPlatform.isIOS).thenReturn(true);
      when(mockIosInfo.isPhysicalDevice).thenReturn(false);
      when(mockDeviceInfo.iosInfo).thenAnswer((_) async => mockIosInfo);

      // Act
      final service = DeviceInfoService(mockDeviceInfo, platform: mockPlatform);
      final isPhysicalDevice = await service.checkDeviceType();

      // Assert
      expect(isPhysicalDevice, false);
      verify(mockDeviceInfo.iosInfo).called(1);
    });

    test('should not call androidInfo on iOS', () async {
      // Arrange
      when(mockPlatform.isAndroid).thenReturn(false);
      when(mockPlatform.isIOS).thenReturn(true);
      when(mockIosInfo.isPhysicalDevice).thenReturn(true);
      when(mockDeviceInfo.iosInfo).thenAnswer((_) async => mockIosInfo);

      // Act
      final service = DeviceInfoService(mockDeviceInfo, platform: mockPlatform);
      await service.checkDeviceType();

      // Assert
      verifyNever(mockDeviceInfo.androidInfo);
    });
  });

  group('DeviceInfoService - Edge Cases', () {
    test('should maintain default value on unsupported platform', () async {
      // Arrange
      when(mockPlatform.isAndroid).thenReturn(false);
      when(mockPlatform.isIOS).thenReturn(false);

      // Act
      final service = DeviceInfoService(mockDeviceInfo, platform: mockPlatform);
      final isPhysicalDevice = await service.checkDeviceType();

      // Assert
      expect(isPhysicalDevice, true); // Default value
      verifyNever(mockDeviceInfo.androidInfo);
      verifyNever(mockDeviceInfo.iosInfo);
    });

    test('should use default PlatformWrapper when not provided', () {
      // Act
      final service = DeviceInfoService(mockDeviceInfo);

      // Assert
      expect(service, isNotNull);
      // This test verifies the service can be instantiated without platform param
    });
  });
}
