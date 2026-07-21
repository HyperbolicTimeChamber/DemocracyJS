import 'package:bonsoir/bonsoir.dart';
import 'package:local_poll/core/constants/app_constants.dart';

class MdnsService {
  BonsoirBroadcast? _broadcast;

  Future<void> register({required String name, required int port}) async {
    final service = BonsoirService(
      name: name,
      type: AppConstants.mDnsServiceType,
      port: port,
    );
    _broadcast = BonsoirBroadcast(service: service);
    await _broadcast!.ready;
    await _broadcast!.start();
  }

  Future<void> unregister() async {
    await _broadcast?.stop();
    _broadcast = null;
  }
}
