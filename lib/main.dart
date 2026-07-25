import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:democracy_js/features/poll/presentation/providers/poll_providers.dart';
import 'package:democracy_js/shared/services/hive_storage_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = HiveStorageService();
  await storageService.init();

  runApp(
    ProviderScope(
      overrides: [
        hiveStorageServiceProvider.overrideWithValue(storageService),
      ],
      child: const DemocracyJSApp(),
    ),
  );
}
