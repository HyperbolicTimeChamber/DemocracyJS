import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:local_poll/core/enums/event_type.dart';
import 'package:local_poll/core/enums/server_status.dart';
import 'package:local_poll/features/hosting/data/server/api_handler.dart';
import 'package:local_poll/features/hosting/data/server/websocket_handler.dart';
import 'package:local_poll/features/hosting/domain/services/local_server.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/web_socket_event.dart';

class ShelfLocalServer implements LocalServer {
  ShelfLocalServer({
    required this.getPoll,
    required this.onVote,
    required this.onClientCountChanged,
  });

  final Poll Function() getPoll;
  final Future<bool> Function(List<String> optionIds, String ip) onVote;
  final void Function(int count) onClientCountChanged;

  HttpServer? _server;
  ServerStatus _status = ServerStatus.stopped;
  final _statusController = StreamController<ServerStatus>.broadcast();
  final _eventController = StreamController<WebSocketEvent>.broadcast();
  late WebSocketHandler _wsHandler;

  // Cached browser client assets (may be null if assets not yet bundled)
  String? _indexHtml;
  String? _styleCss;
  String? _appJs;

  @override
  ServerStatus get status => _status;

  @override
  Stream<ServerStatus> get statusStream => _statusController.stream;

  @override
  Stream<WebSocketEvent> get eventStream => _eventController.stream;

  WebSocketHandler get wsHandler => _wsHandler;

  void _setStatus(ServerStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  Future<void> _loadAssets() async {
    try {
      _indexHtml =
          await rootBundle.loadString('assets/browser_client/index.html');
      _styleCss =
          await rootBundle.loadString('assets/browser_client/style.css');
      _appJs = await rootBundle.loadString('assets/browser_client/app.js');
    } catch (_) {
      // Asset files not yet available (Task 8). Serve placeholder content.
      _indexHtml = '<!DOCTYPE html><html><body><p>Loading...</p></body></html>';
      _styleCss = '';
      _appJs = '';
    }
  }

  @override
  Future<void> start({required int port}) async {
    if (_status == ServerStatus.running) return;
    _setStatus(ServerStatus.starting);

    try {
      await _loadAssets();

      _wsHandler = WebSocketHandler(
        onClientCountChanged: (count) {
          onClientCountChanged(count);
          _eventController.add(WebSocketEvent(
            type: EventType.userJoined,
            data: {'clientCount': count},
          ));
        },
      );

      final apiHandler = ApiHandler(
        getPoll: getPoll,
        onVote: onVote,
        getClientCount: () => _wsHandler.clientCount,
      );

      final router = Router();

      // Static files
      router.get('/', (shelf.Request req) => shelf.Response.ok(
            _indexHtml,
            headers: {'content-type': 'text/html'},
          ));
      router.get('/style.css', (shelf.Request req) => shelf.Response.ok(
            _styleCss,
            headers: {'content-type': 'text/css'},
          ));
      router.get('/app.js', (shelf.Request req) => shelf.Response.ok(
            _appJs,
            headers: {'content-type': 'application/javascript'},
          ));

      // WebSocket
      router.get('/ws', _wsHandler.handler);

      // API routes — mount at root so ApiHandler owns the /api/ prefix
      router.mount('/', apiHandler.router.call);

      // CORS preflight
      router.options(
        '/<ignored|.*>',
        (shelf.Request req) => shelf.Response.ok('', headers: {
          'access-control-allow-origin': '*',
          'access-control-allow-methods': 'GET, POST, OPTIONS',
          'access-control-allow-headers': 'content-type',
        }),
      );

      final handler = const shelf.Pipeline()
          .addMiddleware(shelf.logRequests())
          .addHandler(router.call);

      _server =
          await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
      _setStatus(ServerStatus.running);
    } catch (e) {
      _setStatus(ServerStatus.failed);
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    if (_status == ServerStatus.stopped) return;
    _wsHandler.closeAll();
    await _server?.close(force: true);
    _server = null;
    _setStatus(ServerStatus.stopped);
  }

  void broadcastEvent(WebSocketEvent event) {
    _wsHandler.broadcast(event);
    _eventController.add(event);
  }
}
