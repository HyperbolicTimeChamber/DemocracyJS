import 'package:democracy_js/core/enums/server_status.dart';
import 'package:democracy_js/features/poll/domain/entities/web_socket_event.dart';

abstract class LocalServer {
  Future<void> start({required int port});
  Future<void> stop();
  ServerStatus get status;
  Stream<ServerStatus> get statusStream;
  Stream<WebSocketEvent> get eventStream;
}
