import 'package:local_poll/core/constants/app_constants.dart';
import 'package:local_poll/core/errors/app_exceptions.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/poll_option.dart';
import 'package:uuid/uuid.dart';

class AddOption {
  static const _uuid = Uuid();

  Poll call({required Poll poll, required String text}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw const PollException('Option text cannot be empty');
    }
    if (trimmed.length > AppConstants.maxOptionLength) {
      throw PollException(
        'Option text cannot exceed ${AppConstants.maxOptionLength} characters',
      );
    }
    if (poll.options.length >= AppConstants.optionHardLimit) {
      throw PollException(
        'Cannot add more than ${AppConstants.optionHardLimit} options',
      );
    }

    final option = PollOption(id: _uuid.v4(), text: trimmed);
    return poll.copyWith(
      options: [...poll.options, option],
      updatedAt: DateTime.now(),
    );
  }
}
