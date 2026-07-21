import 'dart:convert';
import 'package:shelf/shelf.dart' show Handler;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:local_poll/core/enums/event_type.dart';
import 'package:local_poll/features/poll/domain/entities/web_socket_event.dart';

class WebSocketHandler {
  final _clients = <WebSocketChannel>[];
  final void Function(int count)? onClientCountChanged;

  WebSocketHandler({this.onClientCountChanged});

  int get clientCount => _clients.length;

  Handler get handler => webSocketHandler((WebSocketChannel channel) {
        _clients.add(channel);
        onClientCountChanged?.call(_clients.length);

        channel.stream.listen(
          (_) {},
          onDone: () {
            _clients.remove(channel);
            onClientCountChanged?.call(_clients.length);
          },
          onError: (_) {
            _clients.remove(channel);
            onClientCountChanged?.call(_clients.length);
          },
        );
      });

  void broadcast(WebSocketEvent event) {
    final message = jsonEncode({
      'type': event.type.toJson(),
      'data': event.data,
    });

    final closedClients = <WebSocketChannel>[];
    for (final client in _clients) {
      try {
        client.sink.add(message);
      } catch (_) {
        closedClients.add(client);
      }
    }
    for (final client in closedClients) {
      _clients.remove(client);
    }
    if (closedClients.isNotEmpty) {
      onClientCountChanged?.call(_clients.length);
    }
  }

  void closeAll() {
    for (final client in _clients) {
      try {
        client.sink.close();
      } catch (_) {}
    }
    _clients.clear();
    onClientCountChanged?.call(0);
  }
}
