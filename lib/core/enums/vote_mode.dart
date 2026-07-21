enum VoteMode { singleChoice, multipleChoice }

extension VoteModeExtension on VoteMode {
  String get label {
    switch (this) {
      case VoteMode.singleChoice:
        return 'Single Choice';
      case VoteMode.multipleChoice:
        return 'Multiple Choice';
    }
  }

  String toJson() => name;
}

extension VoteModeX on VoteMode {
  static VoteMode fromJson(String value) {
    return VoteMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Invalid VoteMode: $value'),
    );
  }
}
