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
