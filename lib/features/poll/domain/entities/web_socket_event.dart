import 'package:local_poll/core/enums/event_type.dart';

class WebSocketEvent {
  const WebSocketEvent({required this.type, required this.data});

  final EventType type;
  final Map<String, dynamic> data;
}
