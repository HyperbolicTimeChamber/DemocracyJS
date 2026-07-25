import 'package:democracy_js/features/hosting/domain/services/local_server.dart';

class StartServer {
  Future<void> call({required LocalServer server, required int port}) async {
    await server.start(port: port);
  }
}
