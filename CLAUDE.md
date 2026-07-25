# DemocracyJS - Project Guide

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
