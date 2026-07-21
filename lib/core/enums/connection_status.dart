enum ConnectionStatus { disconnected, connecting, connected, error }

extension ConnectionStatusExtension on ConnectionStatus {
  String get label {
    switch (this) {
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.connecting:
        return 'Connecting';
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.error:
        return 'Error';
    }
  }

  String toJson() => name;
}

extension ConnectionStatusX on ConnectionStatus {
  static ConnectionStatus fromJson(String value) {
    return ConnectionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Invalid ConnectionStatus: $value'),
    );
  }
}
