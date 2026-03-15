# Technical Spec — Roast My Habits (MVP)

**Status:** Draft
**Platform:** iOS 18+
**Swift:** 6 (strict concurrency)
**Source PRD:** `PRD Roast My Habits (MVP).md`

---

## 1. Overview

Roast My Habits is a local-only iOS habit tracker with a neo-brutalist UI. Users create up to 5 integer-based habits, track progress via tap-to-increment, and trigger on-device AI to generate comedic roasts based on their daily performance. All data and inference stay on-device.

---

## 2. Project Setup

### 2.1 Xcode Project

- Create a new Xcode project: **RoastMyHabits** (iOS App, SwiftUI lifecycle)
- Deployment target: **iOS 18.0**
- Bundle ID: `com.lucakaufmann.RoastMyHabits`
- No external package dependencies for MVP — use only Apple frameworks plus MLX Swift (see section 7)

### 2.2 Package Dependencies

| Package | Source | Purpose |
|---------|--------|---------|
| `mlx-swift` | `https://github.com/ml-explore/mlx-swift` | On-device LLM inference |
| `mlx-swift-examples` (LLMEval module) | `https://github.com/ml-explore/mlx-swift-examples` | Pre-built LLM loading/generation utilities |

Add these via SPM in Xcode. Pin to latest stable tags.

### 2.3 Directory Structure

```
RoastMyHabits/
├── App/
│   ├── RoastMyHabitsApp.swift          # @main entry point
│   ├── Models/
│   │   ├── Habit.swift
│   │   └── DailyLog.swift
│   ├── Config/
│   │   ├── DesignTokens.swift          # Colors, fonts, spacing
│   │   ├── HapticTokens.swift          # Haptic patterns
│   │   └── Persona.swift               # AI persona definitions
│   ├── Repository/
│   │   ├── HabitRepository.swift
│   │   └── DailyLogRepository.swift
│   ├── Service/
│   │   ├── RoastGenerator.swift        # actor — LLM inference
│   │   └── HapticService.swift         # CoreHaptics wrapper
│   ├── ViewModel/
│   │   ├── OnboardingViewModel.swift
│   │   ├── HabitListViewModel.swift
│   │   └── RoastViewModel.swift
│   └── View/
│       ├── OnboardingView.swift
│       ├── PersonaPickerView.swift
│       ├── HabitListView.swift
│       ├── HabitRowView.swift
│       ├── RoastView.swift
│       └── Components/
│           ├── BrutalistButton.swift
│           └── BrutalistCard.swift
├── Tests/
│   ├── Unit/
│   │   ├── HabitRepositoryTests.swift
│   │   ├── DailyLogRepositoryTests.swift
│   │   ├── HabitListViewModelTests.swift
│   │   └── RoastViewModelTests.swift
│   └── Evals/
│       └── RoastQualityEvalTests.swift
├── Resources/
│   └── (bundled model weights, if needed)
└── Assets.xcassets/
```

---

## 3. Data Model (SwiftData)

### 3.1 `Habit`

```swift
import SwiftData
import Foundation

@Model
final class Habit {
    var id: UUID
    var name: String
    var goal: Int                    // target value per day (e.g. 8 glasses)
    var unit: String                 // display label (e.g. "glasses", "pages")
    var createdAt: Date
    var sortOrder: Int               // for manual ordering

    @Relationship(deleteRule: .cascade, inverse: \DailyLog.habit)
    var dailyLogs: [DailyLog]

    init(name: String, goal: Int, unit: String, sortOrder: Int = 0) {
        self.id = UUID()
        self.name = name
        self.goal = goal
        self.unit = unit
        self.createdAt = .now
        self.sortOrder = sortOrder
        self.dailyLogs = []
    }
}
```

### 3.2 `DailyLog`

```swift
@Model
final class DailyLog {
    var id: UUID
    var date: Date                   // normalized to start-of-day
    var currentValue: Int

    var habit: Habit?

    init(date: Date, currentValue: Int = 0, habit: Habit? = nil) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.currentValue = currentValue
        self.habit = habit
    }
}
```

### 3.3 SwiftData Container

Configure in the `@main` App struct:

```swift
@main
struct RoastMyHabitsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Habit.self, DailyLog.self])
    }
}
```

### 3.4 Data Rules

- A `DailyLog` is created lazily: when the user first increments a habit on a given day.
- Date normalization: always use `Calendar.current.startOfDay(for:)` to key logs by day.
- Maximum 5 habits enforced at the repository layer, not the model layer.
- Deleting a `Habit` cascades to all its `DailyLog` entries.

---

## 4. Architecture Layers

Strict one-way dependency flow. **No layer may import a layer to its right.**

```
Models → Config → Repository → Service → ViewModel → View
```

### 4.1 Config Layer

**`DesignTokens.swift`** — a caseless enum of static constants:

```swift
enum DesignTokens {
    enum Colors {
        static let background = Color.black
        static let foreground = Color.white
        static let accentPrimary = Color(hex: 0x39FF14)    // Toxic Green
        static let accentSecondary = Color(hex: 0xFF4500)  // Warning Orange
    }

    enum Typography {
        static let heroNumber = Font.system(size: 72, weight: .black, design: .default)
        static let headline = Font.system(size: 28, weight: .black)
        static let body = Font.system(size: 16, weight: .bold)
        static let caption = Font.system(size: 12, weight: .medium)
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }
}
```

**`Persona.swift`** — the three MVP personas:

```swift
enum Persona: String, CaseIterable, Identifiable, Codable {
    case disappointedParent
    case hustleBro
    case genZBestie

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .disappointedParent: "The Disappointed Parent"
        case .hustleBro: "The Hustle Bro"
        case .genZBestie: "The Gen Z Bestie"
        }
    }

    var emoji: String {
        switch self {
        case .disappointedParent: "😤"
        case .hustleBro: "💪"
        case .genZBestie: "💀"
        }
    }

    var systemPrompt: String {
        switch self {
        case .disappointedParent:
            """
            ROLE: You are a perpetually disappointed parent reviewing your child's daily habits.
            TONE: Sighing, guilt-tripping, passive-aggressive. Bring up how you "didn't raise them like this." Compare them unfavorably to siblings or neighbors' kids.
            CONSTRAINTS: Never use slurs or genuinely hurtful personal attacks. Keep it comedic disappointment, not emotional abuse. Stay in character throughout.
            OUTPUT FORMAT: 2-4 sentences. Reference specific habit numbers from the data provided. End with a resigned sigh or backhanded encouragement.
            """
        case .hustleBro:
            """
            ROLE: You are an over-the-top motivational hustle culture influencer reviewing someone's daily habits.
            TONE: Aggressive positivity meets condescension. Everything is about the grind, the 4 AM wake-up, the sigma mindset. Use excessive emojis and ALL CAPS for emphasis.
            CONSTRAINTS: Never use slurs or genuinely hurtful personal attacks. Keep it comedic cringe, not toxic. Stay in character throughout.
            OUTPUT FORMAT: 2-4 sentences. Reference specific habit numbers from the data provided. Include at least one absurd hustle metaphor.
            """
        case .genZBestie:
            """
            ROLE: You are a chaotic Gen Z best friend reviewing someone's daily habits.
            TONE: Unhinged support mixed with savage honesty. Use internet slang naturally (slay, bestie, no cap, ate, understood the assignment, etc.). Oscillate between hype and brutal reality checks.
            CONSTRAINTS: Never use slurs or genuinely hurtful personal attacks. Keep it comedic and supportive-chaotic, not mean-spirited. Stay in character throughout.
            OUTPUT FORMAT: 2-4 sentences. Reference specific habit numbers from the data provided. End with either maximum hype or a deadpan roast.
            """
        }
    }
}
```

### 4.2 Repository Layer

Repositories own all SwiftData access. ViewModels and Services never touch `ModelContext` directly.

```swift
@ModelActor
actor HabitRepository {
    func fetchAll() throws -> [Habit] { ... }
    func insert(_ habit: Habit) throws { ... }
    func delete(_ habit: Habit) throws { ... }
    func count() throws -> Int { ... }
}
```

```swift
@ModelActor
actor DailyLogRepository {
    /// Returns today's log for a habit, creating one if it doesn't exist.
    func todayLog(for habit: Habit) throws -> DailyLog { ... }

    /// Returns all logs for today across all habits.
    func allTodayLogs() throws -> [DailyLog] { ... }

    /// Increments the current value of today's log for a habit.
    func increment(habit: Habit) throws { ... }

    /// Decrements the current value (floor at 0).
    func decrement(habit: Habit) throws { ... }
}
```

**Key pattern:** Use `@ModelActor` to get an actor-isolated `ModelContext` automatically. This ensures all SwiftData work is off the main thread and concurrency-safe under Swift 6.

### 4.3 Service Layer

**`RoastGenerator`** — see section 7 for full detail.

**`HapticService`** — a lightweight wrapper around `CoreHaptics`:

```swift
import CoreHaptics

final class HapticService: Sendable {
    func playIncrement() { ... }   // light tap
    func playDecrement() { ... }   // soft tap
    func playRoast() { ... }       // heavy notification vibration
}
```

Use `UIImpactFeedbackGenerator` for increment/decrement (`.light` / `.soft`). Use `UINotificationFeedbackGenerator(.success)` or a custom `CHHapticPattern` for the roast reveal.

### 4.4 ViewModel Layer

All ViewModels are `@Observable` classes annotated with `@MainActor`.

```swift
@MainActor
@Observable
final class HabitListViewModel {
    private let habitRepository: HabitRepository
    private let dailyLogRepository: DailyLogRepository
    private let hapticService: HapticService

    var habits: [HabitWithProgress] = []
    var isLoading = false
    var error: String?

    struct HabitWithProgress: Identifiable {
        let habit: Habit
        let currentValue: Int
        let goal: Int
        var progress: Double { Double(currentValue) / Double(goal) }
        var id: UUID { habit.id }
    }

    func load() async { ... }
    func increment(_ habit: Habit) async { ... }
    func decrement(_ habit: Habit) async { ... }
    func deleteHabit(_ habit: Habit) async { ... }
}
```

```swift
@MainActor
@Observable
final class RoastViewModel {
    private let roastGenerator: RoastGenerator
    private let dailyLogRepository: DailyLogRepository
    private let hapticService: HapticService

    var roastText: String = ""
    var isGenerating = false
    var selectedPersona: Persona = .disappointedParent

    func judgeMe() async { ... }
}
```

**Pattern for agents:** ViewModels expose simple `async` intent methods. Views call these from `.task {}` or button actions. ViewModels never import SwiftUI.

### 4.5 View Layer

Views are thin — they read `@State` or `@Bindable` ViewModel properties and call intent methods. No business logic, no direct data access.

```swift
struct HabitListView: View {
    @State private var viewModel: HabitListViewModel

    var body: some View {
        // rendering only — calls viewModel.increment(), etc.
    }
}
```

---

## 5. User Flow & Screen Map

### 5.1 Navigation Architecture

Use a simple `@State`-driven flow in the root `ContentView`. No `NavigationStack` needed for MVP — the app is essentially single-screen with modal overlays.

```swift
struct ContentView: View {
    @State private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            HabitListView(...)
        } else {
            OnboardingView(onComplete: { hasCompletedOnboarding = true })
        }
    }
}
```

Persist `hasCompletedOnboarding` via `@AppStorage("hasCompletedOnboarding")`.

### 5.2 Screen Breakdown

| Screen | Purpose | Key Interactions |
|--------|---------|-----------------|
| **OnboardingView** | First launch. Prompt user to create 3 habits. | Text fields for name/goal/unit, "Add Habit" button, "Done" button (requires >= 1 habit) |
| **PersonaPickerView** | Select AI persona. Shown as sheet from HabitListView. | 3 large cards with emoji + name + sample quote. Tap to select. |
| **HabitListView** | Main daily screen. Shows all habits with progress. | `+` / `-` buttons per habit, "JUDGE ME" button fixed at bottom. |
| **RoastView** | Full-screen overlay showing the AI roast output. | Appears over HabitListView with a dramatic transition. Tap to dismiss. |

### 5.3 "JUDGE ME" Flow

1. User taps "JUDGE ME" button on `HabitListView`.
2. `RoastViewModel.judgeMe()` is called.
3. ViewModel gathers today's habit data from `DailyLogRepository`.
4. ViewModel calls `RoastGenerator.generate(persona:habitData:)`.
5. While generating: show `RoastView` with a loading state (animated SF Symbol — `brain.head.profile` with `.symbolEffect(.pulse)`).
6. On completion: display roast text with heavy haptic. Text appears with a snappy `.transition(.opacity.combined(with: .scale))`.
7. User taps anywhere to dismiss.

---

## 6. UI / Design System

### 6.1 Neo-Brutalist Principles

- **No shadows, no gradients.** All surfaces are flat solid colors.
- **Hard borders.** Use 2-3pt solid borders (`Color.white`) instead of rounded corners or elevation.
- **Maximum contrast.** Black backgrounds, white text, neon accents.
- **Oversized typography.** Numbers should dominate the screen. Use `DesignTokens.Typography.heroNumber` (72pt black weight) for habit values.
- **Rigid animations.** Use `.spring(duration: 0.2, bounce: 0)` or `.easeOut(duration: 0.15)`. No bouncy springs, no slow fades.

### 6.2 Reusable Components

**`BrutalistButton`** — The primary action button style:

```swift
struct BrutalistButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignTokens.Typography.headline)
                .foregroundStyle(DesignTokens.Colors.background)
                .frame(maxWidth: .infinity)
                .padding(DesignTokens.Spacing.md)
                .background(color)
                .border(DesignTokens.Colors.foreground, width: 3)
        }
    }
}
```

**`BrutalistCard`** — Container for habit rows:

```swift
struct BrutalistCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            content()
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .border(DesignTokens.Colors.foreground, width: 2)
    }
}
```

### 6.3 Color Usage

| Element | Color |
|---------|-------|
| All backgrounds | `#000000` (black) |
| Primary text | `#FFFFFF` (white) |
| "JUDGE ME" button | `#39FF14` (Toxic Green) |
| Destructive / warning actions | `#FF4500` (Warning Orange) |
| Progress bar fill (incomplete) | `#FF4500` |
| Progress bar fill (complete / exceeded) | `#39FF14` |
| Borders | `#FFFFFF` |

### 6.4 Status Bar & System Chrome

```swift
.preferredColorScheme(.dark)
```

Apply at the root view to force dark mode system-wide within the app.

---

## 7. AI / Roast Engine

### 7.1 Approach: MLX Swift

Use MLX Swift to run a small quantized LLM on-device. This gives full control over model selection, prompt formatting, and output parsing without depending on Apple Intelligence availability.

### 7.2 Model Selection

For MVP, target a small model that runs acceptably on iPhone 15 Pro+ (8GB RAM):

| Model | Size | Notes |
|-------|------|-------|
| **Llama 3.2 3B (4-bit)** | ~1.7 GB | Good balance of quality and speed. Primary choice. |
| Mistral 7B (4-bit) | ~3.8 GB | Better output quality, slower, more memory. Fallback. |
| Phi-3 Mini (4-bit) | ~2.0 GB | Alternative small model. |

Bundle the model weights in the app or download on first launch (with a progress indicator). For MVP, prefer bundling to avoid network dependency.

### 7.3 `RoastGenerator` Actor

```swift
actor RoastGenerator {
    private var model: LLMModel?     // from mlx-swift-examples LLMEval
    private var tokenizer: Tokenizer?

    enum GenerationError: Error {
        case modelNotLoaded
        case generationFailed(String)
    }

    func loadModel() async throws {
        // Load quantized model from bundle
    }

    func generate(persona: Persona, habitData: [HabitSnapshot]) async throws -> String {
        guard let model, let tokenizer else {
            throw GenerationError.modelNotLoaded
        }

        let prompt = buildPrompt(persona: persona, habitData: habitData)
        let output = try await runInference(prompt: prompt)
        return output
    }

    private func buildPrompt(persona: Persona, habitData: [HabitSnapshot]) -> String {
        let dataBlock = habitData.map { habit in
            "- \(habit.name): \(habit.currentValue)/\(habit.goal) \(habit.unit)"
        }.joined(separator: "\n")

        return """
        <|system|>
        \(persona.systemPrompt)
        <|end|>
        <|user|>
        Here are my habits for today:
        \(dataBlock)

        Judge me.
        <|end|>
        <|assistant|>
        """
    }
}
```

### 7.4 `HabitSnapshot`

A lightweight, `Sendable` value type used to pass habit data across actor boundaries:

```swift
struct HabitSnapshot: Sendable {
    let name: String
    let currentValue: Int
    let goal: Int
    let unit: String
}
```

This avoids passing SwiftData `@Model` objects (which are not `Sendable`) to the `RoastGenerator` actor.

### 7.5 Generation Parameters

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Max tokens | 150 | Keeps roasts concise (2-4 sentences) |
| Temperature | 0.8 | Creative but not unhinged |
| Top-p | 0.9 | Standard nucleus sampling |
| Repetition penalty | 1.1 | Avoid repetitive phrasing |

### 7.6 Safety

- Persona prompts include explicit constraints against slurs and genuinely hurtful content.
- Output is displayed as-is (no post-processing for MVP) since the persona prompts constrain tone.
- If generation fails, show a fallback message: *"Even the AI is disappointed. Try again."*

---

## 8. Haptics

Use `UIImpactFeedbackGenerator` and `UINotificationFeedbackGenerator` for simplicity in MVP. Reserve `CoreHaptics` `CHHapticEngine` patterns for post-MVP.

| Event | Haptic |
|-------|--------|
| Tap `+` to increment | `UIImpactFeedbackGenerator(style: .light).impactOccurred()` |
| Tap `-` to decrement | `UIImpactFeedbackGenerator(style: .soft).impactOccurred()` |
| Roast appears | `UINotificationFeedbackGenerator().notificationOccurred(.success)` |
| Goal completed (100%) | `UINotificationFeedbackGenerator().notificationOccurred(.success)` |

---

## 9. Onboarding & Persistence

### 9.1 Onboarding Flow

1. Show a title screen: app name in massive type + tagline.
2. Prompt user to add habits one at a time (name, daily goal, unit).
3. Require at least 1 habit, encourage 3, cap at 5.
4. After adding habits, show `PersonaPickerView` to choose initial persona.
5. Set `@AppStorage("hasCompletedOnboarding")` to `true`.

### 9.2 Persona Persistence

Store selected persona in `@AppStorage("selectedPersona")` as a raw string value. The persona can be changed anytime via a settings/persona button on `HabitListView`.

### 9.3 Daily Reset

- `DailyLog` entries are keyed by date (start of day).
- When the app opens, `HabitListViewModel.load()` fetches or creates today's logs.
- Yesterday's data is preserved in SwiftData but not shown on the main screen (future: history view).

---

## 10. Concurrency Model

Swift 6 strict concurrency is enforced. Key patterns:

| Concern | Solution |
|---------|----------|
| SwiftData access | `@ModelActor` repositories — each gets its own `ModelContext` on a background thread |
| LLM inference | `actor RoastGenerator` — all generation is isolated |
| UI state | `@MainActor @Observable` ViewModels — all published state is main-actor-isolated |
| Passing data across boundaries | Use `Sendable` value types (`HabitSnapshot`) instead of `@Model` objects |
| View → ViewModel calls | `async` methods called from `.task {}` or `Button` actions |

**Never block the main thread.** All repository calls and LLM inference are `async` and run on their respective actor executors.

---

## 11. Logging

Use `os.Logger` instead of `print()`:

```swift
import os

extension Logger {
    static let habits = Logger(subsystem: "com.lucakaufmann.RoastMyHabits", category: "habits")
    static let roast = Logger(subsystem: "com.lucakaufmann.RoastMyHabits", category: "roast")
    static let haptics = Logger(subsystem: "com.lucakaufmann.RoastMyHabits", category: "haptics")
}
```

---

## 12. Testing Strategy

### 12.1 Unit Tests

| Target | What to test |
|--------|-------------|
| `HabitRepository` | CRUD operations, 5-habit limit enforcement |
| `DailyLogRepository` | Log creation, increment/decrement, date normalization, floor-at-zero |
| `HabitListViewModel` | Loading state, increment/decrement updates, error handling |
| `RoastViewModel` | Generation trigger, loading state, error fallback |

Use an in-memory SwiftData `ModelConfiguration` for repository tests:

```swift
let config = ModelConfiguration(isStoredInMemoryOnly: true)
let container = try ModelContainer(for: Habit.self, DailyLog.self, configurations: config)
```

### 12.2 Roast Quality Evals

Structured eval cases that validate persona output characteristics:

```swift
struct RoastEvalCase {
    let persona: Persona
    let habitData: [HabitSnapshot]
    let expectedTraits: [String]       // e.g. ["mentions water", "passive-aggressive tone"]
    let bannedTerms: [String]          // safety guardrails
    let maxLength: Int                 // character limit
}
```

Deterministic checks:
- Output length within bounds
- References at least one habit name from input
- Contains no banned terms
- Is not empty

### 12.3 Testing Framework

Use Swift Testing (`@Test`, `@Suite`) for all new tests. Do not use XCTest.

---

## 13. Agent Instructions

When implementing this project, agents should follow these patterns:

### 13.1 Work Order

Build in dependency order — each layer should compile before moving to the next:

1. **Models** — `Habit.swift`, `DailyLog.swift`, `HabitSnapshot.swift`
2. **Config** — `DesignTokens.swift`, `Persona.swift`, `HapticTokens.swift`
3. **Repository** — `HabitRepository.swift`, `DailyLogRepository.swift`
4. **Service** — `RoastGenerator.swift`, `HapticService.swift`
5. **ViewModel** — `HabitListViewModel.swift`, `RoastViewModel.swift`, `OnboardingViewModel.swift`
6. **View** — Components first (`BrutalistButton`, `BrutalistCard`), then screens (`HabitListView`, `OnboardingView`, `PersonaPickerView`, `RoastView`), then `ContentView` and `RoastMyHabitsApp.swift`
7. **Tests** — Unit tests for repositories and view models, then eval tests

### 13.2 Patterns to Follow

- **SwiftData repositories:** Always use `@ModelActor`. Never access `ModelContext` from views or view models directly.
- **ViewModels:** Always `@MainActor @Observable class`. Expose intent methods as `func doThing() async`. Never import SwiftUI in a ViewModel file.
- **Views:** Always thin. Call ViewModel methods, read ViewModel state. No logic beyond simple conditionals for rendering.
- **Sendable boundaries:** When passing data from a `@ModelActor` repository to a `@MainActor` ViewModel, map `@Model` objects to `Sendable` value types (structs) first.
- **Design tokens:** Always use `DesignTokens.*` constants. Never hardcode colors, fonts, or spacing values in views.
- **Error handling:** Use typed errors in services. ViewModels catch errors and set an `error: String?` property. Views display errors with `DesignTokens.Colors.accentSecondary`.
- **File size:** Keep files under 200 lines. If a view gets large, extract subviews into the `Components/` directory.

### 13.3 Libraries & APIs to Use

| Need | Use | Do NOT use |
|------|-----|------------|
| Data persistence | SwiftData | Core Data, UserDefaults (except `@AppStorage` for simple prefs), SQLite |
| UI framework | SwiftUI | UIKit (except for haptics APIs) |
| On-device AI | MLX Swift | CloudKit, any network-based AI API, URLSession to AI endpoints |
| Haptics | `UIImpactFeedbackGenerator`, `UINotificationFeedbackGenerator` | Raw `AudioServicesPlaySystemSound` |
| Logging | `os.Logger` | `print()`, `NSLog`, third-party loggers |
| Testing | Swift Testing (`@Test`, `@Suite`) | XCTest |
| Async/concurrency | Swift structured concurrency (`async/await`, actors) | GCD (`DispatchQueue`), Combine, completion handlers |
| Navigation | `@State`-driven conditional views, `.sheet()` | `NavigationStack` (not needed for MVP), `UINavigationController` |

### 13.4 Common Pitfalls to Avoid

- **Do not** pass `@Model` objects across actor boundaries — they are not `Sendable`. Map to value types first.
- **Do not** use `@Query` in views for MVP. Route all data access through repositories and view models to maintain the architecture layers.
- **Do not** call `modelContext.save()` explicitly — SwiftData autosaves. Only call it when you need immediate persistence guarantees.
- **Do not** use `NavigationLink` or `NavigationStack` — the MVP is simple enough for conditional views and sheets.
- **Do not** add `import UIKit` in view files — access haptic APIs only through `HapticService`.
- **Do not** create any network calls. The entire app is offline-only.
