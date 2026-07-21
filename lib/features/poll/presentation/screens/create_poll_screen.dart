import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_poll/core/constants/app_constants.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/core/theme/app_colors.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';
import 'package:local_poll/core/theme/app_text_styles.dart';
import 'package:local_poll/features/poll/presentation/providers/poll_providers.dart';
import 'package:local_poll/features/poll/presentation/widgets/option_input_field.dart';
import 'package:local_poll/features/hosting/presentation/screens/hosting_screen.dart';
import 'package:local_poll/shared/widgets/option_tile.dart';
import 'package:local_poll/shared/widgets/primary_button.dart';

class CreatePollScreen extends ConsumerStatefulWidget {
  const CreatePollScreen({super.key});

  @override
  ConsumerState<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends ConsumerState<CreatePollScreen> {
  final _questionController = TextEditingController();
  VoteMode _voteMode = VoteMode.singleChoice;
  ResultsVisibility _visibility = ResultsVisibility.afterVote;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _createAndHost() {
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a question')),
      );
      return;
    }

    final poll = ref.read(currentPollProvider);
    if (poll == null || poll.options.length < AppConstants.minOptions) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Add at least ${AppConstants.minOptions} options')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HostingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final poll = ref.watch(currentPollProvider);
    final options = poll?.options ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Create Poll')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question', style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.paddingSM),
            TextField(
              controller: _questionController,
              maxLength: AppConstants.maxQuestionLength,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'What do you want to ask?',
              ),
              onChanged: (value) {
                if (poll == null && value.trim().isNotEmpty) {
                  ref.read(currentPollProvider.notifier).create(
                    question: value,
                    voteMode: _voteMode,
                    resultsVisibility: _visibility,
                  );
                }
              },
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            Text('Vote Mode', style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.paddingSM),
            SegmentedButton<VoteMode>(
              segments: VoteMode.values
                  .map((mode) => ButtonSegment(
                        value: mode,
                        label: Text(mode.label),
                      ))
                  .toList(),
              selected: {_voteMode},
              onSelectionChanged: (selected) {
                setState(() => _voteMode = selected.first);
              },
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            Text('Results Visibility', style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.paddingSM),
            DropdownButtonFormField<ResultsVisibility>(
              value: _visibility,
              items: ResultsVisibility.values
                  .map((v) => DropdownMenuItem(
                        value: v,
                        child: Text(v.label),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _visibility = v);
              },
              dropdownColor: AppColors.surface,
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Options (${options.length})', style: AppTextStyles.h3),
                if (options.length >= AppConstants.optionSoftLimit &&
                    options.length < AppConstants.optionHardLimit)
                  Text(
                    'Recommended max: ${AppConstants.optionSoftLimit}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.paddingSM),
            ...options.map((option) => OptionTile(
                  text: option.text,
                  onDelete: () {
                    ref.read(currentPollProvider.notifier).removeOption(option.id);
                  },
                )),
            if (options.length < AppConstants.optionHardLimit) ...[
              const SizedBox(height: AppDimensions.paddingSM),
              OptionInputField(
                onAdd: (text) {
                  if (poll == null) {
                    final q = _questionController.text.trim();
                    if (q.isEmpty) return;
                    ref.read(currentPollProvider.notifier).create(
                      question: q,
                      voteMode: _voteMode,
                      resultsVisibility: _visibility,
                    );
                  }
                  ref.read(currentPollProvider.notifier).addOption(text);
                },
              ),
              const Text('Add Option', style: AppTextStyles.caption),
            ],
            const SizedBox(height: AppDimensions.paddingXL),
            PrimaryButton(
              label: 'Start Hosting',
              onPressed: _createAndHost,
            ),
          ],
        ),
      ),
    );
  }
}
