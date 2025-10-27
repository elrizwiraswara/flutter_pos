import 'package:device_info_plus/device_info_plus.dart';

import '../../utilities/platform_wrapper.dart';

class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfo;
  final PlatformWrapper _platform;

  DeviceInfoService(
    this._deviceInfo, {
    PlatformWrapper? platform,
  }) : _platform = platform ?? PlatformWrapper();

  Future<bool> checkDeviceType() async {
    if (_platform.isAndroid) {
      return (await _deviceInfo.androidInfo).isPhysicalDevice;
    } else if (_platform.isIOS) {
      return (await _deviceInfo.iosInfo).isPhysicalDevice;
    }

    return true;
  }
}
