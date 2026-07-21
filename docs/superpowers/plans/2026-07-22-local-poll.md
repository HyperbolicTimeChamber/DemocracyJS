# Local Poll Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an offline-first Flutter polling app where the host phone runs a local HTTP/WebSocket server and participants vote via browser.

**Architecture:** Monolith feature folders with clean architecture layers (data/domain/presentation) per feature. Shelf embedded HTTP server serves REST API + browser client. Riverpod for state management. Hive for persistence.

**Tech Stack:** Flutter, Dart, Riverpod, Freezed, Shelf, Hive, QR Flutter, Bonsoir (mDNS)

## Global Constraints

- Dart SDK >=3.0.0
- Flutter SDK >=3.10.0
- Dark theme default
- Color palette: `#F8F8FF` (light bg), `#33CCFF` (primary), `#2244EE` (primary variant), `#2E2840` (surface), `#0A0A0F` (dark bg)
- No magic strings/numbers — use constants
- No business logic in widgets
- Immutable state everywhere
- All enums have `label`, `toJson()`, `fromJson()` extensions
- Server default port: 5000
- Poll option soft limit: 10, hard limit: 20
- IP-based duplicate vote prevention
- Browser client: vanilla HTML/CSS/JS, no frameworks, Safari-compatible

---

### Task 1: Flutter Project Setup + Core Foundation

**Files:**
- Create: `pubspec.yaml` (overwrite generated)
- Create: `lib/main.dart`
- Create: `lib/app.dart`
- Create: `lib/core/constants/app_constants.dart`
- Create: `lib/core/enums/poll_status.dart`
- Create: `lib/core/enums/vote_mode.dart`
- Create: `lib/core/enums/server_status.dart`
- Create: `lib/core/enums/connection_status.dart`
- Create: `lib/core/enums/event_type.dart`
- Create: `lib/core/enums/results_visibility.dart`
- Create: `lib/core/errors/app_exceptions.dart`
- Create: `lib/core/theme/app_colors.dart`
- Create: `lib/core/theme/app_dimensions.dart`
- Create: `lib/core/theme/app_text_styles.dart`
- Create: `lib/core/theme/app_theme.dart`
- Create: `lib/core/utils/network_utils.dart`
- Create: `analysis_options.yaml` (overwrite generated)
- Test: `test/unit/core/enums/poll_status_test.dart`
- Test: `test/unit/core/enums/vote_mode_test.dart`
- Test: `test/unit/core/enums/results_visibility_test.dart`

**Interfaces:**
- Consumes: nothing (first task)
- Produces:
  - `PollStatus` enum with `.label`, `.toJson()`, `PollStatusX.fromJson(String)`
  - `VoteMode` enum with `.label`, `.toJson()`, `VoteModeX.fromJson(String)`
  - `ServerStatus` enum with `.label`, `.toJson()`, `ServerStatusX.fromJson(String)`
  - `ConnectionStatus` enum with `.label`, `.toJson()`, `ConnectionStatusX.fromJson(String)`
  - `EventType` enum with `.label`, `.toJson()`, `EventTypeX.fromJson(String)`
  - `ResultsVisibility` enum with `.label`, `.toJson()`, `ResultsVisibilityX.fromJson(String)`
  - `AppConstants` class with static fields
  - `AppColors`, `AppDimensions`, `AppTextStyles`, `AppTheme`
  - `AppException`, `ServerException`, `PollException`, `VoteException`
  - `NetworkUtils.getLocalIpAddress()` → `Future<String?>`

- [ ] **Step 1: Create Flutter project**

```bash
cd /Users/nolandmello/DemocracyJS
flutter create --org com.localpoll --project-name local_poll . --platforms android
```

This creates the Flutter project in the existing repo directory, targeting Android only.

- [ ] **Step 2: Update .gitignore for Flutter**

Replace existing Node .gitignore with Flutter-appropriate one:

```gitignore
# Flutter
*.dart_tool/
.packages
build/
.flutter-plugins
.flutter-plugins-dependencies
.dart_tool/

# IDE
.idea/
*.iml
.vscode/

# Generated
*.g.dart
*.freezed.dart

# OS
.DS_Store
Thumbs.db

# Env
.env
.env.*
```

- [ ] **Step 3: Update pubspec.yaml**

```yaml
name: local_poll
description: Offline-first local-network polling system
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shelf: ^1.4.2
  shelf_router: ^1.1.4
  shelf_web_socket: ^2.0.1
  web_socket_channel: ^3.0.1
  network_info_plus: ^6.1.1
  qr_flutter: ^4.1.0
  bonsoir: ^5.1.4
  uuid: ^4.5.1
  path_provider: ^2.1.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  hive_generator: ^2.0.1
  riverpod_generator: ^2.6.3
  mocktail: ^1.0.4

flutter:
  uses-material-design: true
  assets:
    - assets/browser_client/
```

- [ ] **Step 4: Update analysis_options.yaml**

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    avoid_print: true
    prefer_single_quotes: true
    sort_constructors_first: true
    unawaited_futures: true

analyzer:
  exclude:
    - '**/*.g.dart'
    - '**/*.freezed.dart'
```

- [ ] **Step 5: Write enum tests**

`test/unit/core/enums/poll_status_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/core/enums/poll_status.dart';

void main() {
  group('PollStatus', () {
    test('label returns human-readable string', () {
      expect(PollStatus.draft.label, 'Draft');
      expect(PollStatus.hosting.label, 'Hosting');
      expect(PollStatus.paused.label, 'Paused');
      expect(PollStatus.completed.label, 'Completed');
    });

    test('toJson returns snake_case string', () {
      expect(PollStatus.draft.toJson(), 'draft');
      expect(PollStatus.hosting.toJson(), 'hosting');
      expect(PollStatus.paused.toJson(), 'paused');
      expect(PollStatus.completed.toJson(), 'completed');
    });

    test('fromJson parses valid string', () {
      expect(PollStatusX.fromJson('draft'), PollStatus.draft);
      expect(PollStatusX.fromJson('hosting'), PollStatus.hosting);
      expect(PollStatusX.fromJson('paused'), PollStatus.paused);
      expect(PollStatusX.fromJson('completed'), PollStatus.completed);
    });

    test('fromJson throws on invalid string', () {
      expect(() => PollStatusX.fromJson('invalid'), throwsArgumentError);
    });
  });
}
```

`test/unit/core/enums/vote_mode_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/core/enums/vote_mode.dart';

void main() {
  group('VoteMode', () {
    test('label returns human-readable string', () {
      expect(VoteMode.singleChoice.label, 'Single Choice');
      expect(VoteMode.multipleChoice.label, 'Multiple Choice');
    });

    test('toJson returns camelCase string', () {
      expect(VoteMode.singleChoice.toJson(), 'singleChoice');
      expect(VoteMode.multipleChoice.toJson(), 'multipleChoice');
    });

    test('fromJson parses valid string', () {
      expect(VoteModeX.fromJson('singleChoice'), VoteMode.singleChoice);
      expect(VoteModeX.fromJson('multipleChoice'), VoteMode.multipleChoice);
    });

    test('fromJson throws on invalid string', () {
      expect(() => VoteModeX.fromJson('invalid'), throwsArgumentError);
    });
  });
}
```

`test/unit/core/enums/results_visibility_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/core/enums/results_visibility.dart';

void main() {
  group('ResultsVisibility', () {
    test('label returns human-readable string', () {
      expect(ResultsVisibility.live.label, 'Live');
      expect(ResultsVisibility.afterVote.label, 'After Vote');
      expect(ResultsVisibility.hostControlled.label, 'Host Controlled');
    });

    test('toJson returns camelCase string', () {
      expect(ResultsVisibility.live.toJson(), 'live');
      expect(ResultsVisibility.afterVote.toJson(), 'afterVote');
      expect(ResultsVisibility.hostControlled.toJson(), 'hostControlled');
    });

    test('fromJson parses valid string', () {
      expect(ResultsVisibilityX.fromJson('live'), ResultsVisibility.live);
      expect(ResultsVisibilityX.fromJson('afterVote'), ResultsVisibility.afterVote);
      expect(ResultsVisibilityX.fromJson('hostControlled'), ResultsVisibility.hostControlled);
    });

    test('fromJson throws on invalid string', () {
      expect(() => ResultsVisibilityX.fromJson('invalid'), throwsArgumentError);
    });
  });
}
```

- [ ] **Step 6: Run tests to verify they fail**

```bash
flutter test test/unit/core/enums/
```

Expected: FAIL — files don't exist yet.

- [ ] **Step 7: Create all enums**

`lib/core/enums/poll_status.dart`:
```dart
enum PollStatus { draft, hosting, paused, completed }

extension PollStatusExtension on PollStatus {
  String get label {
    switch (this) {
      case PollStatus.draft:
        return 'Draft';
      case PollStatus.hosting:
        return 'Hosting';
      case PollStatus.paused:
        return 'Paused';
      case PollStatus.completed:
        return 'Completed';
    }
  }

  String toJson() => name;
}

extension PollStatusX on PollStatus {
  static PollStatus fromJson(String value) {
    return PollStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Invalid PollStatus: $value'),
    );
  }
}
```

`lib/core/enums/vote_mode.dart`:
```dart
enum VoteMode { singleChoice, multipleChoice }

extension VoteModeExtension on VoteMode {
  String get label {
    switch (this) {
      case VoteMode.singleChoice:
        return 'Single Choice';
      case VoteMode.multipleChoice:
        return 'Multiple Choice';
    }
  }

  String toJson() => name;
}

extension VoteModeX on VoteMode {
  static VoteMode fromJson(String value) {
    return VoteMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Invalid VoteMode: $value'),
    );
  }
}
```

`lib/core/enums/server_status.dart`:
```dart
enum ServerStatus { stopped, starting, running, failed }

extension ServerStatusExtension on ServerStatus {
  String get label {
    switch (this) {
      case ServerStatus.stopped:
        return 'Stopped';
      case ServerStatus.starting:
        return 'Starting';
      case ServerStatus.running:
        return 'Running';
      case ServerStatus.failed:
        return 'Failed';
    }
  }

  String toJson() => name;
}

extension ServerStatusX on ServerStatus {
  static ServerStatus fromJson(String value) {
    return ServerStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Invalid ServerStatus: $value'),
    );
  }
}
```

`lib/core/enums/connection_status.dart`:
```dart
enum ConnectionStatus { disconnected, connecting, connected, error }

extension ConnectionStatusExtension on ConnectionStatus {
  String get label {
    switch (this) {
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.connecting:
        return 'Connecting';
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.error:
        return 'Error';
    }
  }

  String toJson() => name;
}

extension ConnectionStatusX on ConnectionStatus {
  static ConnectionStatus fromJson(String value) {
    return ConnectionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Invalid ConnectionStatus: $value'),
    );
  }
}
```

`lib/core/enums/event_type.dart`:
```dart
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
```

`lib/core/enums/results_visibility.dart`:
```dart
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
```

- [ ] **Step 8: Create app constants**

`lib/core/constants/app_constants.dart`:
```dart
abstract class AppConstants {
  static const int defaultServerPort = 5000;
  static const int optionSoftLimit = 10;
  static const int optionHardLimit = 20;
  static const int minOptions = 2;
  static const int maxQuestionLength = 500;
  static const int maxOptionLength = 200;
  static const String mDnsServiceName = 'poll';
  static const String mDnsServiceType = '_http._tcp';
  static const Duration serverStartTimeout = Duration(seconds: 10);
  static const Duration wsReconnectInitial = Duration(seconds: 1);
  static const Duration wsReconnectMax = Duration(seconds: 10);

  // Hive box names
  static const String pollsBox = 'polls';
  static const String votesBox = 'votes';
  static const String settingsBox = 'settings';

  // Settings keys
  static const String serverPortKey = 'server_port';
}
```

- [ ] **Step 9: Create app exceptions**

`lib/core/errors/app_exceptions.dart`:
```dart
class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException(super.message);
}

class PollException extends AppException {
  const PollException(super.message);
}

class VoteException extends AppException {
  const VoteException(super.message);
}
```

- [ ] **Step 10: Create theme files**

`lib/core/theme/app_colors.dart`:
```dart
import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF33CCFF);
  static const Color primaryVariant = Color(0xFF2244EE);

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF8F8FF);
  static const Color backgroundDark = Color(0xFF0A0A0F);

  // Surfaces
  static const Color surface = Color(0xFF2E2840);
  static const Color surfaceLight = Color(0xFF3D3555);

  // Text
  static const Color textPrimary = Color(0xFFF8F8FF);
  static const Color textSecondary = Color(0xFFB0A8C0);
  static const Color textOnPrimary = Color(0xFF0A0A0F);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFB74D);

  // Misc
  static const Color divider = Color(0xFF3D3555);
  static const Color disabled = Color(0xFF555060);
}
```

`lib/core/theme/app_dimensions.dart`:
```dart
abstract class AppDimensions {
  // Padding
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  // Border radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 999.0;

  // Component sizes
  static const double buttonHeight = 52.0;
  static const double inputHeight = 52.0;
  static const double iconSizeSM = 20.0;
  static const double iconSizeMD = 24.0;
  static const double iconSizeLG = 32.0;
  static const double qrCodeSize = 250.0;
  static const double resultBarHeight = 40.0;
  static const double statusDotSize = 10.0;
}
```

`lib/core/theme/app_text_styles.dart`:
```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
  );
}
```

`lib/core/theme/app_theme.dart`:
```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';

abstract class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.primaryVariant,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundDark,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMD,
            vertical: AppDimensions.paddingMD,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
        ),
      );
}
```

- [ ] **Step 11: Create network utils**

`lib/core/utils/network_utils.dart`:
```dart
import 'package:network_info_plus/network_info_plus.dart';

abstract class NetworkUtils {
  static final NetworkInfo _networkInfo = NetworkInfo();

  static Future<String?> getLocalIpAddress() async {
    return await _networkInfo.getWifiIP();
  }
}
```

- [ ] **Step 12: Create main.dart and app.dart**

`lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.settingsBox);
  runApp(const ProviderScope(child: LocalPollApp()));
}
```

`lib/app.dart`:
```dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

class LocalPollApp extends StatelessWidget {
  const LocalPollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Poll',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const Scaffold(
        body: Center(child: Text('Local Poll')),
      ),
    );
  }
}
```

- [ ] **Step 13: Run tests to verify they pass**

```bash
flutter pub get && flutter test test/unit/core/enums/
```

Expected: All tests PASS.

- [ ] **Step 14: Commit**

```bash
git add -A
git commit -m "feat: flutter project setup with core enums, theme, and constants"
```

---

### Task 2: Domain Layer — Entities, Models, Repository Interface

**Files:**
- Create: `lib/features/poll/domain/entities/poll_option.dart`
- Create: `lib/features/poll/domain/entities/poll.dart`
- Create: `lib/features/poll/domain/entities/vote.dart`
- Create: `lib/features/poll/domain/entities/web_socket_event.dart`
- Create: `lib/features/poll/domain/repositories/poll_repository.dart`
- Create: `lib/features/poll/data/models/poll_option_model.dart`
- Create: `lib/features/poll/data/models/poll_model.dart`
- Create: `lib/features/poll/data/models/vote_model.dart`
- Test: `test/unit/features/poll/domain/entities/poll_test.dart`
- Test: `test/unit/features/poll/data/models/poll_model_test.dart`

**Interfaces:**
- Consumes: All enums from Task 1
- Produces:
  - `PollOption` freezed entity with `id`, `text`, `voteCount`
  - `Poll` freezed entity with `id`, `question`, `options`, `status`, `voteMode`, `resultsVisibility`, `createdAt`, `updatedAt`
  - `Vote` freezed entity with `id`, `pollId`, `optionIds`, `voterIp`, `timestamp`
  - `WebSocketEvent` with `type` (EventType), `data` (Map)
  - `PollRepository` abstract class
  - `PollOptionModel`, `PollModel`, `VoteModel` with `toJson()`/`fromJson()` + `toEntity()`/`fromEntity()`

- [ ] **Step 1: Write entity tests**

`test/unit/features/poll/domain/entities/poll_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/poll_option.dart';

void main() {
  group('Poll', () {
    test('creates with required fields', () {
      final now = DateTime.now();
      final poll = Poll(
        id: 'test-id',
        question: 'What is best?',
        options: [
          const PollOption(id: 'opt-1', text: 'Option A', voteCount: 0),
          const PollOption(id: 'opt-2', text: 'Option B', voteCount: 0),
        ],
        status: PollStatus.draft,
        voteMode: VoteMode.singleChoice,
        resultsVisibility: ResultsVisibility.afterVote,
        createdAt: now,
        updatedAt: now,
      );

      expect(poll.id, 'test-id');
      expect(poll.question, 'What is best?');
      expect(poll.options.length, 2);
      expect(poll.status, PollStatus.draft);
      expect(poll.voteMode, VoteMode.singleChoice);
      expect(poll.resultsVisibility, ResultsVisibility.afterVote);
    });

    test('copyWith creates modified copy', () {
      final now = DateTime.now();
      final poll = Poll(
        id: 'test-id',
        question: 'Original?',
        options: const [],
        status: PollStatus.draft,
        voteMode: VoteMode.singleChoice,
        resultsVisibility: ResultsVisibility.afterVote,
        createdAt: now,
        updatedAt: now,
      );

      final updated = poll.copyWith(status: PollStatus.hosting);
      expect(updated.status, PollStatus.hosting);
      expect(updated.question, 'Original?');
    });

    test('equality works for identical values', () {
      final now = DateTime(2026, 1, 1);
      final a = Poll(
        id: 'id',
        question: 'Q?',
        options: const [],
        status: PollStatus.draft,
        voteMode: VoteMode.singleChoice,
        resultsVisibility: ResultsVisibility.afterVote,
        createdAt: now,
        updatedAt: now,
      );
      final b = Poll(
        id: 'id',
        question: 'Q?',
        options: const [],
        status: PollStatus.draft,
        voteMode: VoteMode.singleChoice,
        resultsVisibility: ResultsVisibility.afterVote,
        createdAt: now,
        updatedAt: now,
      );
      expect(a, equals(b));
    });
  });

  group('PollOption', () {
    test('creates with defaults', () {
      const option = PollOption(id: 'o1', text: 'Yes', voteCount: 0);
      expect(option.id, 'o1');
      expect(option.text, 'Yes');
      expect(option.voteCount, 0);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
flutter test test/unit/features/poll/domain/entities/poll_test.dart
```

Expected: FAIL — entities not defined.

- [ ] **Step 3: Create freezed entities**

`lib/features/poll/domain/entities/poll_option.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'poll_option.freezed.dart';

@freezed
class PollOption with _$PollOption {
  const factory PollOption({
    required String id,
    required String text,
    @Default(0) int voteCount,
  }) = _PollOption;
}
```

`lib/features/poll/domain/entities/poll.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'poll_option.dart';

part 'poll.freezed.dart';

@freezed
class Poll with _$Poll {
  const factory Poll({
    required String id,
    required String question,
    required List<PollOption> options,
    required PollStatus status,
    required VoteMode voteMode,
    required ResultsVisibility resultsVisibility,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Poll;
}
```

`lib/features/poll/domain/entities/vote.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote.freezed.dart';

@freezed
class Vote with _$Vote {
  const factory Vote({
    required String id,
    required String pollId,
    required List<String> optionIds,
    required String voterIp,
    required DateTime timestamp,
  }) = _Vote;
}
```

`lib/features/poll/domain/entities/web_socket_event.dart`:
```dart
import 'package:local_poll/core/enums/event_type.dart';

class WebSocketEvent {
  const WebSocketEvent({required this.type, required this.data});

  final EventType type;
  final Map<String, dynamic> data;
}
```

- [ ] **Step 4: Create repository interface**

`lib/features/poll/domain/repositories/poll_repository.dart`:
```dart
import '../entities/poll.dart';
import '../entities/vote.dart';

abstract class PollRepository {
  Future<Poll> createPoll(Poll poll);
  Future<Poll?> getPoll(String id);
  Future<List<Poll>> getAllPolls();
  Future<Poll> updatePoll(Poll poll);
  Future<void> deletePoll(String id);
  Future<Vote> submitVote(Vote vote);
  Future<List<Vote>> getVotesForPoll(String id);
  Future<bool> hasVoted(String pollId, String voterIp);
}
```

- [ ] **Step 5: Create data models with JSON serialization**

`lib/features/poll/data/models/poll_option_model.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:local_poll/features/poll/domain/entities/poll_option.dart';

part 'poll_option_model.freezed.dart';
part 'poll_option_model.g.dart';

@freezed
class PollOptionModel with _$PollOptionModel {
  const factory PollOptionModel({
    required String id,
    required String text,
    @Default(0) int voteCount,
  }) = _PollOptionModel;

  factory PollOptionModel.fromJson(Map<String, dynamic> json) =>
      _$PollOptionModelFromJson(json);

  factory PollOptionModel.fromEntity(PollOption entity) => PollOptionModel(
        id: entity.id,
        text: entity.text,
        voteCount: entity.voteCount,
      );
}

extension PollOptionModelX on PollOptionModel {
  PollOption toEntity() => PollOption(
        id: id,
        text: text,
        voteCount: voteCount,
      );
}
```

`lib/features/poll/data/models/poll_model.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'poll_option_model.dart';

part 'poll_model.freezed.dart';
part 'poll_model.g.dart';

@freezed
class PollModel with _$PollModel {
  const factory PollModel({
    required String id,
    required String question,
    required List<PollOptionModel> options,
    required String status,
    required String voteMode,
    required String resultsVisibility,
    required String createdAt,
    required String updatedAt,
  }) = _PollModel;

  factory PollModel.fromJson(Map<String, dynamic> json) =>
      _$PollModelFromJson(json);

  factory PollModel.fromEntity(Poll entity) => PollModel(
        id: entity.id,
        question: entity.question,
        options:
            entity.options.map((o) => PollOptionModel.fromEntity(o)).toList(),
        status: entity.status.toJson(),
        voteMode: entity.voteMode.toJson(),
        resultsVisibility: entity.resultsVisibility.toJson(),
        createdAt: entity.createdAt.toIso8601String(),
        updatedAt: entity.updatedAt.toIso8601String(),
      );
}

extension PollModelX on PollModel {
  Poll toEntity() => Poll(
        id: id,
        question: question,
        options: options.map((o) => o.toEntity()).toList(),
        status: PollStatusX.fromJson(status),
        voteMode: VoteModeX.fromJson(voteMode),
        resultsVisibility: ResultsVisibilityX.fromJson(resultsVisibility),
        createdAt: DateTime.parse(createdAt),
        updatedAt: DateTime.parse(updatedAt),
      );
}
```

`lib/features/poll/data/models/vote_model.dart`:
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:local_poll/features/poll/domain/entities/vote.dart';

part 'vote_model.freezed.dart';
part 'vote_model.g.dart';

@freezed
class VoteModel with _$VoteModel {
  const factory VoteModel({
    required String id,
    required String pollId,
    required List<String> optionIds,
    required String voterIp,
    required String timestamp,
  }) = _VoteModel;

  factory VoteModel.fromJson(Map<String, dynamic> json) =>
      _$VoteModelFromJson(json);

  factory VoteModel.fromEntity(Vote entity) => VoteModel(
        id: entity.id,
        pollId: entity.pollId,
        optionIds: entity.optionIds,
        voterIp: entity.voterIp,
        timestamp: entity.timestamp.toIso8601String(),
      );
}

extension VoteModelX on VoteModel {
  Vote toEntity() => Vote(
        id: id,
        pollId: pollId,
        optionIds: optionIds,
        voterIp: voterIp,
        timestamp: DateTime.parse(timestamp),
      );
}
```

- [ ] **Step 6: Write model tests**

`test/unit/features/poll/data/models/poll_model_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/features/poll/data/models/poll_model.dart';
import 'package:local_poll/features/poll/data/models/poll_option_model.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/poll_option.dart';

void main() {
  group('PollModel', () {
    final now = DateTime(2026, 1, 1);

    test('fromJson creates model from JSON map', () {
      final json = {
        'id': 'p1',
        'question': 'Best color?',
        'options': [
          {'id': 'o1', 'text': 'Red', 'voteCount': 3},
          {'id': 'o2', 'text': 'Blue', 'voteCount': 5},
        ],
        'status': 'hosting',
        'voteMode': 'singleChoice',
        'resultsVisibility': 'afterVote',
        'createdAt': '2026-01-01T00:00:00.000',
        'updatedAt': '2026-01-01T00:00:00.000',
      };

      final model = PollModel.fromJson(json);
      expect(model.id, 'p1');
      expect(model.question, 'Best color?');
      expect(model.options.length, 2);
      expect(model.status, 'hosting');
    });

    test('toJson produces valid JSON map', () {
      const model = PollModel(
        id: 'p1',
        question: 'Q?',
        options: [PollOptionModel(id: 'o1', text: 'A', voteCount: 0)],
        status: 'draft',
        voteMode: 'singleChoice',
        resultsVisibility: 'afterVote',
        createdAt: '2026-01-01T00:00:00.000',
        updatedAt: '2026-01-01T00:00:00.000',
      );

      final json = model.toJson();
      expect(json['id'], 'p1');
      expect(json['options'], isList);
      expect((json['options'] as List).first['text'], 'A');
    });

    test('round-trips entity → model → entity', () {
      final entity = Poll(
        id: 'p1',
        question: 'Q?',
        options: const [PollOption(id: 'o1', text: 'A', voteCount: 2)],
        status: PollStatus.hosting,
        voteMode: VoteMode.singleChoice,
        resultsVisibility: ResultsVisibility.afterVote,
        createdAt: now,
        updatedAt: now,
      );

      final model = PollModel.fromEntity(entity);
      final restored = model.toEntity();

      expect(restored.id, entity.id);
      expect(restored.question, entity.question);
      expect(restored.status, entity.status);
      expect(restored.options.first.voteCount, 2);
    });

    test('round-trips JSON → model → JSON', () {
      final json = {
        'id': 'p1',
        'question': 'Q?',
        'options': [
          {'id': 'o1', 'text': 'A', 'voteCount': 0},
        ],
        'status': 'draft',
        'voteMode': 'singleChoice',
        'resultsVisibility': 'live',
        'createdAt': '2026-01-01T00:00:00.000',
        'updatedAt': '2026-01-01T00:00:00.000',
      };

      final model = PollModel.fromJson(json);
      final output = model.toJson();

      expect(output['id'], json['id']);
      expect(output['status'], json['status']);
      expect(output['resultsVisibility'], json['resultsVisibility']);
    });
  });
}
```

- [ ] **Step 7: Run code generation**

```bash
cd /Users/nolandmello/DemocracyJS && dart run build_runner build --delete-conflicting-outputs
```

Expected: generates `.freezed.dart` and `.g.dart` files.

- [ ] **Step 8: Run all tests**

```bash
flutter test test/unit/
```

Expected: All tests PASS.

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "feat: domain entities, data models, and repository interface"
```

---

### Task 3: Data Layer — Hive Repository Implementation + Use Cases

**Files:**
- Create: `lib/shared/services/hive_storage_service.dart`
- Create: `lib/features/poll/data/repositories/poll_repository_impl.dart`
- Create: `lib/features/poll/domain/usecases/create_poll.dart`
- Create: `lib/features/poll/domain/usecases/add_option.dart`
- Create: `lib/features/poll/domain/usecases/remove_option.dart`
- Create: `lib/features/poll/domain/usecases/submit_vote.dart`
- Create: `lib/features/voting/domain/usecases/process_vote.dart`
- Test: `test/unit/features/poll/data/repositories/poll_repository_impl_test.dart`
- Test: `test/unit/features/poll/domain/usecases/create_poll_test.dart`
- Test: `test/unit/features/poll/domain/usecases/submit_vote_test.dart`

**Interfaces:**
- Consumes: `PollRepository` interface, `Poll`, `Vote`, `PollOption`, `PollModel`, `VoteModel`, enums, `AppConstants`
- Produces:
  - `HiveStorageService` with `init()`, `getBox<T>(String name)`
  - `PollRepositoryImpl` implements `PollRepository`
  - `CreatePoll` use case: `call({required String question, required VoteMode voteMode, required ResultsVisibility resultsVisibility})` → `Future<Poll>`
  - `AddOption` use case: `call({required Poll poll, required String text})` → `Poll`
  - `RemoveOption` use case: `call({required Poll poll, required String optionId})` → `Poll`
  - `SubmitVote` use case: `call({required String pollId, required List<String> optionIds, required String voterIp})` → `Future<Vote>`
  - `ProcessVote` use case: `call({required Poll poll, required Vote vote})` → `Poll`

- [ ] **Step 1: Write repository tests**

`test/unit/features/poll/data/repositories/poll_repository_impl_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:local_poll/core/constants/app_constants.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/features/poll/data/repositories/poll_repository_impl.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/poll_option.dart';
import 'package:local_poll/features/poll/domain/entities/vote.dart';
import 'dart:io';

void main() {
  late PollRepositoryImpl repository;
  late Box pollsBox;
  late Box votesBox;

  setUp(() async {
    final tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    pollsBox = await Hive.openBox(AppConstants.pollsBox);
    votesBox = await Hive.openBox(AppConstants.votesBox);
    repository = PollRepositoryImpl(pollsBox: pollsBox, votesBox: votesBox);
  });

  tearDown(() async {
    await pollsBox.clear();
    await votesBox.clear();
    await Hive.close();
  });

  Poll _makePoll({String id = 'p1'}) {
    final now = DateTime.now();
    return Poll(
      id: id,
      question: 'Test?',
      options: const [
        PollOption(id: 'o1', text: 'A', voteCount: 0),
        PollOption(id: 'o2', text: 'B', voteCount: 0),
      ],
      status: PollStatus.draft,
      voteMode: VoteMode.singleChoice,
      resultsVisibility: ResultsVisibility.afterVote,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('PollRepositoryImpl', () {
    test('createPoll stores and returns poll', () async {
      final poll = _makePoll();
      final result = await repository.createPoll(poll);
      expect(result.id, poll.id);

      final stored = await repository.getPoll(poll.id);
      expect(stored, isNotNull);
      expect(stored!.question, 'Test?');
    });

    test('getAllPolls returns all stored polls', () async {
      await repository.createPoll(_makePoll(id: 'p1'));
      await repository.createPoll(_makePoll(id: 'p2'));

      final polls = await repository.getAllPolls();
      expect(polls.length, 2);
    });

    test('updatePoll modifies existing poll', () async {
      final poll = _makePoll();
      await repository.createPoll(poll);

      final updated = poll.copyWith(status: PollStatus.hosting);
      await repository.updatePoll(updated);

      final result = await repository.getPoll(poll.id);
      expect(result!.status, PollStatus.hosting);
    });

    test('deletePoll removes poll', () async {
      await repository.createPoll(_makePoll());
      await repository.deletePoll('p1');

      final result = await repository.getPoll('p1');
      expect(result, isNull);
    });

    test('submitVote stores vote', () async {
      final vote = Vote(
        id: 'v1',
        pollId: 'p1',
        optionIds: const ['o1'],
        voterIp: '192.168.1.5',
        timestamp: DateTime.now(),
      );

      final result = await repository.submitVote(vote);
      expect(result.id, 'v1');
    });

    test('hasVoted returns true for duplicate IP', () async {
      final vote = Vote(
        id: 'v1',
        pollId: 'p1',
        optionIds: const ['o1'],
        voterIp: '192.168.1.5',
        timestamp: DateTime.now(),
      );
      await repository.submitVote(vote);

      expect(await repository.hasVoted('p1', '192.168.1.5'), isTrue);
      expect(await repository.hasVoted('p1', '192.168.1.6'), isFalse);
    });

    test('getVotesForPoll returns only matching votes', () async {
      final v1 = Vote(
        id: 'v1',
        pollId: 'p1',
        optionIds: const ['o1'],
        voterIp: '1.1.1.1',
        timestamp: DateTime.now(),
      );
      final v2 = Vote(
        id: 'v2',
        pollId: 'p2',
        optionIds: const ['o2'],
        voterIp: '2.2.2.2',
        timestamp: DateTime.now(),
      );
      await repository.submitVote(v1);
      await repository.submitVote(v2);

      final result = await repository.getVotesForPoll('p1');
      expect(result.length, 1);
      expect(result.first.id, 'v1');
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
flutter test test/unit/features/poll/data/repositories/poll_repository_impl_test.dart
```

Expected: FAIL — `PollRepositoryImpl` not defined.

- [ ] **Step 3: Implement HiveStorageService**

`lib/shared/services/hive_storage_service.dart`:
```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_poll/core/constants/app_constants.dart';

class HiveStorageService {
  late Box _pollsBox;
  late Box _votesBox;
  late Box _settingsBox;

  Box get pollsBox => _pollsBox;
  Box get votesBox => _votesBox;
  Box get settingsBox => _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _pollsBox = await Hive.openBox(AppConstants.pollsBox);
    _votesBox = await Hive.openBox(AppConstants.votesBox);
    _settingsBox = await Hive.openBox(AppConstants.settingsBox);
  }
}
```

- [ ] **Step 4: Implement PollRepositoryImpl**

`lib/features/poll/data/repositories/poll_repository_impl.dart`:
```dart
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:local_poll/features/poll/data/models/poll_model.dart';
import 'package:local_poll/features/poll/data/models/vote_model.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/vote.dart';
import 'package:local_poll/features/poll/domain/repositories/poll_repository.dart';

class PollRepositoryImpl implements PollRepository {
  PollRepositoryImpl({required this.pollsBox, required this.votesBox});

  final Box pollsBox;
  final Box votesBox;

  @override
  Future<Poll> createPoll(Poll poll) async {
    final model = PollModel.fromEntity(poll);
    await pollsBox.put(poll.id, jsonEncode(model.toJson()));
    return poll;
  }

  @override
  Future<Poll?> getPoll(String id) async {
    final raw = pollsBox.get(id);
    if (raw == null) return null;
    final model = PollModel.fromJson(jsonDecode(raw as String) as Map<String, dynamic>);
    return model.toEntity();
  }

  @override
  Future<List<Poll>> getAllPolls() async {
    return pollsBox.values.map((raw) {
      final model = PollModel.fromJson(jsonDecode(raw as String) as Map<String, dynamic>);
      return model.toEntity();
    }).toList();
  }

  @override
  Future<Poll> updatePoll(Poll poll) async {
    final model = PollModel.fromEntity(poll);
    await pollsBox.put(poll.id, jsonEncode(model.toJson()));
    return poll;
  }

  @override
  Future<void> deletePoll(String id) async {
    await pollsBox.delete(id);
    // Also delete associated votes
    final voteKeys = votesBox.keys.where((key) => (key as String).startsWith('$id:'));
    for (final key in voteKeys) {
      await votesBox.delete(key);
    }
  }

  @override
  Future<Vote> submitVote(Vote vote) async {
    final model = VoteModel.fromEntity(vote);
    final key = '${vote.pollId}:${vote.voterIp}';
    await votesBox.put(key, jsonEncode(model.toJson()));
    return vote;
  }

  @override
  Future<List<Vote>> getVotesForPoll(String id) async {
    final votes = <Vote>[];
    for (final key in votesBox.keys) {
      if ((key as String).startsWith('$id:')) {
        final raw = votesBox.get(key);
        final model = VoteModel.fromJson(jsonDecode(raw as String) as Map<String, dynamic>);
        votes.add(model.toEntity());
      }
    }
    return votes;
  }

  @override
  Future<bool> hasVoted(String pollId, String voterIp) async {
    final key = '$pollId:$voterIp';
    return votesBox.containsKey(key);
  }
}
```

- [ ] **Step 5: Write use case tests**

`test/unit/features/poll/domain/usecases/create_poll_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/core/errors/app_exceptions.dart';
import 'package:local_poll/features/poll/domain/usecases/create_poll.dart';

void main() {
  group('CreatePoll', () {
    late CreatePoll createPoll;

    setUp(() {
      createPoll = CreatePoll();
    });

    test('creates poll with valid inputs', () {
      final poll = createPoll(
        question: 'Best language?',
        voteMode: VoteMode.singleChoice,
        resultsVisibility: ResultsVisibility.afterVote,
      );

      expect(poll.question, 'Best language?');
      expect(poll.status, PollStatus.draft);
      expect(poll.voteMode, VoteMode.singleChoice);
      expect(poll.resultsVisibility, ResultsVisibility.afterVote);
      expect(poll.options, isEmpty);
      expect(poll.id, isNotEmpty);
    });

    test('throws on empty question', () {
      expect(
        () => createPoll(
          question: '',
          voteMode: VoteMode.singleChoice,
          resultsVisibility: ResultsVisibility.afterVote,
        ),
        throwsA(isA<PollException>()),
      );
    });

    test('throws on question exceeding max length', () {
      expect(
        () => createPoll(
          question: 'x' * 501,
          voteMode: VoteMode.singleChoice,
          resultsVisibility: ResultsVisibility.afterVote,
        ),
        throwsA(isA<PollException>()),
      );
    });
  });
}
```

`test/unit/features/poll/domain/usecases/submit_vote_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/core/errors/app_exceptions.dart';
import 'package:local_poll/features/poll/domain/usecases/submit_vote.dart';

void main() {
  group('SubmitVote', () {
    late SubmitVote submitVote;

    setUp(() {
      submitVote = SubmitVote();
    });

    test('creates vote with valid inputs', () {
      final vote = submitVote(
        pollId: 'p1',
        optionIds: ['o1'],
        voterIp: '192.168.1.5',
      );

      expect(vote.pollId, 'p1');
      expect(vote.optionIds, ['o1']);
      expect(vote.voterIp, '192.168.1.5');
      expect(vote.id, isNotEmpty);
    });

    test('throws on empty optionIds', () {
      expect(
        () => submitVote(
          pollId: 'p1',
          optionIds: [],
          voterIp: '192.168.1.5',
        ),
        throwsA(isA<VoteException>()),
      );
    });

    test('throws on empty voterIp', () {
      expect(
        () => submitVote(
          pollId: 'p1',
          optionIds: ['o1'],
          voterIp: '',
        ),
        throwsA(isA<VoteException>()),
      );
    });
  });
}
```

- [ ] **Step 6: Implement use cases**

`lib/features/poll/domain/usecases/create_poll.dart`:
```dart
import 'package:local_poll/core/constants/app_constants.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/core/errors/app_exceptions.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:uuid/uuid.dart';

class CreatePoll {
  static const _uuid = Uuid();

  Poll call({
    required String question,
    required VoteMode voteMode,
    required ResultsVisibility resultsVisibility,
  }) {
    final trimmed = question.trim();
    if (trimmed.isEmpty) {
      throw const PollException('Question cannot be empty');
    }
    if (trimmed.length > AppConstants.maxQuestionLength) {
      throw PollException(
        'Question cannot exceed ${AppConstants.maxQuestionLength} characters',
      );
    }

    final now = DateTime.now();
    return Poll(
      id: _uuid.v4(),
      question: trimmed,
      options: const [],
      status: PollStatus.draft,
      voteMode: voteMode,
      resultsVisibility: resultsVisibility,
      createdAt: now,
      updatedAt: now,
    );
  }
}
```

`lib/features/poll/domain/usecases/add_option.dart`:
```dart
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
```

`lib/features/poll/domain/usecases/remove_option.dart`:
```dart
import 'package:local_poll/core/errors/app_exceptions.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';

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
```

`lib/features/poll/domain/usecases/submit_vote.dart`:
```dart
import 'package:local_poll/core/errors/app_exceptions.dart';
import 'package:local_poll/features/poll/domain/entities/vote.dart';
import 'package:uuid/uuid.dart';

class SubmitVote {
  static const _uuid = Uuid();

  Vote call({
    required String pollId,
    required List<String> optionIds,
    required String voterIp,
  }) {
    if (optionIds.isEmpty) {
      throw const VoteException('Must select at least one option');
    }
    if (voterIp.isEmpty) {
      throw const VoteException('Voter IP is required');
    }

    return Vote(
      id: _uuid.v4(),
      pollId: pollId,
      optionIds: optionIds,
      voterIp: voterIp,
      timestamp: DateTime.now(),
    );
  }
}
```

`lib/features/voting/domain/usecases/process_vote.dart`:
```dart
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/poll_option.dart';
import 'package:local_poll/features/poll/domain/entities/vote.dart';

class ProcessVote {
  Poll call({required Poll poll, required Vote vote}) {
    final updatedOptions = poll.options.map((option) {
      if (vote.optionIds.contains(option.id)) {
        return PollOption(
          id: option.id,
          text: option.text,
          voteCount: option.voteCount + 1,
        );
      }
      return option;
    }).toList();

    return poll.copyWith(
      options: updatedOptions,
      updatedAt: DateTime.now(),
    );
  }
}
```

- [ ] **Step 7: Run all tests**

```bash
flutter test test/unit/
```

Expected: All tests PASS.

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "feat: hive repository implementation and domain use cases"
```

---

### Task 4: State Management — Riverpod Providers

**Files:**
- Create: `lib/features/poll/presentation/providers/poll_providers.dart`
- Create: `lib/features/hosting/domain/services/local_server.dart`
- Create: `lib/features/hosting/presentation/providers/hosting_providers.dart`
- Create: `lib/features/voting/presentation/providers/voting_providers.dart`
- Create: `lib/shared/services/network_service.dart`
- Modify: `lib/main.dart` — add provider overrides for HiveStorageService

**Interfaces:**
- Consumes: `PollRepository`, `PollRepositoryImpl`, `HiveStorageService`, all entities, all use cases, enums, `AppConstants`, `NetworkUtils`
- Produces:
  - `hiveStorageServiceProvider` → `Provider<HiveStorageService>`
  - `pollRepositoryProvider` → `Provider<PollRepository>`
  - `pollListProvider` → `StateNotifierProvider<PollListNotifier, AsyncValue<List<Poll>>>`
  - `currentPollProvider` → `StateNotifierProvider<CurrentPollNotifier, Poll?>`
  - `serverStatusProvider` → `StateNotifierProvider<ServerStatusNotifier, ServerStatus>`
  - `networkInfoProvider` → `FutureProvider<String?>`
  - `serverPortProvider` → `StateNotifierProvider<ServerPortNotifier, int>`
  - `connectedClientsProvider` → `StateNotifierProvider<ConnectedClientsNotifier, int>`
  - `LocalServer` abstract class with `start()`, `stop()`, `status`, `statusStream`, `eventStream`

- [ ] **Step 1: Create LocalServer interface**

`lib/features/hosting/domain/services/local_server.dart`:
```dart
import 'package:local_poll/core/enums/server_status.dart';
import 'package:local_poll/features/poll/domain/entities/web_socket_event.dart';

abstract class LocalServer {
  Future<void> start({required int port});
  Future<void> stop();
  ServerStatus get status;
  Stream<ServerStatus> get statusStream;
  Stream<WebSocketEvent> get eventStream;
}
```

- [ ] **Step 2: Create NetworkService interface**

`lib/shared/services/network_service.dart`:
```dart
import 'package:local_poll/core/utils/network_utils.dart';

class NetworkService {
  Future<String?> getLocalIp() => NetworkUtils.getLocalIpAddress();
}
```

- [ ] **Step 3: Create poll providers**

`lib/features/poll/presentation/providers/poll_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_poll/core/constants/app_constants.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/features/poll/data/repositories/poll_repository_impl.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/repositories/poll_repository.dart';
import 'package:local_poll/features/poll/domain/usecases/create_poll.dart';
import 'package:local_poll/features/poll/domain/usecases/add_option.dart';
import 'package:local_poll/features/poll/domain/usecases/remove_option.dart';
import 'package:local_poll/shared/services/hive_storage_service.dart';
import 'package:hive/hive.dart';

final hiveStorageServiceProvider = Provider<HiveStorageService>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

final pollRepositoryProvider = Provider<PollRepository>((ref) {
  final storage = ref.watch(hiveStorageServiceProvider);
  return PollRepositoryImpl(
    pollsBox: storage.pollsBox,
    votesBox: storage.votesBox,
  );
});

final pollListProvider =
    StateNotifierProvider<PollListNotifier, AsyncValue<List<Poll>>>((ref) {
  final repository = ref.watch(pollRepositoryProvider);
  return PollListNotifier(repository);
});

class PollListNotifier extends StateNotifier<AsyncValue<List<Poll>>> {
  PollListNotifier(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final PollRepository _repository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final polls = await _repository.getAllPolls();
      state = AsyncValue.data(polls);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addPoll(Poll poll) async {
    await _repository.createPoll(poll);
    await load();
  }

  Future<void> removePoll(String id) async {
    await _repository.deletePoll(id);
    await load();
  }
}

final currentPollProvider =
    StateNotifierProvider<CurrentPollNotifier, Poll?>((ref) {
  return CurrentPollNotifier();
});

class CurrentPollNotifier extends StateNotifier<Poll?> {
  CurrentPollNotifier() : super(null);

  final _createPoll = CreatePoll();
  final _addOption = AddOption();
  final _removeOption = RemoveOption();

  void create({
    required String question,
    required VoteMode voteMode,
    required ResultsVisibility resultsVisibility,
  }) {
    state = _createPoll(
      question: question,
      voteMode: voteMode,
      resultsVisibility: resultsVisibility,
    );
  }

  void addOption(String text) {
    if (state == null) return;
    state = _addOption(poll: state!, text: text);
  }

  void removeOption(String optionId) {
    if (state == null) return;
    state = _removeOption(poll: state!, optionId: optionId);
  }

  void updateStatus(PollStatus status) {
    if (state == null) return;
    state = state!.copyWith(status: status, updatedAt: DateTime.now());
  }

  void updatePoll(Poll poll) {
    state = poll;
  }

  void clear() {
    state = null;
  }
}
```

- [ ] **Step 4: Create hosting providers**

`lib/features/hosting/presentation/providers/hosting_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_poll/core/constants/app_constants.dart';
import 'package:local_poll/core/enums/server_status.dart';
import 'package:local_poll/features/hosting/domain/services/local_server.dart';
import 'package:local_poll/shared/services/network_service.dart';

final localServerProvider = Provider<LocalServer>((ref) {
  throw UnimplementedError('Must be overridden when server is created');
});

final serverStatusProvider =
    StateNotifierProvider<ServerStatusNotifier, ServerStatus>((ref) {
  return ServerStatusNotifier();
});

class ServerStatusNotifier extends StateNotifier<ServerStatus> {
  ServerStatusNotifier() : super(ServerStatus.stopped);

  void update(ServerStatus status) {
    state = status;
  }
}

final networkInfoProvider = FutureProvider<String?>((ref) async {
  final service = NetworkService();
  return await service.getLocalIp();
});

final serverPortProvider =
    StateNotifierProvider<ServerPortNotifier, int>((ref) {
  return ServerPortNotifier();
});

class ServerPortNotifier extends StateNotifier<int> {
  ServerPortNotifier() : super(AppConstants.defaultServerPort);

  void update(int port) {
    state = port;
  }
}

final connectedClientsProvider =
    StateNotifierProvider<ConnectedClientsNotifier, int>((ref) {
  return ConnectedClientsNotifier();
});

class ConnectedClientsNotifier extends StateNotifier<int> {
  ConnectedClientsNotifier() : super(0);

  void update(int count) {
    state = count;
  }

  void increment() {
    state = state + 1;
  }

  void decrement() {
    if (state > 0) state = state - 1;
  }

  void reset() {
    state = 0;
  }
}
```

- [ ] **Step 5: Create voting providers**

`lib/features/voting/presentation/providers/voting_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/web_socket_event.dart';

final webSocketEventsProvider =
    StreamProvider<WebSocketEvent>((ref) {
  // Will be overridden when server starts
  return const Stream.empty();
});

final liveResultsProvider =
    StateNotifierProvider<LiveResultsNotifier, Poll?>((ref) {
  return LiveResultsNotifier();
});

class LiveResultsNotifier extends StateNotifier<Poll?> {
  LiveResultsNotifier() : super(null);

  void update(Poll poll) {
    state = poll;
  }

  void clear() {
    state = null;
  }
}
```

- [ ] **Step 6: Update main.dart with proper initialization**

`lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_poll/features/poll/presentation/providers/poll_providers.dart';
import 'package:local_poll/shared/services/hive_storage_service.dart';
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
      child: const LocalPollApp(),
    ),
  );
}
```

- [ ] **Step 7: Verify project compiles**

```bash
flutter analyze
```

Expected: No errors (warnings acceptable).

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "feat: riverpod state management providers"
```

---

### Task 5: Shared Widgets — Design System Components

**Files:**
- Create: `lib/shared/widgets/primary_button.dart`
- Create: `lib/shared/widgets/secondary_button.dart`
- Create: `lib/shared/widgets/poll_card.dart`
- Create: `lib/shared/widgets/option_tile.dart`
- Create: `lib/shared/widgets/result_bar.dart`
- Create: `lib/shared/widgets/qr_code_widget.dart`
- Create: `lib/shared/widgets/connection_indicator.dart`
- Create: `lib/shared/widgets/status_badge.dart`
- Create: `lib/shared/widgets/loading_view.dart`
- Create: `lib/shared/widgets/error_view.dart`
- Create: `lib/shared/widgets/empty_state.dart`
- Test: `test/widget/shared/primary_button_test.dart`
- Test: `test/widget/shared/result_bar_test.dart`
- Test: `test/widget/shared/poll_card_test.dart`

**Interfaces:**
- Consumes: `AppColors`, `AppDimensions`, `AppTextStyles`, `AppTheme`, enums
- Produces: All shared widget classes (each is a `StatelessWidget` with configurable parameters)

- [ ] **Step 1: Write widget tests**

`test/widget/shared/primary_button_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/shared/widgets/primary_button.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('PrimaryButton', () {
    testWidgets('displays label text', (tester) async {
      await tester.pumpWidget(wrap(
        PrimaryButton(label: 'Submit', onPressed: () {}),
      ));
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(wrap(
        PrimaryButton(label: 'Go', onPressed: () => pressed = true),
      ));
      await tester.tap(find.text('Go'));
      expect(pressed, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(wrap(
        const PrimaryButton(label: 'Go', onPressed: null),
      ));
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(wrap(
        PrimaryButton(label: 'Go', onPressed: () {}, isLoading: true),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Go'), findsNothing);
    });
  });
}
```

`test/widget/shared/result_bar_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/shared/widgets/result_bar.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('ResultBar', () {
    testWidgets('displays option text and vote count', (tester) async {
      await tester.pumpWidget(wrap(
        const ResultBar(text: 'Option A', voteCount: 5, totalVotes: 10),
      ));
      expect(find.text('Option A'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('displays percentage', (tester) async {
      await tester.pumpWidget(wrap(
        const ResultBar(text: 'Option A', voteCount: 3, totalVotes: 10),
      ));
      expect(find.text('30%'), findsOneWidget);
    });

    testWidgets('handles zero total votes', (tester) async {
      await tester.pumpWidget(wrap(
        const ResultBar(text: 'Option A', voteCount: 0, totalVotes: 0),
      ));
      expect(find.text('0%'), findsOneWidget);
    });
  });
}
```

`test/widget/shared/poll_card_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/shared/widgets/poll_card.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('PollCard', () {
    testWidgets('displays question and status', (tester) async {
      await tester.pumpWidget(wrap(
        PollCard(
          question: 'Best color?',
          status: PollStatus.completed,
          optionCount: 4,
          onTap: () {},
        ),
      ));
      expect(find.text('Best color?'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(
        PollCard(
          question: 'Q?',
          status: PollStatus.draft,
          optionCount: 2,
          onTap: () => tapped = true,
        ),
      ));
      await tester.tap(find.byType(PollCard));
      expect(tapped, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
flutter test test/widget/shared/
```

Expected: FAIL — widgets not defined.

- [ ] **Step 3: Implement all shared widgets**

`lib/shared/widgets/primary_button.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:local_poll/core/theme/app_colors.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';
import 'package:local_poll/core/theme/app_text_styles.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryVariant,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.disabled,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: AppDimensions.iconSizeMD,
                height: AppDimensions.iconSizeMD,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textPrimary,
                ),
              )
            : Text(label, style: AppTextStyles.button.copyWith(color: AppColors.textPrimary)),
      ),
    );
  }
}
```

`lib/shared/widgets/secondary_button.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:local_poll/core/theme/app_colors.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';
import 'package:local_poll/core/theme/app_text_styles.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
        ),
        child: Text(label, style: AppTextStyles.button.copyWith(color: AppColors.primary)),
      ),
    );
  }
}
```

`lib/shared/widgets/poll_card.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/theme/app_colors.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';
import 'package:local_poll/core/theme/app_text_styles.dart';
import 'status_badge.dart';

class PollCard extends StatelessWidget {
  const PollCard({
    super.key,
    required this.question,
    required this.status,
    required this.optionCount,
    required this.onTap,
  });

  final String question;
  final PollStatus status;
  final int optionCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(question, style: AppTextStyles.h3),
                  ),
                  StatusBadge(status: status),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingSM),
              Text(
                '$optionCount options',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

`lib/shared/widgets/option_tile.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:local_poll/core/theme/app_colors.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';
import 'package:local_poll/core/theme/app_text_styles.dart';

class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.text,
    this.onDelete,
    this.trailing,
  });

  final String text;
  final VoidCallback? onDelete;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSM),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMD,
        vertical: AppDimensions.paddingSM,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text, style: AppTextStyles.body)),
          if (trailing != null) trailing!,
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.close, size: AppDimensions.iconSizeSM),
              color: AppColors.textSecondary,
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}
```

`lib/shared/widgets/result_bar.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:local_poll/core/theme/app_colors.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';
import 'package:local_poll/core/theme/app_text_styles.dart';

class ResultBar extends StatelessWidget {
  const ResultBar({
    super.key,
    required this.text,
    required this.voteCount,
    required this.totalVotes,
  });

  final String text;
  final int voteCount;
  final int totalVotes;

  double get _percentage => totalVotes > 0 ? voteCount / totalVotes : 0;
  String get _percentLabel => '${(_percentage * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingSM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(text, style: AppTextStyles.body)),
              Text('$voteCount', style: AppTextStyles.body),
              const SizedBox(width: AppDimensions.paddingSM),
              SizedBox(
                width: 40,
                child: Text(
                  _percentLabel,
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.paddingXS),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            child: SizedBox(
              height: AppDimensions.resultBarHeight,
              child: Stack(
                children: [
                  Container(color: AppColors.surface),
                  FractionallySizedBox(
                    widthFactor: _percentage,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryVariant],
                        ),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSM),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

`lib/shared/widgets/qr_code_widget.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:local_poll/core/theme/app_colors.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';

class QRCodeWidget extends StatelessWidget {
  const QRCodeWidget({
    super.key,
    required this.data,
    this.size = AppDimensions.qrCodeSize,
  });

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: size,
        backgroundColor: AppColors.backgroundLight,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.roundedRect,
          color: AppColors.backgroundDark,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.roundedRect,
          color: AppColors.backgroundDark,
        ),
      ),
    );
  }
}
```

`lib/shared/widgets/connection_indicator.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:local_poll/core/enums/connection_status.dart';
import 'package:local_poll/core/theme/app_colors.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';
import 'package:local_poll/core/theme/app_text_styles.dart';

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({super.key, required this.status});

  final ConnectionStatus status;

  Color get _color {
    switch (status) {
      case ConnectionStatus.connected:
        return AppColors.success;
      case ConnectionStatus.connecting:
        return AppColors.warning;
      case ConnectionStatus.disconnected:
      case ConnectionStatus.error:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: AppDimensions.statusDotSize,
          height: AppDimensions.statusDotSize,
          decoration: BoxDecoration(
            color: _color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppDimensions.paddingSM),
        Text(status.label, style: AppTextStyles.caption),
      ],
    );
  }
}
```

`lib/shared/widgets/status_badge.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/theme/app_colors.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';
import 'package:local_poll/core/theme/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final PollStatus status;

  Color get _color {
    switch (status) {
      case PollStatus.draft:
        return AppColors.textSecondary;
      case PollStatus.hosting:
        return AppColors.success;
      case PollStatus.paused:
        return AppColors.warning;
      case PollStatus.completed:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingSM,
        vertical: AppDimensions.paddingXS,
      ),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.caption.copyWith(color: _color),
      ),
    );
  }
}
```

`lib/shared/widgets/loading_view.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:local_poll/core/theme/app_colors.dart';
import 'package:local_poll/core/theme/app_text_styles.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = 'Loading...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(message, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
```

`lib/shared/widgets/error_view.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:local_poll/core/theme/app_colors.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';
import 'package:local_poll/core/theme/app_text_styles.dart';
import 'secondary_button.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppDimensions.paddingMD),
            Text(message, style: AppTextStyles.body, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: AppDimensions.paddingMD),
              SecondaryButton(label: 'Retry', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
```

`lib/shared/widgets/empty_state.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:local_poll/core/theme/app_colors.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';
import 'package:local_poll/core/theme/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: AppDimensions.paddingMD),
            Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: AppDimensions.paddingSM),
              Text(subtitle!, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run widget tests**

```bash
flutter test test/widget/shared/
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: shared design system widgets"
```

---

### Task 6: Flutter UI Screens — Home, Create, Hosting, Results

**Files:**
- Create: `lib/features/poll/presentation/screens/create_poll_screen.dart`
- Create: `lib/features/poll/presentation/screens/poll_results_screen.dart`
- Create: `lib/features/poll/presentation/widgets/option_input_field.dart`
- Create: `lib/features/hosting/presentation/screens/hosting_screen.dart`
- Create: `lib/features/hosting/presentation/widgets/connected_clients_list.dart`
- Create: `lib/features/voting/presentation/screens/live_results_screen.dart`
- Create: `lib/features/poll/presentation/screens/home_screen.dart`
- Modify: `lib/app.dart` — wire up navigation
- Test: `test/widget/features/home_screen_test.dart`
- Test: `test/widget/features/create_poll_screen_test.dart`

**Interfaces:**
- Consumes: All providers from Task 4, all widgets from Task 5, all entities, enums, `AppConstants`, theme
- Produces: All screen widgets, wired navigation in `app.dart`

- [ ] **Step 1: Write screen tests**

`test/widget/features/home_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/features/poll/presentation/providers/poll_providers.dart';
import 'package:local_poll/features/poll/presentation/screens/home_screen.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';

void main() {
  Widget wrap(Widget child, {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(home: child),
    );
  }

  group('HomeScreen', () {
    testWidgets('shows empty state when no polls', (tester) async {
      await tester.pumpWidget(wrap(
        const HomeScreen(),
        overrides: [
          pollListProvider.overrideWith((ref) {
            return PollListNotifierStub([]);
          }),
        ],
      ));
      await tester.pumpAndSettle();
      expect(find.text('No polls yet'), findsOneWidget);
    });

    testWidgets('shows FAB to create poll', (tester) async {
      await tester.pumpWidget(wrap(
        const HomeScreen(),
        overrides: [
          pollListProvider.overrideWith((ref) {
            return PollListNotifierStub([]);
          }),
        ],
      ));
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}

class PollListNotifierStub extends PollListNotifier {
  PollListNotifierStub(List<Poll> polls) : super(_FakeRepo()) {
    state = AsyncValue.data(polls);
  }
}

class _FakeRepo implements PollRepository {
  @override
  Future<Poll> createPoll(Poll poll) async => poll;
  @override
  Future<void> deletePoll(String id) async {}
  @override
  Future<List<Poll>> getAllPolls() async => [];
  @override
  Future<Poll?> getPoll(String id) async => null;
  @override
  Future<List<Vote>> getVotesForPoll(String id) async => [];
  @override
  Future<bool> hasVoted(String pollId, String voterIp) async => false;
  @override
  Future<Vote> submitVote(Vote vote) async => vote;
  @override
  Future<Poll> updatePoll(Poll poll) async => poll;
}
```

Add this import to the test file:
```dart
import 'package:local_poll/features/poll/domain/repositories/poll_repository.dart';
import 'package:local_poll/features/poll/domain/entities/vote.dart';
```

`test/widget/features/create_poll_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/features/poll/presentation/screens/create_poll_screen.dart';

void main() {
  Widget wrap(Widget child) {
    return ProviderScope(child: MaterialApp(home: child));
  }

  group('CreatePollScreen', () {
    testWidgets('has question input field', (tester) async {
      await tester.pumpWidget(wrap(const CreatePollScreen()));
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('has add option button', (tester) async {
      await tester.pumpWidget(wrap(const CreatePollScreen()));
      expect(find.text('Add Option'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
flutter test test/widget/features/
```

Expected: FAIL — screens not defined.

- [ ] **Step 3: Create OptionInputField widget**

`lib/features/poll/presentation/widgets/option_input_field.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:local_poll/core/theme/app_colors.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';

class OptionInputField extends StatefulWidget {
  const OptionInputField({super.key, required this.onAdd});

  final ValueChanged<String> onAdd;

  @override
  State<OptionInputField> createState() => _OptionInputFieldState();
}

class _OptionInputFieldState extends State<OptionInputField> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onAdd(text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Enter option...'),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: AppDimensions.paddingSM),
        IconButton(
          onPressed: _submit,
          icon: const Icon(Icons.add_circle, color: AppColors.primary),
          iconSize: AppDimensions.iconSizeLG,
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Create CreatePollScreen**

`lib/features/poll/presentation/screens/create_poll_screen.dart`:
```dart
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
```

- [ ] **Step 5: Create HostingScreen**

`lib/features/hosting/presentation/screens/hosting_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/server_status.dart';
import 'package:local_poll/core/theme/app_colors.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';
import 'package:local_poll/core/theme/app_text_styles.dart';
import 'package:local_poll/features/hosting/presentation/providers/hosting_providers.dart';
import 'package:local_poll/features/poll/presentation/providers/poll_providers.dart';
import 'package:local_poll/features/poll/presentation/screens/poll_results_screen.dart';
import 'package:local_poll/shared/widgets/connection_indicator.dart';
import 'package:local_poll/shared/widgets/loading_view.dart';
import 'package:local_poll/shared/widgets/primary_button.dart';
import 'package:local_poll/shared/widgets/qr_code_widget.dart';
import 'package:local_poll/shared/widgets/result_bar.dart';
import 'package:local_poll/shared/widgets/secondary_button.dart';
import 'package:local_poll/core/enums/connection_status.dart';

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

    try {
      final server = ref.read(localServerProvider);
      await server.start(port: port);
      ref.read(serverStatusProvider.notifier).update(ServerStatus.running);
    } catch (e) {
      ref.read(serverStatusProvider.notifier).update(ServerStatus.failed);
    }
  }

  Future<void> _stopServer() async {
    try {
      final server = ref.read(localServerProvider);
      await server.stop();
    } catch (_) {}
    ref.read(serverStatusProvider.notifier).update(ServerStatus.stopped);
    ref.read(currentPollProvider.notifier).updateStatus(PollStatus.completed);
    ref.read(connectedClientsProvider.notifier).reset();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PollResultsScreen()),
      );
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
            Text('Live Results', style: AppTextStyles.h3),
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
```

- [ ] **Step 6: Create PollResultsScreen**

`lib/features/poll/presentation/screens/poll_results_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';
import 'package:local_poll/core/theme/app_text_styles.dart';
import 'package:local_poll/features/poll/presentation/providers/poll_providers.dart';
import 'package:local_poll/shared/widgets/primary_button.dart';
import 'package:local_poll/shared/widgets/result_bar.dart';

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
                // Save to history and go home
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
```

- [ ] **Step 7: Create HomeScreen**

`lib/features/poll/presentation/screens/home_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';
import 'package:local_poll/core/theme/app_text_styles.dart';
import 'package:local_poll/features/poll/presentation/providers/poll_providers.dart';
import 'package:local_poll/features/poll/presentation/screens/create_poll_screen.dart';
import 'package:local_poll/shared/widgets/empty_state.dart';
import 'package:local_poll/shared/widgets/error_view.dart';
import 'package:local_poll/shared/widgets/loading_view.dart';
import 'package:local_poll/shared/widgets/poll_card.dart';
import 'package:local_poll/core/theme/app_colors.dart';

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
                  // View past results
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
```

- [ ] **Step 8: Update app.dart with HomeScreen**

`lib/app.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:local_poll/core/theme/app_theme.dart';
import 'package:local_poll/features/poll/presentation/screens/home_screen.dart';

class LocalPollApp extends StatelessWidget {
  const LocalPollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Poll',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
```

- [ ] **Step 9: Create ConnectedClientsList and LiveResultsScreen stubs**

`lib/features/hosting/presentation/widgets/connected_clients_list.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:local_poll/core/theme/app_dimensions.dart';
import 'package:local_poll/core/theme/app_text_styles.dart';

class ConnectedClientsList extends StatelessWidget {
  const ConnectedClientsList({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      child: Text('$count clients connected', style: AppTextStyles.body),
    );
  }
}
```

`lib/features/voting/presentation/screens/live_results_screen.dart`:
```dart
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
```

- [ ] **Step 10: Run tests**

```bash
flutter test test/widget/features/
```

Expected: All tests PASS.

- [ ] **Step 11: Commit**

```bash
git add -A
git commit -m "feat: all flutter UI screens with navigation"
```

---

### Task 7: Local Server — Shelf HTTP + WebSocket

**Files:**
- Create: `lib/features/hosting/data/server/local_server_impl.dart`
- Create: `lib/features/hosting/data/server/api_handler.dart`
- Create: `lib/features/hosting/data/server/websocket_handler.dart`
- Create: `lib/features/hosting/domain/usecases/start_server.dart`
- Create: `lib/features/hosting/domain/usecases/stop_server.dart`
- Test: `test/unit/features/hosting/data/server/api_handler_test.dart`
- Test: `test/integration/server_test.dart`

**Interfaces:**
- Consumes: `LocalServer` interface, `PollRepository`, `Poll`, `Vote`, `WebSocketEvent`, `EventType`, `ServerStatus`, `AppConstants`, `ProcessVote`
- Produces:
  - `ShelfLocalServer` implements `LocalServer`
  - `ApiHandler` with `Router get router`
  - `WebSocketHandler` with `Handler get handler`, `broadcast(WebSocketEvent)`, `int get clientCount`
  - `StartServer` use case: `call({required LocalServer server, required int port})` → `Future<void>`
  - `StopServer` use case: `call({required LocalServer server})` → `Future<void>`

- [ ] **Step 1: Write API handler tests**

`test/unit/features/hosting/data/server/api_handler_test.dart`:
```dart
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/features/hosting/data/server/api_handler.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/poll_option.dart';
import 'package:shelf/shelf.dart';

void main() {
  late ApiHandler handler;
  late Poll testPoll;

  setUp(() {
    final now = DateTime.now();
    testPoll = Poll(
      id: 'p1',
      question: 'Best?',
      options: const [
        PollOption(id: 'o1', text: 'A', voteCount: 0),
        PollOption(id: 'o2', text: 'B', voteCount: 0),
      ],
      status: PollStatus.hosting,
      voteMode: VoteMode.singleChoice,
      resultsVisibility: ResultsVisibility.afterVote,
      createdAt: now,
      updatedAt: now,
    );
    handler = ApiHandler(
      getPoll: () => testPoll,
      onVote: (optionIds, ip) async => true,
      getClientCount: () => 2,
    );
  });

  group('ApiHandler', () {
    test('GET /api/poll returns poll JSON', () async {
      final request = Request('GET', Uri.parse('http://localhost/api/poll'));
      final response = await handler.router.call(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['question'], 'Best?');
      expect(body['options'], hasLength(2));
    });

    test('GET /api/status returns server status', () async {
      final request = Request('GET', Uri.parse('http://localhost/api/status'));
      final response = await handler.router.call(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['status'], 'running');
      expect(body['connectedClients'], 2);
    });

    test('POST /api/vote accepts valid vote', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/api/vote'),
        body: jsonEncode({'optionIds': ['o1']}),
        headers: {'content-type': 'application/json'},
      );
      final response = await handler.router.call(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['success'], true);
    });
  });
}
```

- [ ] **Step 2: Run tests to verify they fail**

```bash
flutter test test/unit/features/hosting/data/server/api_handler_test.dart
```

Expected: FAIL — `ApiHandler` not defined.

- [ ] **Step 3: Implement WebSocketHandler**

`lib/features/hosting/data/server/websocket_handler.dart`:
```dart
import 'dart:convert';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:local_poll/core/enums/event_type.dart';
import 'package:local_poll/features/poll/domain/entities/web_socket_event.dart';

class WebSocketHandler {
  final _clients = <WebSocketChannel>[];
  final void Function(int count)? onClientCountChanged;

  WebSocketHandler({this.onClientCountChanged});

  int get clientCount => _clients.length;

  Handler get handler => webSocketHandler((WebSocketChannel channel) {
        _clients.add(channel);
        onClientCountChanged?.call(_clients.length);

        channel.stream.listen(
          (_) {},
          onDone: () {
            _clients.remove(channel);
            onClientCountChanged?.call(_clients.length);
          },
          onError: (_) {
            _clients.remove(channel);
            onClientCountChanged?.call(_clients.length);
          },
        );
      });

  void broadcast(WebSocketEvent event) {
    final message = jsonEncode({
      'type': event.type.toJson(),
      'data': event.data,
    });

    final closedClients = <WebSocketChannel>[];
    for (final client in _clients) {
      try {
        client.sink.add(message);
      } catch (_) {
        closedClients.add(client);
      }
    }
    for (final client in closedClients) {
      _clients.remove(client);
    }
    if (closedClients.isNotEmpty) {
      onClientCountChanged?.call(_clients.length);
    }
  }

  void closeAll() {
    for (final client in _clients) {
      try {
        client.sink.close();
      } catch (_) {}
    }
    _clients.clear();
    onClientCountChanged?.call(0);
  }
}

typedef Handler = dynamic Function(dynamic);
```

Wait — `Handler` is already defined by shelf. Remove the typedef at the bottom and use the proper import:

`lib/features/hosting/data/server/websocket_handler.dart` (corrected):
```dart
import 'dart:convert';
import 'package:shelf/shelf.dart' show Handler;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:local_poll/features/poll/domain/entities/web_socket_event.dart';

class WebSocketHandler {
  final _clients = <WebSocketChannel>[];
  final void Function(int count)? onClientCountChanged;

  WebSocketHandler({this.onClientCountChanged});

  int get clientCount => _clients.length;

  Handler get handler => webSocketHandler((WebSocketChannel channel) {
        _clients.add(channel);
        onClientCountChanged?.call(_clients.length);

        channel.stream.listen(
          (_) {},
          onDone: () {
            _clients.remove(channel);
            onClientCountChanged?.call(_clients.length);
          },
          onError: (_) {
            _clients.remove(channel);
            onClientCountChanged?.call(_clients.length);
          },
        );
      });

  void broadcast(WebSocketEvent event) {
    final message = jsonEncode({
      'type': event.type.toJson(),
      'data': event.data,
    });

    final closedClients = <WebSocketChannel>[];
    for (final client in _clients) {
      try {
        client.sink.add(message);
      } catch (_) {
        closedClients.add(client);
      }
    }
    for (final client in closedClients) {
      _clients.remove(client);
    }
    if (closedClients.isNotEmpty) {
      onClientCountChanged?.call(_clients.length);
    }
  }

  void closeAll() {
    for (final client in _clients) {
      try {
        client.sink.close();
      } catch (_) {}
    }
    _clients.clear();
    onClientCountChanged?.call(0);
  }
}
```

- [ ] **Step 4: Implement ApiHandler**

`lib/features/hosting/data/server/api_handler.dart`:
```dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:local_poll/features/poll/data/models/poll_model.dart';
import 'package:local_poll/features/poll/data/models/poll_option_model.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';

class ApiHandler {
  ApiHandler({
    required this.getPoll,
    required this.onVote,
    required this.getClientCount,
  });

  final Poll Function() getPoll;
  final Future<bool> Function(List<String> optionIds, String ip) onVote;
  final int Function() getClientCount;

  Router get router {
    final router = Router();

    router.get('/api/poll', _handleGetPoll);
    router.get('/api/results', _handleGetResults);
    router.get('/api/status', _handleGetStatus);
    router.post('/api/vote', _handleVote);

    return router;
  }

  Response _handleGetPoll(Request request) {
    final poll = getPoll();
    final body = {
      'id': poll.id,
      'question': poll.question,
      'options': poll.options
          .map((o) => {'id': o.id, 'text': o.text})
          .toList(),
      'voteMode': poll.voteMode.toJson(),
      'resultsVisibility': poll.resultsVisibility.toJson(),
    };
    return Response.ok(
      jsonEncode(body),
      headers: _jsonHeaders,
    );
  }

  Response _handleGetResults(Request request) {
    final poll = getPoll();
    final totalVotes = poll.options.fold<int>(0, (sum, o) => sum + o.voteCount);
    final body = {
      'options': poll.options
          .map((o) => {'id': o.id, 'text': o.text, 'voteCount': o.voteCount})
          .toList(),
      'totalVotes': totalVotes,
      'visibility': poll.resultsVisibility.toJson(),
    };
    return Response.ok(
      jsonEncode(body),
      headers: _jsonHeaders,
    );
  }

  Response _handleGetStatus(Request request) {
    return Response.ok(
      jsonEncode({
        'status': 'running',
        'connectedClients': getClientCount(),
      }),
      headers: _jsonHeaders,
    );
  }

  Future<Response> _handleVote(Request request) async {
    try {
      final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
      final optionIds = (body['optionIds'] as List).cast<String>();

      // Extract client IP
      final connectionInfo = request.context['shelf.io.connection_info'];
      final ip = connectionInfo != null
          ? (connectionInfo as dynamic).remoteAddress.address as String
          : request.headers['x-forwarded-for'] ?? 'unknown';

      final success = await onVote(optionIds, ip);

      if (!success) {
        return Response.ok(
          jsonEncode({'error': 'already_voted'}),
          headers: _jsonHeaders,
        );
      }

      return Response.ok(
        jsonEncode({'success': true}),
        headers: _jsonHeaders,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
        headers: _jsonHeaders,
      );
    }
  }

  static const _jsonHeaders = {
    'content-type': 'application/json',
    'access-control-allow-origin': '*',
    'access-control-allow-methods': 'GET, POST, OPTIONS',
    'access-control-allow-headers': 'content-type',
  };
}
```

- [ ] **Step 5: Implement ShelfLocalServer**

`lib/features/hosting/data/server/local_server_impl.dart`:
```dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:local_poll/core/enums/event_type.dart';
import 'package:local_poll/core/enums/server_status.dart';
import 'package:local_poll/features/hosting/data/server/api_handler.dart';
import 'package:local_poll/features/hosting/data/server/websocket_handler.dart';
import 'package:local_poll/features/hosting/domain/services/local_server.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/web_socket_event.dart';

class ShelfLocalServer implements LocalServer {
  ShelfLocalServer({
    required this.getPoll,
    required this.onVote,
    required this.onClientCountChanged,
  });

  final Poll Function() getPoll;
  final Future<bool> Function(List<String> optionIds, String ip) onVote;
  final void Function(int count) onClientCountChanged;

  HttpServer? _server;
  ServerStatus _status = ServerStatus.stopped;
  final _statusController = StreamController<ServerStatus>.broadcast();
  final _eventController = StreamController<WebSocketEvent>.broadcast();
  late WebSocketHandler _wsHandler;

  // Cached browser client assets
  String? _indexHtml;
  String? _styleCss;
  String? _appJs;

  @override
  ServerStatus get status => _status;

  @override
  Stream<ServerStatus> get statusStream => _statusController.stream;

  @override
  Stream<WebSocketEvent> get eventStream => _eventController.stream;

  WebSocketHandler get wsHandler => _wsHandler;

  void _setStatus(ServerStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  Future<void> _loadAssets() async {
    _indexHtml = await rootBundle.loadString('assets/browser_client/index.html');
    _styleCss = await rootBundle.loadString('assets/browser_client/style.css');
    _appJs = await rootBundle.loadString('assets/browser_client/app.js');
  }

  @override
  Future<void> start({required int port}) async {
    if (_status == ServerStatus.running) return;
    _setStatus(ServerStatus.starting);

    try {
      await _loadAssets();

      _wsHandler = WebSocketHandler(
        onClientCountChanged: (count) {
          onClientCountChanged(count);
          _eventController.add(WebSocketEvent(
            type: EventType.userJoined,
            data: {'clientCount': count},
          ));
        },
      );

      final apiHandler = ApiHandler(
        getPoll: getPoll,
        onVote: onVote,
        getClientCount: () => _wsHandler.clientCount,
      );

      final router = Router();

      // Static files
      router.get('/', (shelf.Request req) => shelf.Response.ok(
            _indexHtml,
            headers: {'content-type': 'text/html'},
          ));
      router.get('/style.css', (shelf.Request req) => shelf.Response.ok(
            _styleCss,
            headers: {'content-type': 'text/css'},
          ));
      router.get('/app.js', (shelf.Request req) => shelf.Response.ok(
            _appJs,
            headers: {'content-type': 'application/javascript'},
          ));

      // WebSocket
      router.get('/ws', _wsHandler.handler);

      // API routes
      router.mount('/api/', apiHandler.router.call);

      // CORS preflight
      router.options(
        '/<ignored|.*>',
        (shelf.Request req) => shelf.Response.ok('', headers: {
          'access-control-allow-origin': '*',
          'access-control-allow-methods': 'GET, POST, OPTIONS',
          'access-control-allow-headers': 'content-type',
        }),
      );

      final handler = const shelf.Pipeline()
          .addMiddleware(shelf.logRequests())
          .addHandler(router.call);

      _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
      _setStatus(ServerStatus.running);
    } catch (e) {
      _setStatus(ServerStatus.failed);
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    _wsHandler.closeAll();
    await _server?.close(force: true);
    _server = null;
    _setStatus(ServerStatus.stopped);
  }

  void broadcastEvent(WebSocketEvent event) {
    _wsHandler.broadcast(event);
    _eventController.add(event);
  }
}
```

- [ ] **Step 6: Create server use cases**

`lib/features/hosting/domain/usecases/start_server.dart`:
```dart
import 'package:local_poll/features/hosting/domain/services/local_server.dart';

class StartServer {
  Future<void> call({required LocalServer server, required int port}) async {
    await server.start(port: port);
  }
}
```

`lib/features/hosting/domain/usecases/stop_server.dart`:
```dart
import 'package:local_poll/features/hosting/domain/services/local_server.dart';

class StopServer {
  Future<void> call({required LocalServer server}) async {
    await server.stop();
  }
}
```

- [ ] **Step 7: Run API handler tests**

```bash
flutter test test/unit/features/hosting/data/server/api_handler_test.dart
```

Expected: All tests PASS.

- [ ] **Step 8: Write integration test**

`test/integration/server_test.dart`:
```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/features/hosting/data/server/api_handler.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/poll_option.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

void main() {
  late HttpServer server;
  late Poll testPoll;
  final votedIps = <String>{};

  setUp(() async {
    final now = DateTime.now();
    testPoll = Poll(
      id: 'p1',
      question: 'Test?',
      options: const [
        PollOption(id: 'o1', text: 'A', voteCount: 0),
        PollOption(id: 'o2', text: 'B', voteCount: 0),
      ],
      status: PollStatus.hosting,
      voteMode: VoteMode.singleChoice,
      resultsVisibility: ResultsVisibility.afterVote,
      createdAt: now,
      updatedAt: now,
    );

    final handler = ApiHandler(
      getPoll: () => testPoll,
      onVote: (optionIds, ip) async {
        if (votedIps.contains(ip)) return false;
        votedIps.add(ip);
        return true;
      },
      getClientCount: () => 0,
    );

    server = await shelf_io.serve(handler.router.call, 'localhost', 0);
  });

  tearDown(() async {
    votedIps.clear();
    await server.close(force: true);
  });

  test('GET /api/poll returns poll data', () async {
    final client = HttpClient();
    final request = await client.get('localhost', server.port, '/api/poll');
    final response = await request.close();
    final body = jsonDecode(await response.transform(utf8.decoder).join());

    expect(response.statusCode, 200);
    expect(body['question'], 'Test?');
    client.close();
  });

  test('POST /api/vote accepts and rejects duplicate', () async {
    final client = HttpClient();

    // First vote
    var request = await client.post('localhost', server.port, '/api/vote');
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({'optionIds': ['o1']}));
    var response = await request.close();
    var body = jsonDecode(await response.transform(utf8.decoder).join());
    expect(body['success'], true);

    // Duplicate vote
    request = await client.post('localhost', server.port, '/api/vote');
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({'optionIds': ['o2']}));
    response = await request.close();
    body = jsonDecode(await response.transform(utf8.decoder).join());
    expect(body['error'], 'already_voted');

    client.close();
  });
}
```

- [ ] **Step 9: Run integration test**

```bash
flutter test test/integration/server_test.dart
```

Expected: All tests PASS.

- [ ] **Step 10: Commit**

```bash
git add -A
git commit -m "feat: shelf HTTP server with REST API and WebSocket support"
```

---

### Task 8: Browser Client — Voting Interface

**Files:**
- Create: `assets/browser_client/index.html`
- Create: `assets/browser_client/style.css`
- Create: `assets/browser_client/app.js`

**Interfaces:**
- Consumes: API contracts (GET /api/poll, POST /api/vote, GET /api/results, GET /ws)
- Produces: Complete browser voting app served by shelf server

- [ ] **Step 1: Create index.html**

`assets/browser_client/index.html`:
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
  <title>Local Poll</title>
  <link rel="stylesheet" href="/style.css">
</head>
<body>
  <div id="app">
    <div id="loading" class="screen active">
      <div class="spinner"></div>
      <p>Connecting to poll...</p>
    </div>

    <div id="voting" class="screen">
      <h1 id="question"></h1>
      <div id="options"></div>
      <button id="submit-btn" class="btn-primary" disabled>Submit Vote</button>
    </div>

    <div id="submitted" class="screen">
      <div class="check-icon">&#10003;</div>
      <h2>Vote Recorded!</h2>
      <div id="results-after-vote"></div>
    </div>

    <div id="waiting" class="screen">
      <div class="check-icon">&#10003;</div>
      <h2>Vote Recorded!</h2>
      <p>Results will be revealed by the host.</p>
    </div>

    <div id="results" class="screen">
      <h2>Results</h2>
      <div id="results-container"></div>
      <p id="total-votes"></p>
    </div>

    <div id="ended" class="screen">
      <h2>Poll Ended</h2>
      <div id="final-results"></div>
      <p id="final-total"></p>
    </div>

    <div id="error" class="screen">
      <div class="error-icon">!</div>
      <h2>Connection Error</h2>
      <p id="error-message">Could not connect to poll.</p>
      <button class="btn-secondary" onclick="location.reload()">Retry</button>
    </div>
  </div>

  <div id="connection-status">
    <span id="status-dot"></span>
    <span id="status-text">Connecting</span>
  </div>

  <script src="/app.js"></script>
</body>
</html>
```

- [ ] **Step 2: Create style.css**

`assets/browser_client/style.css`:
```css
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background-color: #0A0A0F;
  color: #F8F8FF;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
}

#app {
  width: 100%;
  max-width: 480px;
  padding: 24px 16px;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.screen {
  display: none;
  flex-direction: column;
  flex: 1;
}

.screen.active {
  display: flex;
}

h1 {
  font-size: 24px;
  font-weight: 700;
  margin-bottom: 24px;
  text-align: center;
  line-height: 1.3;
}

h2 {
  font-size: 20px;
  font-weight: 700;
  margin-bottom: 16px;
  text-align: center;
}

/* Loading */
#loading {
  justify-content: center;
  align-items: center;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 3px solid #2E2840;
  border-top-color: #33CCFF;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Options */
.option-item {
  background: #2E2840;
  border: 2px solid transparent;
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  transition: border-color 0.2s, background 0.2s;
  -webkit-tap-highlight-color: transparent;
}

.option-item:hover {
  background: #3D3555;
}

.option-item.selected {
  border-color: #33CCFF;
  background: #2E2840;
}

.option-item input {
  display: none;
}

.option-indicator {
  width: 22px;
  height: 22px;
  border: 2px solid #B0A8C0;
  border-radius: 50%;
  margin-right: 12px;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: border-color 0.2s, background 0.2s;
}

.option-item.multi .option-indicator {
  border-radius: 4px;
}

.option-item.selected .option-indicator {
  border-color: #33CCFF;
  background: #33CCFF;
}

.option-indicator-inner {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #0A0A0F;
  display: none;
}

.option-item.multi .option-indicator-inner {
  border-radius: 2px;
  width: 12px;
  height: 12px;
}

.option-item.selected .option-indicator-inner {
  display: block;
}

.option-text {
  font-size: 16px;
  line-height: 1.4;
}

/* Buttons */
.btn-primary {
  width: 100%;
  padding: 16px;
  background: #2244EE;
  color: #F8F8FF;
  border: none;
  border-radius: 12px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  margin-top: 24px;
  transition: opacity 0.2s;
  -webkit-tap-highlight-color: transparent;
}

.btn-primary:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.btn-primary:not(:disabled):hover {
  opacity: 0.9;
}

.btn-secondary {
  width: 100%;
  padding: 16px;
  background: transparent;
  color: #33CCFF;
  border: 2px solid #33CCFF;
  border-radius: 12px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  margin-top: 16px;
  -webkit-tap-highlight-color: transparent;
}

/* Check/Error icons */
.check-icon {
  width: 64px;
  height: 64px;
  background: #4CAF50;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  margin: 0 auto 16px;
}

.error-icon {
  width: 64px;
  height: 64px;
  background: #EF5350;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  font-weight: bold;
  margin: 0 auto 16px;
}

/* Result bars */
.result-item {
  margin-bottom: 12px;
}

.result-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 4px;
}

.result-text {
  font-size: 14px;
  flex: 1;
}

.result-count {
  font-size: 14px;
  margin-left: 8px;
  margin-right: 8px;
}

.result-percent {
  font-size: 12px;
  color: #B0A8C0;
  min-width: 36px;
  text-align: right;
}

.result-bar-bg {
  height: 32px;
  background: #2E2840;
  border-radius: 8px;
  overflow: hidden;
}

.result-bar-fill {
  height: 100%;
  background: linear-gradient(90deg, #33CCFF, #2244EE);
  border-radius: 8px;
  transition: width 0.5s ease;
  min-width: 0;
}

#total-votes, #final-total {
  text-align: center;
  color: #B0A8C0;
  font-size: 14px;
  margin-top: 16px;
}

/* Connection status */
#connection-status {
  position: fixed;
  top: 12px;
  right: 12px;
  display: flex;
  align-items: center;
  font-size: 12px;
  color: #B0A8C0;
}

#status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #FFB74D;
  margin-right: 6px;
}

#status-dot.connected { background: #4CAF50; }
#status-dot.error { background: #EF5350; }
#status-dot.connecting { background: #FFB74D; }

/* Submitted / waiting centering */
#submitted, #waiting {
  justify-content: center;
  align-items: center;
}

#error {
  justify-content: center;
  align-items: center;
}
```

- [ ] **Step 3: Create app.js**

`assets/browser_client/app.js`:
```javascript
(function() {
  'use strict';

  var state = {
    poll: null,
    selected: [],
    voted: false,
    wsConnected: false
  };

  var ws = null;
  var reconnectDelay = 1000;
  var maxReconnectDelay = 10000;

  // DOM helpers
  function $(id) { return document.getElementById(id); }

  function showScreen(name) {
    var screens = document.querySelectorAll('.screen');
    for (var i = 0; i < screens.length; i++) {
      screens[i].classList.remove('active');
    }
    $(name).classList.add('active');
  }

  function setConnectionStatus(status) {
    var dot = $('status-dot');
    var text = $('status-text');
    dot.className = status;
    text.textContent = status === 'connected' ? 'Connected' :
                       status === 'connecting' ? 'Connecting...' :
                       'Disconnected';
  }

  // API
  function fetchPoll() {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/api/poll', true);
    xhr.onload = function() {
      if (xhr.status === 200) {
        state.poll = JSON.parse(xhr.responseText);
        renderVoting();
      } else {
        showError('Could not load poll.');
      }
    };
    xhr.onerror = function() {
      showError('Could not connect to server.');
    };
    xhr.send();
  }

  function submitVote() {
    if (state.selected.length === 0) return;

    var btn = $('submit-btn');
    btn.disabled = true;
    btn.textContent = 'Submitting...';

    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/api/vote', true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.onload = function() {
      var res = JSON.parse(xhr.responseText);
      if (res.success) {
        state.voted = true;
        if (state.poll.resultsVisibility === 'afterVote' || state.poll.resultsVisibility === 'live') {
          fetchAndShowResults('results-after-vote');
          showScreen('submitted');
        } else {
          showScreen('waiting');
        }
      } else if (res.error === 'already_voted') {
        state.voted = true;
        fetchAndShowResults('results-after-vote');
        showScreen('submitted');
      } else {
        showError(res.error || 'Vote failed.');
      }
    };
    xhr.onerror = function() {
      btn.disabled = false;
      btn.textContent = 'Submit Vote';
      showError('Could not submit vote.');
    };
    xhr.send(JSON.stringify({ optionIds: state.selected }));
  }

  function fetchAndShowResults(containerId) {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/api/results', true);
    xhr.onload = function() {
      if (xhr.status === 200) {
        var data = JSON.parse(xhr.responseText);
        renderResults(containerId, data);
      }
    };
    xhr.send();
  }

  // Rendering
  function renderVoting() {
    if (!state.poll) return;

    $('question').textContent = state.poll.question;
    var container = $('options');
    container.innerHTML = '';

    var isMulti = state.poll.voteMode === 'multipleChoice';

    for (var i = 0; i < state.poll.options.length; i++) {
      var opt = state.poll.options[i];
      var div = document.createElement('div');
      div.className = 'option-item' + (isMulti ? ' multi' : '');
      div.setAttribute('data-id', opt.id);
      div.innerHTML =
        '<div class="option-indicator"><div class="option-indicator-inner"></div></div>' +
        '<span class="option-text">' + escapeHtml(opt.text) + '</span>';

      div.addEventListener('click', (function(optId) {
        return function() { toggleOption(optId, isMulti); };
      })(opt.id));

      container.appendChild(div);
    }

    showScreen('voting');
  }

  function toggleOption(optId, isMulti) {
    if (isMulti) {
      var idx = state.selected.indexOf(optId);
      if (idx > -1) {
        state.selected.splice(idx, 1);
      } else {
        state.selected.push(optId);
      }
    } else {
      state.selected = [optId];
    }
    updateOptionUI();
  }

  function updateOptionUI() {
    var items = document.querySelectorAll('.option-item');
    for (var i = 0; i < items.length; i++) {
      var id = items[i].getAttribute('data-id');
      if (state.selected.indexOf(id) > -1) {
        items[i].classList.add('selected');
      } else {
        items[i].classList.remove('selected');
      }
    }
    $('submit-btn').disabled = state.selected.length === 0;
  }

  function renderResults(containerId, data) {
    var container = $(containerId);
    if (!container) return;
    container.innerHTML = '';

    for (var i = 0; i < data.options.length; i++) {
      var opt = data.options[i];
      var pct = data.totalVotes > 0 ? Math.round((opt.voteCount / data.totalVotes) * 100) : 0;
      var div = document.createElement('div');
      div.className = 'result-item';
      div.innerHTML =
        '<div class="result-header">' +
          '<span class="result-text">' + escapeHtml(opt.text) + '</span>' +
          '<span class="result-count">' + opt.voteCount + '</span>' +
          '<span class="result-percent">' + pct + '%</span>' +
        '</div>' +
        '<div class="result-bar-bg">' +
          '<div class="result-bar-fill" style="width:' + pct + '%"></div>' +
        '</div>';
      container.appendChild(div);
    }

    // Total votes display
    var totalEl = containerId === 'final-results' ? $('final-total') : $('total-votes');
    if (totalEl) {
      totalEl.textContent = data.totalVotes + ' total votes';
    }
  }

  function showError(msg) {
    $('error-message').textContent = msg;
    showScreen('error');
  }

  function escapeHtml(str) {
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  }

  // WebSocket
  function connectWs() {
    var protocol = location.protocol === 'https:' ? 'wss:' : 'ws:';
    var url = protocol + '//' + location.host + '/ws';

    setConnectionStatus('connecting');

    try {
      ws = new WebSocket(url);
    } catch (e) {
      setConnectionStatus('error');
      scheduleReconnect();
      return;
    }

    ws.onopen = function() {
      state.wsConnected = true;
      reconnectDelay = 1000;
      setConnectionStatus('connected');
    };

    ws.onmessage = function(event) {
      try {
        var msg = JSON.parse(event.data);
        handleWsMessage(msg);
      } catch (e) {}
    };

    ws.onclose = function() {
      state.wsConnected = false;
      setConnectionStatus('error');
      scheduleReconnect();
    };

    ws.onerror = function() {
      state.wsConnected = false;
      setConnectionStatus('error');
    };
  }

  function scheduleReconnect() {
    setTimeout(function() {
      connectWs();
    }, reconnectDelay);
    reconnectDelay = Math.min(reconnectDelay * 2, maxReconnectDelay);
  }

  function handleWsMessage(msg) {
    switch (msg.type) {
      case 'results_updated':
        if (state.voted) {
          renderResults('results-after-vote', msg.data);
        }
        break;
      case 'poll_ended':
        fetchAndShowResults('final-results');
        showScreen('ended');
        break;
      case 'vote_submitted':
        // Update total votes if showing results
        break;
    }
  }

  // Submit button
  $('submit-btn').addEventListener('click', submitVote);

  // Init
  fetchPoll();
  connectWs();
})();
```

- [ ] **Step 4: Verify assets exist**

```bash
ls -la /Users/nolandmello/DemocracyJS/assets/browser_client/
```

Expected: `index.html`, `style.css`, `app.js` all present.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "feat: browser voting client with dark theme and WebSocket support"
```

---

### Task 9: Integration — Wire Server to Providers + mDNS

**Files:**
- Modify: `lib/features/hosting/presentation/providers/hosting_providers.dart` — wire `ShelfLocalServer` creation
- Modify: `lib/features/hosting/presentation/screens/hosting_screen.dart` — integrate server with providers
- Modify: `lib/features/poll/presentation/providers/poll_providers.dart` — add repository save on vote
- Create: `lib/shared/services/mdns_service.dart`
- Modify: `lib/main.dart` — register Hive adapters if needed

**Interfaces:**
- Consumes: `ShelfLocalServer`, all providers, `PollRepository`, `ProcessVote`, `bonsoir` package, all entities
- Produces:
  - `MdnsService` with `register({required String name, required int port})`, `unregister()`
  - Updated hosting providers that create `ShelfLocalServer` instance and wire vote processing

- [ ] **Step 1: Create mDNS service**

`lib/shared/services/mdns_service.dart`:
```dart
import 'package:bonsoir/bonsoir.dart';
import 'package:local_poll/core/constants/app_constants.dart';

class MdnsService {
  BonsoirBroadcast? _broadcast;

  Future<void> register({required String name, required int port}) async {
    final service = BonsoirService(
      name: name,
      type: AppConstants.mDnsServiceType,
      port: port,
    );
    _broadcast = BonsoirBroadcast(service: service);
    await _broadcast!.ready;
    await _broadcast!.start();
  }

  Future<void> unregister() async {
    await _broadcast?.stop();
    _broadcast = null;
  }
}
```

- [ ] **Step 2: Update hosting providers to create real server**

`lib/features/hosting/presentation/providers/hosting_providers.dart` — replace `localServerProvider`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_poll/core/constants/app_constants.dart';
import 'package:local_poll/core/enums/event_type.dart';
import 'package:local_poll/core/enums/server_status.dart';
import 'package:local_poll/features/hosting/data/server/local_server_impl.dart';
import 'package:local_poll/features/hosting/domain/services/local_server.dart';
import 'package:local_poll/features/poll/domain/entities/web_socket_event.dart';
import 'package:local_poll/features/poll/presentation/providers/poll_providers.dart';
import 'package:local_poll/features/poll/domain/usecases/submit_vote.dart';
import 'package:local_poll/features/voting/domain/usecases/process_vote.dart';
import 'package:local_poll/shared/services/mdns_service.dart';
import 'package:local_poll/shared/services/network_service.dart';

final localServerProvider = Provider<ShelfLocalServer>((ref) {
  final processVote = ProcessVote();
  final submitVoteUseCase = SubmitVote();

  return ShelfLocalServer(
    getPoll: () => ref.read(currentPollProvider)!,
    onVote: (optionIds, ip) async {
      final repo = ref.read(pollRepositoryProvider);
      final poll = ref.read(currentPollProvider);
      if (poll == null) return false;

      final alreadyVoted = await repo.hasVoted(poll.id, ip);
      if (alreadyVoted) return false;

      final vote = submitVoteUseCase(
        pollId: poll.id,
        optionIds: optionIds,
        voterIp: ip,
      );
      await repo.submitVote(vote);

      final updatedPoll = processVote(poll: poll, vote: vote);
      await repo.updatePoll(updatedPoll);
      ref.read(currentPollProvider.notifier).updatePoll(updatedPoll);

      return true;
    },
    onClientCountChanged: (count) {
      ref.read(connectedClientsProvider.notifier).update(count);
    },
  );
});

final mdnsServiceProvider = Provider<MdnsService>((ref) {
  return MdnsService();
});

final serverStatusProvider =
    StateNotifierProvider<ServerStatusNotifier, ServerStatus>((ref) {
  return ServerStatusNotifier();
});

class ServerStatusNotifier extends StateNotifier<ServerStatus> {
  ServerStatusNotifier() : super(ServerStatus.stopped);

  void update(ServerStatus status) {
    state = status;
  }
}

final networkInfoProvider = FutureProvider<String?>((ref) async {
  final service = NetworkService();
  return await service.getLocalIp();
});

final serverPortProvider =
    StateNotifierProvider<ServerPortNotifier, int>((ref) {
  return ServerPortNotifier();
});

class ServerPortNotifier extends StateNotifier<int> {
  ServerPortNotifier() : super(AppConstants.defaultServerPort);

  void update(int port) {
    state = port;
  }
}

final connectedClientsProvider =
    StateNotifierProvider<ConnectedClientsNotifier, int>((ref) {
  return ConnectedClientsNotifier();
});

class ConnectedClientsNotifier extends StateNotifier<int> {
  ConnectedClientsNotifier() : super(0);

  void update(int count) {
    state = count;
  }

  void increment() {
    state = state + 1;
  }

  void decrement() {
    if (state > 0) state = state - 1;
  }

  void reset() {
    state = 0;
  }
}
```

- [ ] **Step 3: Update HostingScreen to use mDNS and broadcast events**

Update `_startServer` in `lib/features/hosting/presentation/screens/hosting_screen.dart`:

Replace the `_startServer` method body:
```dart
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
```

Replace the `_stopServer` method body:
```dart
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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PollResultsScreen()),
      );
    }
  }
```

Add required imports to hosting_screen.dart:
```dart
import 'package:local_poll/core/constants/app_constants.dart';
import 'package:local_poll/core/enums/event_type.dart';
import 'package:local_poll/features/poll/domain/entities/web_socket_event.dart';
```

- [ ] **Step 4: Update server to broadcast vote events**

In `lib/features/hosting/presentation/providers/hosting_providers.dart`, update the `onVote` callback in `localServerProvider` to broadcast after successful vote:

After `ref.read(currentPollProvider.notifier).updatePoll(updatedPoll);` add:

```dart
      // Broadcast results update
      final server = ref.read(localServerProvider);
      server.broadcastEvent(WebSocketEvent(
        type: EventType.resultsUpdated,
        data: {
          'options': updatedPoll.options
              .map((o) => {'id': o.id, 'text': o.text, 'voteCount': o.voteCount})
              .toList(),
          'totalVotes': updatedPoll.options.fold<int>(0, (sum, o) => sum + o.voteCount),
        },
      ));
      server.broadcastEvent(WebSocketEvent(
        type: EventType.voteSubmitted,
        data: {
          'totalVotes': updatedPoll.options.fold<int>(0, (sum, o) => sum + o.voteCount),
        },
      ));
```

- [ ] **Step 5: Verify project compiles**

```bash
flutter analyze
```

Expected: No errors.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: wire server to providers, add mDNS and real-time vote broadcasting"
```

---

### Task 10: Testing + Documentation

**Files:**
- Create: `test/unit/features/poll/domain/usecases/add_option_test.dart`
- Create: `test/unit/features/poll/domain/usecases/remove_option_test.dart`
- Create: `test/unit/features/voting/domain/usecases/process_vote_test.dart`
- Create: `CLAUDE.md`
- Modify: `README.md`

**Interfaces:**
- Consumes: All use cases, entities, enums
- Produces: Additional test coverage, project documentation

- [ ] **Step 1: Write AddOption tests**

`test/unit/features/poll/domain/usecases/add_option_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/core/constants/app_constants.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/core/errors/app_exceptions.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/poll_option.dart';
import 'package:local_poll/features/poll/domain/usecases/add_option.dart';

void main() {
  late AddOption addOption;
  late Poll basePoll;

  setUp(() {
    addOption = AddOption();
    final now = DateTime.now();
    basePoll = Poll(
      id: 'p1',
      question: 'Test?',
      options: const [],
      status: PollStatus.draft,
      voteMode: VoteMode.singleChoice,
      resultsVisibility: ResultsVisibility.afterVote,
      createdAt: now,
      updatedAt: now,
    );
  });

  group('AddOption', () {
    test('adds option to poll', () {
      final result = addOption(poll: basePoll, text: 'Option A');
      expect(result.options.length, 1);
      expect(result.options.first.text, 'Option A');
      expect(result.options.first.voteCount, 0);
    });

    test('trims whitespace from option text', () {
      final result = addOption(poll: basePoll, text: '  Option B  ');
      expect(result.options.first.text, 'Option B');
    });

    test('throws on empty text', () {
      expect(
        () => addOption(poll: basePoll, text: ''),
        throwsA(isA<PollException>()),
      );
    });

    test('throws on text exceeding max length', () {
      expect(
        () => addOption(poll: basePoll, text: 'x' * 201),
        throwsA(isA<PollException>()),
      );
    });

    test('throws when at hard limit', () {
      var poll = basePoll;
      for (var i = 0; i < AppConstants.optionHardLimit; i++) {
        poll = poll.copyWith(
          options: [...poll.options, PollOption(id: 'o$i', text: 'Opt $i')],
        );
      }
      expect(
        () => addOption(poll: poll, text: 'One more'),
        throwsA(isA<PollException>()),
      );
    });
  });
}
```

- [ ] **Step 2: Write RemoveOption tests**

`test/unit/features/poll/domain/usecases/remove_option_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/core/errors/app_exceptions.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/poll_option.dart';
import 'package:local_poll/features/poll/domain/usecases/remove_option.dart';

void main() {
  late RemoveOption removeOption;

  setUp(() {
    removeOption = RemoveOption();
  });

  group('RemoveOption', () {
    test('removes option by id', () {
      final now = DateTime.now();
      final poll = Poll(
        id: 'p1',
        question: 'Q?',
        options: const [
          PollOption(id: 'o1', text: 'A'),
          PollOption(id: 'o2', text: 'B'),
        ],
        status: PollStatus.draft,
        voteMode: VoteMode.singleChoice,
        resultsVisibility: ResultsVisibility.afterVote,
        createdAt: now,
        updatedAt: now,
      );

      final result = removeOption(poll: poll, optionId: 'o1');
      expect(result.options.length, 1);
      expect(result.options.first.id, 'o2');
    });

    test('throws when option not found', () {
      final now = DateTime.now();
      final poll = Poll(
        id: 'p1',
        question: 'Q?',
        options: const [PollOption(id: 'o1', text: 'A')],
        status: PollStatus.draft,
        voteMode: VoteMode.singleChoice,
        resultsVisibility: ResultsVisibility.afterVote,
        createdAt: now,
        updatedAt: now,
      );

      expect(
        () => removeOption(poll: poll, optionId: 'nonexistent'),
        throwsA(isA<PollException>()),
      );
    });
  });
}
```

- [ ] **Step 3: Write ProcessVote tests**

`test/unit/features/voting/domain/usecases/process_vote_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:local_poll/core/enums/poll_status.dart';
import 'package:local_poll/core/enums/vote_mode.dart';
import 'package:local_poll/core/enums/results_visibility.dart';
import 'package:local_poll/features/poll/domain/entities/poll.dart';
import 'package:local_poll/features/poll/domain/entities/poll_option.dart';
import 'package:local_poll/features/poll/domain/entities/vote.dart';
import 'package:local_poll/features/voting/domain/usecases/process_vote.dart';

void main() {
  late ProcessVote processVote;

  setUp(() {
    processVote = ProcessVote();
  });

  group('ProcessVote', () {
    test('increments vote count for selected option', () {
      final now = DateTime.now();
      final poll = Poll(
        id: 'p1',
        question: 'Q?',
        options: const [
          PollOption(id: 'o1', text: 'A', voteCount: 0),
          PollOption(id: 'o2', text: 'B', voteCount: 0),
        ],
        status: PollStatus.hosting,
        voteMode: VoteMode.singleChoice,
        resultsVisibility: ResultsVisibility.afterVote,
        createdAt: now,
        updatedAt: now,
      );

      final vote = Vote(
        id: 'v1',
        pollId: 'p1',
        optionIds: const ['o1'],
        voterIp: '192.168.1.5',
        timestamp: now,
      );

      final result = processVote(poll: poll, vote: vote);
      expect(result.options[0].voteCount, 1);
      expect(result.options[1].voteCount, 0);
    });

    test('increments multiple options for multipleChoice', () {
      final now = DateTime.now();
      final poll = Poll(
        id: 'p1',
        question: 'Q?',
        options: const [
          PollOption(id: 'o1', text: 'A', voteCount: 0),
          PollOption(id: 'o2', text: 'B', voteCount: 0),
          PollOption(id: 'o3', text: 'C', voteCount: 0),
        ],
        status: PollStatus.hosting,
        voteMode: VoteMode.multipleChoice,
        resultsVisibility: ResultsVisibility.afterVote,
        createdAt: now,
        updatedAt: now,
      );

      final vote = Vote(
        id: 'v1',
        pollId: 'p1',
        optionIds: const ['o1', 'o3'],
        voterIp: '192.168.1.5',
        timestamp: now,
      );

      final result = processVote(poll: poll, vote: vote);
      expect(result.options[0].voteCount, 1);
      expect(result.options[1].voteCount, 0);
      expect(result.options[2].voteCount, 1);
    });
  });
}
```

- [ ] **Step 4: Run all tests**

```bash
flutter test
```

Expected: All tests PASS.

- [ ] **Step 5: Create CLAUDE.md**

`CLAUDE.md`:
```markdown
# Local Poll - Project Guide

## Overview
Offline-first local-network polling app. Host phone runs shelf HTTP/WebSocket server, participants vote via browser.

## Architecture
- **Pattern:** Clean Architecture with feature-based folders
- **State:** Riverpod (StateNotifier pattern)
- **Models:** Freezed (immutable) + json_serializable
- **Persistence:** Hive
- **Server:** Shelf (HTTP + WebSocket)
- **mDNS:** Bonsoir (`poll.local`)

## Commands
- `flutter pub get` — install deps
- `dart run build_runner build --delete-conflicting-outputs` — generate freezed/json code
- `flutter test` — run all tests
- `flutter test test/unit/` — unit tests only
- `flutter test test/widget/` — widget tests only
- `flutter test test/integration/` — integration tests only
- `flutter analyze` — static analysis
- `flutter run` — run on connected device

## Project Structure
- `lib/core/` — constants, enums, errors, theme, utils
- `lib/shared/` — reusable widgets and services
- `lib/features/poll/` — poll CRUD (domain, data, presentation)
- `lib/features/hosting/` — server management (shelf, API, WebSocket)
- `lib/features/voting/` — vote processing
- `assets/browser_client/` — vanilla HTML/CSS/JS voting UI
- `test/` — unit, widget, integration tests

## Key Patterns
- No business logic in widgets
- All colors from `AppColors`, dimensions from `AppDimensions`
- Enums with `.label`, `.toJson()`, `fromJson()` extensions
- Repository pattern with Hive implementation
- Use cases encapsulate single business operations
- IP-based vote deduplication

## Server
- Default port: 5000
- API: GET /api/poll, POST /api/vote, GET /api/results, GET /api/status
- WebSocket: GET /ws
- Browser client served from Flutter asset bundle

## Color Palette
- Primary: #33CCFF
- Primary Variant: #2244EE
- Surface: #2E2840
- Background: #0A0A0F
- Light: #F8F8FF
```

- [ ] **Step 6: Update README.md**

`README.md`:
```markdown
# Local Poll

Offline-first local-network polling app built with Flutter. One device hosts a real-time poll server, while participants join via QR code and vote instantly from any browser — no app install required.

## How It Works

```
Host Phone (Flutter App)
        |
 Local HTTP + WebSocket Server
        |
 --------------------------------
 |              |               |
iPhone       Android        Laptop
Safari       Chrome         Browser
```

1. **Create** a poll on your phone
2. **Start hosting** — your phone becomes a local server
3. **Share** the QR code or URL with participants
4. **Participants scan** and vote in their browser
5. **See results** update in real-time

## Features

- **No internet required** — works on local Wi-Fi or phone hotspot
- **No app install for voters** — browser-based voting
- **No accounts** — zero friction to participate
- **Real-time results** — WebSocket-powered live updates
- **Configurable visibility** — show results live, after vote, or on reveal
- **Single & multiple choice** — flexible voting modes
- **QR code + mDNS** — easy joining via `poll.local:5000`
- **Poll history** — persisted locally with Hive
- **Dark theme** — sleek UI with custom color palette

## Tech Stack

- **Flutter** — cross-platform mobile framework
- **Riverpod** — state management
- **Shelf** — embedded HTTP server
- **Hive** — local persistence
- **Freezed** — immutable models
- **Bonsoir** — mDNS service registration
- **QR Flutter** — QR code generation

## Getting Started

### Prerequisites
- Flutter SDK >=3.10.0
- Android device or emulator

### Setup

```bash
# Install dependencies
flutter pub get

# Generate freezed/json code
dart run build_runner build --delete-conflicting-outputs

# Run on device
flutter run
```

### Running Tests

```bash
flutter test
```

## Architecture

Clean Architecture with feature-based organization:

```
lib/
├── core/          # Constants, enums, theme, utils
├── shared/        # Reusable widgets and services
└── features/
    ├── poll/      # Poll creation and management
    ├── hosting/   # Local server (Shelf + WebSocket)
    └── voting/    # Vote processing
```

## API

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/poll` | Get current poll |
| POST | `/api/vote` | Submit a vote |
| GET | `/api/results` | Get poll results |
| GET | `/api/status` | Server status |
| GET | `/ws` | WebSocket connection |

## License

MIT
```

- [ ] **Step 7: Run final verification**

```bash
flutter analyze && flutter test
```

Expected: No errors, all tests pass.

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "feat: add tests, CLAUDE.md, and README documentation"
```
