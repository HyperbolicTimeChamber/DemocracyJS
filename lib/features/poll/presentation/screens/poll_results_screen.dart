import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:democracy_js/core/theme/app_dimensions.dart';
import 'package:democracy_js/core/theme/app_text_styles.dart';
import 'package:democracy_js/features/poll/presentation/providers/poll_providers.dart';
import 'package:democracy_js/shared/widgets/primary_button.dart';
import 'package:democracy_js/shared/widgets/result_bar.dart';

class PollResultsScreen extends ConsumerWidget {
  const PollResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poll = ref.watch(currentPollProvider);

    if (poll == null) {
      return const Scaffold(body: Center(child: Text('No poll data')));
    }

    final totalVotes = poll.options.fold<int>(0, (sum, o) => sum + o.voteCount);

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(poll.question, style: AppTextStyles.h2),
            const SizedBox(height: AppDimensions.paddingSM),
            Text('$totalVotes total votes', style: AppTextStyles.bodySmall),
            const SizedBox(height: AppDimensions.paddingLG),
            Expanded(
              child: ListView(
                children: poll.options
                    .map((option) => ResultBar(
                          text: option.text,
                          voteCount: option.voteCount,
                          totalVotes: totalVotes,
                        ))
                    .toList(),
              ),
            ),
            PrimaryButton(
              label: 'Done',
              onPressed: () {
                ref.read(pollListProvider.notifier).addPoll(poll);
                ref.read(currentPollProvider.notifier).clear();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}
