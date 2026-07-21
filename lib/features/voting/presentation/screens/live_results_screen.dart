import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';
import 'package:local_poll/core/theme/app_text_styles.dart';
import 'package:local_poll/features/poll/presentation/providers/poll_providers.dart';
import 'package:local_poll/shared/widgets/result_bar.dart';

class LiveResultsScreen extends ConsumerWidget {
  const LiveResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poll = ref.watch(currentPollProvider);

    if (poll == null) {
      return const Center(child: Text('No active poll'));
    }

    final totalVotes = poll.options.fold<int>(0, (sum, o) => sum + o.voteCount);

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Results', style: AppTextStyles.h3),
          const SizedBox(height: AppDimensions.paddingMD),
          ...poll.options.map((option) => ResultBar(
                text: option.text,
                voteCount: option.voteCount,
                totalVotes: totalVotes,
              )),
        ],
      ),
    );
  }
}
