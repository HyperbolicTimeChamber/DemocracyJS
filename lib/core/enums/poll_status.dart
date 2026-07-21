enum PollStatus { draft, hosting, paused, completed }

extension PollStatusExtension on PollStatus {
  String get label {
    switch (this) {
      case PollStatus.draft:
        return 'Draft';
      case PollStatus.hosting:
        return 'Hosting';
      case PollStatus.paused:
        return 'Paused';
      case PollStatus.completed:
        return 'Completed';
    }
  }

  String toJson() => name;
}

extension PollStatusX on PollStatus {
  static PollStatus fromJson(String value) {
    return PollStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Invalid PollStatus: $value'),
    );
  }
}
