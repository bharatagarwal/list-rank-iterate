# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **mobile framework comparison experiment** evaluating Flutter, React Native, Capacitor, and Lynx by building the same task list app across all frameworks. The goal is to determine which framework is best suited for AI-assisted development and the i3w platform.

**Current Status**:
- **Flutter**: Phase 2 Complete ✅ (Foundation, data layer, and core UI with comprehensive tests)
- **React Native**: Not started
- **Capacitor**: Not started
- **Lynx**: Not started

The Flutter implementation currently includes:
- Task model with Hive TypeAdapter for local storage
- Platform-conditional storage: Hive (mobile/desktop) and SharedPreferences (web/WASM)
- TaskRepository abstracting all data operations
- TaskProvider for state management
- Main task list screen with Moon Design UI components
- TaskCard widget with tap-to-edit functionality
- Pull-down-to-add task feature with modal bottom sheet
- Archived tasks view with read-only display
- Navigation between active and archived task lists
- Empty states for both views
- Full unit test coverage (models, repository, provider)
- Comprehensive widget test coverage (60 tests passing)
- **Web WASM support** with localStorage persistence

## What to Build

A daily task list app with:
- Voice input and gesture controls
- Swipe right to complete, swipe left to archive
- Long press + drag to reorder
- Midnight auto-archive job
- Local-only storage (no cloud sync, no auth)
- 60 FPS performance target

See README.md for complete feature specification and data model.

## Repository Structure

The repository is organized with each framework implementation in its own subdirectory:

```
/flutter-implementation/     ← Phase 2 Complete (Foundation + Core UI)
/react-native-implementation/ (not started)
/capacitor-implementation/   (not started)
/lynx-implementation/        (not started)
```

Each framework implementation is a separate subdirectory with its own build system and dependencies.

## Development Approach

### Parallel Development Strategy
- All 4 frameworks will be developed **in parallel** over 1 week
- Each framework gets its own isolated directory
- Use AI agents (Cursor/Copilot/Claude) heavily throughout development
- Document AI-assisted development observations for the final comparison report

### Implementation Phases (issues.md)
The project is broken into 5 phases:
1. **Phase 1**: Project foundation & data layer (with unit tests)
2. **Phase 2**: Core UI & static task management (with widget tests)
3. **Phase 3**: Advanced gestures & native integration (with integration tests)
4. **Phase 4**: Background logic & midnight archive job (with background task tests)
5. **Phase 5**: Profiling, QA & final reporting (with coverage analysis)

### Testing Requirements
**Critical**: Each phase includes a comprehensive testing harness:
- Unit tests for models, repositories, and providers
- Widget tests for UI components
- Integration tests for gestures and background jobs
- Aim for high test coverage to evaluate framework testability

## Key Technical Requirements

### Performance Targets
- Gesture latency: < 16ms (60 FPS)
- Startup time: < 2 sec
- Memory with 50 tasks: < 100 MB
- App size: < 20 MB
- Hot reload: < 3 sec

### Platform Support
- **iOS**: 13+
- **Android**: API 26+
- **Web**: Chrome/Safari/Firefox (latest 2 versions), PWA-capable

### Midnight Archive Job
- Runs at 00:00 local time daily
- Moves all active/completed tasks to archived status
- Must work reliably on all platforms (use background task schedulers)

### Speech-to-Text
- Use native platform APIs via framework wrappers
- Microphone button to activate
- Real-time transcription display

## Architecture Guidelines

Follow framework-specific best practices:
- **Flutter**: BLoC or Provider for state management
- **React Native**: Redux/Context + Hooks
- **Capacitor**: Vue/React/Angular + Capacitor plugins
- **Lynx**: Follow Lynx architectural patterns

## Evaluation Criteria

Track these metrics for **each framework** to compile the final comparison report:

1. **Development Experience (35%)**: AI agent compatibility, setup time, hot reload speed, debugging, documentation
2. **Performance (25%)**: Gesture latency, animation smoothness, startup time, memory usage, app size
3. **Code Sharing (20%)**: % code shared across platforms, platform-specific code lines
4. **Build & Deployment (15%)**: Debug/release build times, CI/CD setup difficulty
5. **UI/UX (5%)**: Native feel, design system quality

## What NOT to Build

Do not implement:
- Cloud sync or backend services
- User authentication or multi-user support
- Task metadata (tags, categories, due dates)
- Notifications/reminders
- Search or filtering
- Analytics or theming/customization
- Import/export functionality

Keep the scope focused on the core gesture-based task management experience.

## Design Specifications

- System fonts only (San Francisco/Roboto)
- 8px grid spacing
- Full-width task cards
- Swipe threshold: 40% of screen width
- Animation duration: 250-300ms
- Haptic feedback on gesture completion

## Deliverables

For each framework:
- Working iOS/Android/Web builds
- Source code with comprehensive README
- Performance measurements against all targets
- Development journal documenting:
  - Blockers encountered
  - AI-assisted development observations
  - Time spent per phase

Final comparison report using this format:
```
Framework: [name]
AI Dev Friendliness: [1-5]
Performance: [metrics]
Code Sharing: [%]
Build Speed: [times]
i3w Suitability: [1-5]
Overall Score: [/10]
Recommend for i3w: Yes/No/Maybe
Notes: [key findings]
```

## Known Risks

- **Lynx documentation gaps**: Allocate extra research time, engage with community
- **Speech API differences**: Framework wrappers may have inconsistent behavior
- **Midnight job reliability**: Requires extensive cross-platform testing
- **Parallel overload**: Lean heavily on AI assistance to manage 4 concurrent implementations

## Framework-Specific Commands

### Flutter (Phase 2 Complete)

```bash
cd flutter-implementation

# Run tests (60 tests passing)
flutter test
# or
make test

# Run app (iOS/Android/Web)
make ios           # Run on iOS simulator
make android       # Run on Android emulator
make web           # Run on Chrome with WASM

# Build release
make build-ios      # iOS
make build-android  # Android APK
make build-web      # Web with WASM

# Generate Hive adapters (if models change)
flutter pub run build_runner build
```

### React Native (Not Started)
- React Native: https://reactnative.dev/docs

### Capacitor (Not Started)
- Capacitor: https://capacitorjs.com/docs

### Lynx (Not Started)
- Lynx: https://lynxjs.org/
