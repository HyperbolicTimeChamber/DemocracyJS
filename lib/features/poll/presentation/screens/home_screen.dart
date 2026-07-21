import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_poll/core/theme/app_colors.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';
import 'package:local_poll/features/poll/presentation/providers/poll_providers.dart';
import 'package:local_poll/features/poll/presentation/screens/create_poll_screen.dart';
import 'package:local_poll/shared/widgets/empty_state.dart';
import 'package:local_poll/shared/widgets/error_view.dart';
import 'package:local_poll/shared/widgets/loading_view.dart';
import 'package:local_poll/shared/widgets/poll_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pollsAsync = ref.watch(pollListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Local Poll')),
      body: pollsAsync.when(
        loading: () => const LoadingView(),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.read(pollListProvider.notifier).load(),
        ),
        data: (polls) {
          if (polls.isEmpty) {
            return const EmptyState(
              icon: Icons.poll_outlined,
              title: 'No polls yet',
              subtitle: 'Tap + to create your first poll',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingMD),
            itemCount: polls.length,
            itemBuilder: (context, index) {
              final poll = polls[index];
              return PollCard(
                question: poll.question,
                status: poll.status,
                optionCount: poll.options.length,
                onTap: () {
                  ref.read(currentPollProvider.notifier).updatePoll(poll);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(currentPollProvider.notifier).clear();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreatePollScreen()),
          );
        },
        backgroundColor: AppColors.primaryVariant,
        child: const Icon(Icons.add, color: AppColors.textPrimary),
      ),
    );
  }
}
