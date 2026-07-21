enum ResultsVisibility { live, afterVote, hostControlled }

extension ResultsVisibilityExtension on ResultsVisibility {
  String get label {
    switch (this) {
      case ResultsVisibility.live:
        return 'Live';
      case ResultsVisibility.afterVote:
        return 'After Vote';
      case ResultsVisibility.hostControlled:
        return 'Host Controlled';
    }
  }

  String toJson() => name;
}

extension ResultsVisibilityX on ResultsVisibility {
  static ResultsVisibility fromJson(String value) {
    return ResultsVisibility.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Invalid ResultsVisibility: $value'),
    );
  }
}
