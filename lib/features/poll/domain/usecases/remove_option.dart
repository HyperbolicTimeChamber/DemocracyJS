import 'package:democracy_js/core/errors/app_exceptions.dart';
import 'package:democracy_js/features/poll/domain/entities/poll.dart';

class RemoveOption {
  Poll call({required Poll poll, required String optionId}) {
    final exists = poll.options.any((o) => o.id == optionId);
    if (!exists) {
      throw const PollException('Option not found');
    }

    return poll.copyWith(
      options: poll.options.where((o) => o.id != optionId).toList(),
      updatedAt: DateTime.now(),
    );
  }
}
