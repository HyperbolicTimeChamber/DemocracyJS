# Local Poll — Design Specification

**Date:** 2026-07-22
**Status:** Approved

## Overview

Local Poll is an offline-first local-network polling system built with Flutter. The poll creator's phone becomes a local HTTP/WebSocket server. Participants join via QR code or URL in any browser — no app install, no cloud, no accounts, no internet required.

```
Host Phone (Flutter)
        |
 Local HTTP Server + WebSocket Server (port 5000)
        |
 --------------------------------
 |              |               |
iPhone       Android        Laptop
Browser      Browser        Browser
```

**Primary host:** Android phone.
**Clients:** iPhone Safari, Android Chrome, Desktop browsers.

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Duplicate vote prevention | IP-based | Zero friction, server extracts client IP automatically |
| Poll persistence | Hive local DB | Prevents accidental data loss, enables poll history |
| Max options per poll | Soft limit 10, hard limit 20 | Warning at 10, covers all practical use cases |
| Results visibility | Configurable per poll (live / afterVote / hostControlled) | Default: afterVote |
| Server port | Configurable, default 5000 | Predictable default, escape hatch for conflicts |
| mDNS | `poll.local:5000` with IP fallback | Nice UX on Apple devices, IP always works |
| Theme | Dark theme default | Matches color palette |
| Architecture | Monolith feature folders | Right complexity for scope |

## Color Palette

| Role | Hex | Usage |
|------|-----|-------|
| Background (light) | `#F8F8FF` | Light theme bg, QR code bg |
| Primary / Accent | `#33CCFF` | Accent, highlights, links |
| Primary variant | `#2244EE` | Buttons, active states |
| Surface (dark) | `#2E2840` | Cards, surfaces |
| Background (dark) | `#0A0A0F` | Dark theme bg |

## Project Structure

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── enums/
│   │   ├── poll_status.dart
│   │   ├── vote_mode.dart
│   │   ├── server_status.dart
│   │   ├── connection_status.dart
│   │   ├── event_type.dart
│   │   └── results_visibility.dart
│   ├── errors/
│   │   └── app_exceptions.dart
│   ├── extensions/
│   │   └── enum_extensions.dart
│   ├── utils/
│   │   └── network_utils.dart
│   └── theme/
│       ├── app_colors.dart
│       ├── app_theme.dart
│       ├── app_text_styles.dart
│       └── app_dimensions.dart
│
├── shared/
│   ├── widgets/
│   │   ├── primary_button.dart
│   │   ├── secondary_button.dart
│   │   ├── poll_card.dart
│   │   ├── option_tile.dart
│   │   ├── result_bar.dart
│   │   ├── qr_code_widget.dart
│   │   ├── connection_indicator.dart
│   │   ├── status_badge.dart
│   │   ├── loading_view.dart
│   │   ├── error_view.dart
│   │   └── empty_state.dart
│   └── services/
│       ├── network_service.dart
│       └── hive_storage_service.dart
│
├── features/
│   ├── poll/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── poll_model.dart
│   │   │   │   ├── poll_option_model.dart
│   │   │   │   └── vote_model.dart
│   │   │   └── repositories/
│   │   │       └── poll_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── poll.dart
│   │   │   │   ├── poll_option.dart
│   │   │   │   └── vote.dart
│   │   │   ├── repositories/
│   │   │   │   └── poll_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_poll.dart
│   │   │       ├── add_option.dart
│   │   │       ├── remove_option.dart
│   │   │       └── submit_vote.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── poll_providers.dart
│   │       ├── screens/
│   │       │   ├── create_poll_screen.dart
│   │       │   └── poll_results_screen.dart
│   │       └── widgets/
│   │           └── option_input_field.dart
│   │
│   ├── hosting/
│   │   ├── data/
│   │   │   └── server/
│   │   │       ├── local_server_impl.dart
│   │   │       ├── api_handler.dart
│   │   │       └── websocket_handler.dart
│   │   ├── domain/
│   │   │   ├── services/
│   │   │   │   └── local_server.dart
│   │   │   └── usecases/
│   │   │       ├── start_server.dart
│   │   │       └── stop_server.dart
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── hosting_providers.dart
│   │       ├── screens/
│   │       │   └── hosting_screen.dart
│   │       └── widgets/
│   │           └── connected_clients_list.dart
│   │
│   └── voting/
│       ├── domain/
│       │   └── usecases/
│       │       └── process_vote.dart
│       └── presentation/
│           ├── providers/
│           │   └── voting_providers.dart
│           └── screens/
│               └── live_results_screen.dart
│
assets/
└── browser_client/
    ├── index.html
    ├── style.css
    └── app.js

test/
├── unit/
├── widget/
└── integration/
```

## Domain Models

### Enums

```dart
enum PollStatus { draft, hosting, paused, completed }
enum VoteMode { singleChoice, multipleChoice }
enum ServerStatus { stopped, starting, running, failed }
enum ConnectionStatus { disconnected, connecting, connected, error }
enum EventType { pollCreated, userJoined, voteSubmitted, resultsUpdated, pollEnded }
enum ResultsVisibility { live, afterVote, hostControlled }
```

All enums have extensions for `label`, `toJson()`, `fromJson()`.

### Entities (immutable, freezed)

**Poll:**
- `id`: String (UUID)
- `question`: String
- `options`: List\<PollOption\>
- `status`: PollStatus
- `voteMode`: VoteMode
- `resultsVisibility`: ResultsVisibility
- `createdAt`: DateTime
- `updatedAt`: DateTime

**PollOption:**
- `id`: String
- `text`: String
- `voteCount`: int

**Vote:**
- `id`: String
- `pollId`: String
- `optionIds`: List\<String\>
- `voterIp`: String
- `timestamp`: DateTime

### WebSocketEvent

```dart
class WebSocketEvent {
  final EventType type;
  final Map<String, dynamic> data;
}
```

### Interfaces

```dart
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

abstract class LocalServer {
  Future<void> start({required int port});
  Future<void> stop();
  ServerStatus get status;
  Stream<ServerStatus> get statusStream;
  Stream<WebSocketEvent> get eventStream;
}
```

## Server & API

### Shelf HTTP Server

Runs in-process. Serves REST API + browser client from Flutter asset bundle.

**Routes:**

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/` | Serves index.html |
| GET | `/style.css` | Serves CSS |
| GET | `/app.js` | Serves JS |
| GET | `/api/poll` | Current poll JSON |
| GET | `/api/results` | Results JSON |
| GET | `/api/status` | Server status |
| POST | `/api/vote` | Submit vote (IP checked) |
| GET | `/ws` | WebSocket upgrade |

### API Contracts

**GET /api/poll**
```json
{ "id": "...", "question": "...", "options": [{"id": "...", "text": "..."}], "voteMode": "singleChoice", "resultsVisibility": "afterVote" }
```

**POST /api/vote**
Request: `{ "optionIds": ["id1"] }`
Success: `{ "success": true }`
Error: `{ "error": "already_voted" }`

**GET /api/results**
```json
{ "options": [{"id": "...", "text": "...", "voteCount": 5}], "totalVotes": 12, "visibility": "afterVote" }
```

**GET /api/status**
```json
{ "status": "running", "connectedClients": 3 }
```

### WebSocket Events (server → client)

```json
{ "type": "poll_created",     "data": { ... } }
{ "type": "user_joined",      "data": { "clientCount": 3 } }
{ "type": "vote_submitted",   "data": { "totalVotes": 5 } }
{ "type": "results_updated",  "data": { "options": [...] } }
{ "type": "poll_ended",       "data": {} }
```

### IP-Based Vote Deduplication

Server extracts `request.context['shelf.io.connection_info']` → `remoteAddress`. Stores IP per poll in repository. Returns `already_voted` on duplicate.

### mDNS

Package: `bonsoir`. Registers `poll` service on server start → `poll.local:5000`. Deregisters on stop. QR/URL display shows both `poll.local:5000` and `{ip}:5000` as fallback.

## Browser Client

Single-page vanilla HTML/CSS/JS app. No frameworks, no external dependencies. All inline.

### States

1. **Loading** — fetching poll data
2. **Voting** — question + options + submit
3. **Submitted** — confirmation + results (if visible)
4. **Waiting** — results hidden (hostControlled mode)
5. **Results** — bar chart with counts/percentages
6. **Ended** — poll closed, final results
7. **Error** — connection lost / poll not found

### UI

- Dark theme default (`#0A0A0F` bg, `#33CCFF` accent, `#2244EE` buttons)
- Mobile-first responsive (iPhone SE → desktop)
- Radio buttons (single choice), checkboxes (multi choice)
- Animated result bars
- Connection status indicator (green/yellow/red dot)

### WebSocket Reconnect

Exponential backoff: 1s → 2s → 4s → max 10s. Shows "Reconnecting..." indicator.

### Safari Compatibility

- No ES modules
- No advanced `fetch` features
- CSS: margins instead of flexbox `gap`
- WebSocket API (supported Safari 7+)

## State Management

### Riverpod Providers

```dart
// Core
serverStatusProvider      → StateNotifier<ServerStatus>
networkInfoProvider       → local IP address
serverPortProvider        → int (default 5000)

// Poll
currentPollProvider       → StateNotifier<Poll?>
pollListProvider          → FutureProvider<List<Poll>>
pollRepositoryProvider    → Provider<PollRepository>

// Hosting
localServerProvider       → Provider<LocalServer>
connectedClientsProvider  → StateNotifier<int>
webSocketEventsProvider   → StreamProvider<WebSocketEvent>

// Voting
liveResultsProvider       → StreamProvider<Poll>
```

### Data Flow

- **Create:** Screen → UseCase → Repository → Hive + Provider
- **Host:** Screen → StartServer → LocalServer.start() → ServerStatus update → QR generate
- **Vote:** Browser → POST /api/vote → ApiHandler → ProcessVote → Repository → WebSocket broadcast → Host UI
- **End:** Screen → StopServer → Broadcast poll_ended → PollStatus update → Hive persist

### Hive Boxes

- `polls` → `Box<PollModel>`
- `votes` → `Box<VoteModel>`
- `settings` → `Box<dynamic>`

## Screens & Navigation

### Screens

1. **HomeScreen** — poll list, FAB to create, empty state
2. **CreatePollScreen** — question, options (add/remove), vote mode, visibility, "Start Hosting"
3. **HostingScreen** — QR code, URL (copyable), status, client count, live results, pause/end
4. **PollResultsScreen** — final results, total votes, delete/re-host

### Navigation

```
HomeScreen → CreatePollScreen → HostingScreen → PollResultsScreen
    ↑                                               |
    └───────────────────────────────────────────────┘
```

Simple stack navigation. Linear flow.

## Packages

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `freezed` + `freezed_annotation` | Immutable models |
| `json_annotation` + `json_serializable` | JSON serialization |
| `build_runner` | Code generation |
| `hive` + `hive_flutter` | Local persistence |
| `shelf` + `shelf_router` | HTTP server |
| `shelf_web_socket` + `web_socket_channel` | WebSocket server |
| `network_info_plus` | Local IP detection |
| `qr_flutter` | QR code generation |
| `bonsoir` | mDNS service registration |
| `uuid` | ID generation |

## Testing Strategy

### Unit Tests
- Enum extensions (serialization, labels)
- Domain entities
- Use cases (CreatePoll, SubmitVote, ProcessVote)
- Vote dedup logic (IP check)
- Poll validation (option limits, empty question)

### Widget Tests
- All shared widgets
- CreatePollScreen (add/remove options, validation)
- HostingScreen (QR display, status)
- HomeScreen (empty state, poll list)

### Integration Tests
- Full flow: create → host → vote → verify results
- WebSocket: connect → events → disconnect/reconnect
- Duplicate vote rejection
- Server lifecycle (start/stop)
- Hive persistence across restarts

### Not In Scope
- E2E browser testing (manual QA)
- Performance/load testing

## Development Phases

1. Architecture + design system (theme, constants, enums)
2. Domain models + state management (freezed, Riverpod)
3. Poll creation UI
4. Local server (shelf + WebSocket)
5. Browser client (HTML/CSS/JS)
6. QR joining + mDNS
7. Real-time updates (WebSocket integration)
8. Persistence (Hive)
9. Testing
10. Refactoring + optimization
