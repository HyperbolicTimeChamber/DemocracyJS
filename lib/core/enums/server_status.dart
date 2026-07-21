enum ServerStatus { stopped, starting, running, failed }

extension ServerStatusExtension on ServerStatus {
  String get label {
    switch (this) {
      case ServerStatus.stopped:
        return 'Stopped';
      case ServerStatus.starting:
        return 'Starting';
      case ServerStatus.running:
        return 'Running';
      case ServerStatus.failed:
        return 'Failed';
    }
  }

  String toJson() => name;
}

extension ServerStatusX on ServerStatus {
  static ServerStatus fromJson(String value) {
    return ServerStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Invalid ServerStatus: $value'),
    );
  }
}
