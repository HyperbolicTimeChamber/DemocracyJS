import 'package:democracy_js/core/utils/network_utils.dart';

class NetworkService {
  Future<String?> getLocalIp() => NetworkUtils.getLocalIpAddress();
}
