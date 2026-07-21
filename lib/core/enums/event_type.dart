enum EventType {
  pollCreated,
  userJoined,
  voteSubmitted,
  resultsUpdated,
  pollEnded,
}

extension EventTypeExtension on EventType {
  String get label {
    switch (this) {
      case EventType.pollCreated:
        return 'Poll Created';
      case EventType.userJoined:
        return 'User Joined';
      case EventType.voteSubmitted:
        return 'Vote Submitted';
      case EventType.resultsUpdated:
        return 'Results Updated';
      case EventType.pollEnded:
        return 'Poll Ended';
    }
  }

  String toJson() {
    switch (this) {
      case EventType.pollCreated:
        return 'poll_created';
      case EventType.userJoined:
        return 'user_joined';
      case EventType.voteSubmitted:
        return 'vote_submitted';
      case EventType.resultsUpdated:
        return 'results_updated';
      case EventType.pollEnded:
        return 'poll_ended';
    }
  }
}

extension EventTypeX on EventType {
  static EventType fromJson(String value) {
    switch (value) {
      case 'poll_created':
        return EventType.pollCreated;
      case 'user_joined':
        return EventType.userJoined;
      case 'vote_submitted':
        return EventType.voteSubmitted;
      case 'results_updated':
        return EventType.resultsUpdated;
      case 'poll_ended':
        return EventType.pollEnded;
      default:
        throw ArgumentError('Invalid EventType: $value');
    }
  }
}
