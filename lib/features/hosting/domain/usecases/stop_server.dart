import 'package:local_poll/features/hosting/domain/services/local_server.dart';

class StopServer {
  Future<void> call({required LocalServer server}) async {
    await server.stop();
  }
}
