import 'package:network_info_plus/network_info_plus.dart';

abstract class NetworkUtils {
  static final NetworkInfo _networkInfo = NetworkInfo();

  static Future<String?> getLocalIpAddress() async {
    return await _networkInfo.getWifiIP();
  }
}
