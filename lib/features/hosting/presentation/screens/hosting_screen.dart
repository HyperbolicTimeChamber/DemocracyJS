import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:democracy_js/core/enums/connection_status.dart';
import 'package:democracy_js/core/enums/poll_status.dart';
import 'package:democracy_js/core/enums/server_status.dart';
import 'package:democracy_js/core/theme/app_colors.dart';
import 'package:democracy_js/core/theme/app_dimensions.dart';
import 'package:democracy_js/core/theme/app_text_styles.dart';
import 'package:democracy_js/core/constants/app_constants.dart';
import 'package:democracy_js/core/enums/event_type.dart';
import 'package:democracy_js/features/hosting/presentation/providers/hosting_providers.dart';
import 'package:democracy_js/features/poll/domain/entities/web_socket_event.dart';
import 'package:democracy_js/features/poll/presentation/providers/poll_providers.dart';
import 'package:democracy_js/features/poll/presentation/screens/poll_results_screen.dart';
import 'package:democracy_js/shared/widgets/connection_indicator.dart';
import 'package:democracy_js/shared/widgets/loading_view.dart';
import 'package:democracy_js/shared/widgets/primary_button.dart';
import 'package:democracy_js/shared/widgets/qr_code_widget.dart';
import 'package:democracy_js/shared/widgets/result_bar.dart';
import 'package:democracy_js/shared/widgets/secondary_button.dart';

class HostingScreen extends ConsumerStatefulWidget {
  const HostingScreen({super.key});

  @override
  ConsumerState<HostingScreen> createState() => _HostingScreenState();
}

class _HostingScreenState extends ConsumerState<HostingScreen> {
  @override
  void initState() {
    super.initState();
    _startServer();
  }

  Future<void> _startServer() async {
    final port = ref.read(serverPortProvider);
    ref.read(serverStatusProvider.notifier).update(ServerStatus.starting);
    ref.read(currentPollProvider.notifier).updateStatus(PollStatus.hosting);

    // Save poll to repository
    final poll = ref.read(currentPollProvider);
    if (poll != null) {
      await ref.read(pollRepositoryProvider).createPoll(poll);
    }

    try {
      final server = ref.read(localServerProvider);
      await server.start(port: port);
      ref.read(serverStatusProvider.notifier).update(ServerStatus.running);

      // Register mDNS
      try {
        await ref.read(mdnsServiceProvider).register(
          name: AppConstants.mDnsServiceName,
          port: port,
        );
      } catch (_) {
        // mDNS registration is best-effort
      }
    } catch (e) {
      ref.read(serverStatusProvider.notifier).update(ServerStatus.failed);
    }
  }

  Future<void> _stopServer() async {
    // Broadcast poll ended
    try {
      final server = ref.read(localServerProvider);
      server.broadcastEvent(const WebSocketEvent(
        type: EventType.pollEnded,
        data: {},
      ));
      await server.stop();
    } catch (_) {}

    // Unregister mDNS
    try {
      await ref.read(mdnsServiceProvider).unregister();
    } catch (_) {}

    ref.read(serverStatusProvider.notifier).update(ServerStatus.stopped);
    ref.read(currentPollProvider.notifier).updateStatus(PollStatus.completed);

    // Save final poll state
    final poll = ref.read(currentPollProvider);
    if (poll != null) {
      await ref.read(pollRepositoryProvider).updatePoll(poll);
    }

    ref.read(connectedClientsProvider.notifier).reset();

    if (mounted) {
      unawaited(Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PollResultsScreen()),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final poll = ref.watch(currentPollProvider);
    final serverStatus = ref.watch(serverStatusProvider);
    final clientCount = ref.watch(connectedClientsProvider);
    final networkAsync = ref.watch(networkInfoProvider);
    final port = ref.watch(serverPortProvider);

    if (poll == null) {
      return const Scaffold(body: LoadingView());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hosting'),
        automaticallyImplyLeading: false,
        actions: [
          ConnectionIndicator(
            status: serverStatus == ServerStatus.running
                ? ConnectionStatus.connected
                : serverStatus == ServerStatus.starting
                    ? ConnectionStatus.connecting
                    : ConnectionStatus.disconnected,
          ),
          const SizedBox(width: AppDimensions.paddingMD),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          children: [
            Text(poll.question, style: AppTextStyles.h2, textAlign: TextAlign.center),
            const SizedBox(height: AppDimensions.paddingLG),
            networkAsync.when(
              data: (ip) {
                if (ip == null) {
                  return const Text('No network connection', style: AppTextStyles.bodySmall);
                }
                final url = 'http://$ip:$port';
                final mdnsUrl = 'http://poll.local:$port';
                return Column(
                  children: [
                    QRCodeWidget(data: url),
                    const SizedBox(height: AppDimensions.paddingMD),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: url));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('URL copied')),
                        );
                      },
                      child: Text(mdnsUrl, style: AppTextStyles.body.copyWith(color: AppColors.primary)),
                    ),
                    const SizedBox(height: AppDimensions.paddingXS),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: url));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('URL copied')),
                        );
                      },
                      child: Text(url, style: AppTextStyles.bodySmall),
                    ),
                  ],
                );
              },
              loading: () => const LoadingView(message: 'Getting network info...'),
              error: (_, __) => const Text('Could not detect network'),
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people, color: AppColors.primary),
                  const SizedBox(width: AppDimensions.paddingSM),
                  Text('$clientCount connected', style: AppTextStyles.h3),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.paddingLG),
            const Text('Live Results', style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.paddingSM),
            ...poll.options.map((option) {
              final totalVotes = poll.options.fold<int>(0, (sum, o) => sum + o.voteCount);
              return ResultBar(
                text: option.text,
                voteCount: option.voteCount,
                totalVotes: totalVotes,
              );
            }),
            const SizedBox(height: AppDimensions.paddingXL),
            if (poll.status == PollStatus.hosting)
              SecondaryButton(
                label: 'Pause Poll',
                onPressed: () {
                  ref.read(currentPollProvider.notifier).updateStatus(PollStatus.paused);
                },
              ),
            if (poll.status == PollStatus.paused)
              SecondaryButton(
                label: 'Resume Poll',
                onPressed: () {
                  ref.read(currentPollProvider.notifier).updateStatus(PollStatus.hosting);
                },
              ),
            const SizedBox(height: AppDimensions.paddingSM),
            PrimaryButton(label: 'End Poll', onPressed: _stopServer),
          ],
        ),
      ),
    );
  }
}
