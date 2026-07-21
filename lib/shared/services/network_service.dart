import 'package:local_poll/core/utils/network_utils.dart';

class NetworkService {
  Future<String?> getLocalIp() => NetworkUtils.getLocalIpAddress();
}
