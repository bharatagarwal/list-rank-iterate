# List, Rank, Iterate - Flutter Implementation

A gesture-based daily task list application built with Flutter as part of a multi-framework comparison experiment.

## Current Status

**Phase 2 Complete ✅** - Core UI & Static Task Management

### Completed Features

**Phase 1: Foundation & Data Layer**
- Task model with Hive TypeAdapter for local storage
- TaskRepository abstracting all data operations
- TaskProvider for state management using Provider pattern
- Comprehensive unit test coverage (models, repository, provider)

**Phase 2: Core UI & Static Task Management**
- Main task list screen displaying active tasks
- Reusable TaskCard widget using Moon Design components
- "Pull down to add new task" feature with modal bottom sheet
- "Tap to edit" inline task title editing
- Separate read-only "Archived Tasks" view
- Navigation between active and archived task lists
- Clear empty states for both active and archived views
- Comprehensive widget test coverage

### Test Coverage

- **60 tests passing** across all layers:
  - Unit tests: Task model, TaskRepository, TaskProvider
  - Widget tests: TaskCard, TaskListScreen, navigation flows

Run tests with:
```bash
flutter test
# or
make test
```

## Tech Stack

- **Flutter**: 3.35.6 (stable)
- **State Management**: Provider 6.1.2
- **Local Storage**:
  - Mobile/Desktop: Hive 2.2.3 with hive_flutter 1.1.0
  - Web (WASM): shared_preferences 2.2.3 with localStorage
- **UI Framework**: Moon Design 1.0.0
- **Build System**: Makefile for easy commands

## Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart 3.9.2 or higher
- For iOS: Xcode 13+ (macOS only)
- For Android: Android Studio with SDK 26+
- For Web: Chrome, Safari, or Firefox

### Installation

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Generate Hive adapters:**
   ```bash
   flutter pub run build_runner build
   ```

### Running the App

**Using Make (recommended):**
```bash
make ios           # Run on iOS simulator
make android       # Run on Android emulator
make web           # Run on Chrome with WASM
```

**Using Flutter CLI:**
```bash
flutter run -d ios       # iOS
flutter run -d android   # Android
flutter run -d chrome --wasm  # Web with WASM
```

### Building for Production

**Using Make:**
```bash
make build-ios      # Build iOS release
make build-android  # Build Android APK
make build-web      # Build web with WASM
```

**Using Flutter CLI:**
```bash
flutter build ios --release
flutter build apk --release
flutter build web --wasm
```

### Testing

```bash
# Run all tests
flutter test
# or
make test

# Run tests with coverage
flutter test --coverage
```

### Cleaning Build Artifacts

```bash
make clean              # Clean all build artifacts
make clean-ios          # Clean iOS-specific artifacts
make clean-android      # Clean Android-specific artifacts
make clean-web          # Clean web-specific artifacts
```

## Project Structure

```
lib/
├── main.dart                    # App entry point with theme setup
├── models/
│   ├── task.dart               # Task data model
│   └── task.g.dart             # Generated Hive adapter
├── repositories/
│   └── task_repository.dart    # Data persistence layer
├── providers/
│   └── task_provider.dart      # State management
├── screens/
│   ├── task_list_screen.dart   # Main task list view
│   └── archived_tasks_screen.dart  # Archive view
└── widgets/
    ├── task_card.dart          # Reusable task card component
    └── task_list_empty_state.dart  # Empty state component

test/
├── models/
│   └── task_test.dart          # Task model unit tests
├── repositories/
│   └── task_repository_test.dart  # Repository unit tests
├── providers/
│   └── task_provider_test.dart    # Provider unit tests
├── widgets/
│   ├── task_card_test.dart        # TaskCard widget tests
│   └── task_list_screen_test.dart # Screen widget tests
└── helpers/
    └── fake_task_repository.dart  # Test helpers
```

## Architecture

### State Management
- **Provider pattern** for reactive state management
- TaskProvider manages task list state and notifies listeners
- Clean separation between UI and business logic

### Data Layer
- **Platform-conditional storage**:
  - Mobile/Desktop: Hive for fast file-based storage with type-safe adapters
  - Web (WASM): SharedPreferences with localStorage for persistence
- Dual repository pattern: TaskRepository (Hive) and SharedPreferencesTaskRepository (web)
- Conditional initialization in main.dart based on `kIsWeb`
- Abstracted data layer ensures identical API across all platforms

### UI Layer
- **Moon Design** for consistent, accessible components
- Semantic color system (piccolo, bulma, trunks, etc.)
- Token-based spacing and typography
- Dark mode support via theme extensions

## Next Steps

**Phase 3: Advanced Gestures & Native Integration**
- Swipe right to complete task
- Swipe left to archive task
- Long press + drag to reorder tasks
- Haptic feedback on gestures
- Speech-to-text for voice input
- Integration tests for gesture flows

**Phase 4: Background Logic & Midnight Archive Job**
- Midnight auto-archive job (00:00 local time)
- Background task scheduling
- Platform-specific job implementations

**Phase 5: Profiling, QA & Final Reporting**
- Performance profiling (60 FPS target)
- Memory usage analysis (< 100 MB with 50 tasks)
- App size optimization (< 20 MB target)
- Final comparison report

## Performance Targets

- Gesture latency: < 16ms (60 FPS)
- Startup time: < 2 sec
- Memory with 50 tasks: < 100 MB
- App size: < 20 MB
- Hot reload: < 3 sec

## Design System

Using **Moon Design 1.0.0** with:
- Semantic color tokens (piccolo, bulma, trunks, gohan, goku)
- Typography system (heading, body text styles)
- Consistent spacing via tokens (xs, sm, md, lg, xl)
- Border radius and transition tokens
- Components: MoonMenuItem, MoonTextInput, MoonFilledButton, MoonTextButton, MoonTag

## Platform Support

- **iOS**: 13+ ✅ (Hive file storage)
- **Android**: API 26+ ✅ (Hive file storage)
- **Web**: Chrome/Safari/Firefox (latest 2 versions) with **WASM** ✅ (localStorage via shared_preferences)

### Web Storage Strategy

The web build uses a platform-conditional repository pattern:
- **Desktop/Mobile**: `TaskRepository` with Hive file system storage
- **Web/WASM**: `SharedPreferencesTaskRepository` with browser localStorage

This approach solves the WASM compatibility issue (Hive's IndexedDB backend isn't available in WASM) while maintaining:
- Identical API across all platforms
- Full data persistence in browser storage
- Seamless code sharing (>95% shared code)

**Important**: Web data persists across sessions but is isolated per browser/domain. This dual-repository pattern demonstrates excellent code sharing evaluation for the framework comparison.

## Contributing

This is an experimental project for framework comparison. See the root README.md and CLAUDE.md for full project context and development approach.

## License

Part of the List, Rank, Iterate framework comparison experiment.
