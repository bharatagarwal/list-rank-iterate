# List, Rank, Iterate
Experiment in using multiple mobile frameworks, including Flutter, React Native, Capacitor &amp; Lynx

## Current Status

**Flutter Implementation: Phase 2 Complete ✅**
- Project foundation and data layer implemented
- Task model with Hive TypeAdapter
- TaskRepository with local storage
- TaskProvider for state management
- Core UI with Moon Design components
- Task list screen with pull-to-add and tap-to-edit
- Archived tasks view
- Comprehensive test coverage (60 tests passing)

**Next Steps:**
- Phase 3: Advanced gestures & native integration
- Other frameworks (React Native, Capacitor, Lynx): Not started

## Goal

Compare frameworks on:
- AI agent development compatibility
- Performance (gestures, animations, hardware usage)
- Code sharing across platforms
- Build speed and ecosystem maturity

## Frameworks to Test


- **Flutter** - iOS, Android, Web
- **React Native** - iOS, Android, Web (via React Native Web)
- **Capacitor** - iOS, Android, Web (web-first approach)
- **Lynx** - iOS, Android (docs: https://lynxjs.org/)

## What to Build

A daily task list app with voice input and gesture controls.

### Core Features

**Task Management**
- Add tasks (text or voice dictation)
- Edit tasks inline
- Drag to reorder
- Swipe right → complete task
- Swipe left → archive task
- View archived tasks (read-only)

**Data Model**

```typescript
interface Task {
  id: string;
  title: string;
  status: 'active' | 'completed' | 'archived';
  order: number;
  createdAt: Date;
  completedAt?: Date;
  archivedAt?: Date;
}
```

**Behavior**
- Tasks only exist for today
- At midnight (00:00), all active/completed tasks → archived
- Incomplete tasks viewable in archive
- No future planning, no cloud sync, no auth

**Voice Input**
- Use native speech-to-text
- Microphone button to activate
- Real-time transcription display


### Gestures (inspired by Clear app)

- **Swipe right** → complete task (fade out with checkmark)
- **Swipe left** → archive task (slide off screen)
- **Long press + drag** → reorder (task lifts, others shift)
- **Tap** → edit inline
- **Pull down** → add new task

**Performance target:** < 16ms latency (60 FPS minimum)

### Storage

- Local only (no cloud, no auth)
- Use framework-appropriate storage (SQLite, SharedPreferences, IndexedDB, etc.)

### Platforms

**iOS:** 13+, native feel, 60 FPS
**Android:** API 26+, Material Design compliant, 60 FPS
**Web:** Chrome/Safari/Firefox (latest 2 versions), mobile-first, PWA-capable

## Evaluation Criteria

Track these metrics for each framework:

### 1. Development Experience (35% weight)

- AI agent compatibility (Cursor, Copilot, Claude)
- Setup time (target: < 30 min)
- Hot reload speed (target: < 3 sec)
- Documentation quality
- Debugging experience
- IDE support quality

### 2. Performance (25% weight)

- Gesture latency (target: < 16ms)
- Animation smoothness (no dropped frames)
- Startup time (target: < 2 sec)
- Memory usage with 50 tasks (target: < 100 MB)
- App size (target: < 20 MB)

### 3. Code Sharing (20% weight)

- % code shared across platforms (target: > 80%)
- Lines of platform-specific code
- Ease of native API access (speech-to-text)
- Third-party library availability

### 4. Build & Deployment (15% weight)

- Debug build time (target: < 2 min)
- Release build time (target: < 10 min)
- CI/CD setup difficulty

### 5. UI/UX (5% weight)

- Native feel
- Design system quality

## Technical Implementation

### Architecture

Use framework best practices:
- **Flutter:** BLoC or Provider
- **React Native:** Redux/Context + Hooks
- **Capacitor:** Pick Vue/React/Angular + Capacitor plugins
- **Lynx:** Follow Lynx patterns

### Key APIs

- Gesture recognition (native or libraries)
- Animations (use framework native APIs)
- Local storage (SQLite, Hive, AsyncStorage, etc.)
- Speech-to-text (native platform APIs)
- Background scheduling (midnight job)

### Midnight Archive Job

- Trigger at 00:00 local time
- Move all active/completed → archived
- Use background task or scheduled job

## Timeline

**1 week, parallel development**

- Day 1: Setup all frameworks
- Day 2-3: Core UI (list, add, gestures)
- Day 4: Drag-reorder, animations, voice
- Day 5: Archive view, midnight job
- Day 6: Testing, profiling
- Day 7: Documentation, comparison report

## Deliverables

**For each framework:**
- Working iOS/Android builds (+ Web where applicable)
- Source code repo with README
- Performance measurements
- Development journal (blockers, AI assist notes, progress)

**Final comparison report:**
- Side-by-side metric comparison
- Code sharing breakdown
- Gesture/animation quality assessment
- AI-assisted development observations
- Framework recommendation for i3w

**Report format:**

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

## What NOT to Build

- Cloud sync or backend
- User authentication
- Multi-user support
- Task metadata (tags, categories, due dates)
- Notifications/reminders
- Search or filtering
- Analytics
- Theming/customization
- Import/export
- Advanced i3w features (OCR, video, avatars)

## Design Guidelines

- System fonts (San Francisco/Roboto)
- Simple color palette
- 8px grid spacing
- Full-width task cards
- Swipe threshold: 40% of screen width
- Animation duration: 250-300ms
- Haptic feedback on gestures
- Clear empty states

## Reference Links

- Clear app gestures: https://www.youtube.com/watch?v=_JTwS7EWpig
- Flutter: https://flutter.dev/docs
- React Native: https://reactnative.dev/docs
- Capacitor: https://capacitorjs.com/docs
- Lynx: https://lynxjs.org/

## Risks

- **Lynx documentation gaps** → allocate extra time, ask community
- **Speech API differences** → use framework wrappers
- **Midnight job reliability** → test extensively
- **Parallel overload** → lean on AI agents heavily

