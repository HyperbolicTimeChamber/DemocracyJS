import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_poll/core/constants/app_constants.dart';
import 'package:local_poll/core/enums/server_status.dart';
import 'package:local_poll/features/hosting/domain/services/local_server.dart';
import 'package:local_poll/shared/services/network_service.dart';

final localServerProvider = Provider<LocalServer>((ref) {
  throw UnimplementedError('Must be overridden when server is created');
});

final serverStatusProvider =
    StateNotifierProvider<ServerStatusNotifier, ServerStatus>((ref) {
  return ServerStatusNotifier();
});

class ServerStatusNotifier extends StateNotifier<ServerStatus> {
  ServerStatusNotifier() : super(ServerStatus.stopped);

  void update(ServerStatus status) {
    state = status;
  }
}

final networkInfoProvider = FutureProvider<String?>((ref) async {
  final service = NetworkService();
  return await service.getLocalIp();
});

final serverPortProvider =
    StateNotifierProvider<ServerPortNotifier, int>((ref) {
  return ServerPortNotifier();
});

class ServerPortNotifier extends StateNotifier<int> {
  ServerPortNotifier() : super(AppConstants.defaultServerPort);

  void update(int port) {
    state = port;
  }
}

final connectedClientsProvider =
    StateNotifierProvider<ConnectedClientsNotifier, int>((ref) {
  return ConnectedClientsNotifier();
});

class ConnectedClientsNotifier extends StateNotifier<int> {
  ConnectedClientsNotifier() : super(0);

  void update(int count) {
    state = count;
  }

  void increment() {
    state = state + 1;
  }

  void decrement() {
    if (state > 0) state = state - 1;
  }

  void reset() {
    state = 0;
  }
}
