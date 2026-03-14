

**Status:** In Development
**Platform:** iOS 18+ (with iPadOS/macOS compatibility)
**Tech Stack:** Swift 6, SwiftUI, SwiftData, On-Device AI (MLX Swift / Apple Intelligence)

## 1. Product Vision & Core Value Proposition

Traditional habit trackers rely on positive reinforcement, pastel colors, and gentle nudges. "Roast My Habits" is the antidote to toxic positivity. It is a brutalist, high-contrast utility that tracks your daily goals and uses on-device AI to relentlessly judge your performance. The core value is hyper-personalized, comedic accountability that keeps users coming back purely to see what the AI will say to them next.

## 2. Target Audience

- People experiencing "habit fatigue" with traditional, overly earnest wellness apps.
- Users who respond better to tough love, humor, and gamified shame.
- Privacy-conscious individuals who want AI intelligence without sending their daily routines to a cloud server.

---

## 3. MVP Feature Scope

To guarantee we ship quickly, V1 will rely on manual data input and on-demand AI generation.

|**Feature Area**|**MVP Inclusion (V1)**|
|---|---|
|**Habit Creation**|Users can create custom integer-based habits (e.g., "Drink Water", Goal: 8). Limit to 5 habits to maintain focus.|
|**Data Tracking**|Manual tap-to-increment via prominent `+` and `-` buttons on the main UI.|
|**AI Personas**|Three distinct, hard-coded system prompts: The Disappointed Parent, The Hustle Bro, and The Gen Z Bestie.|
|**The "Roast" Engine**|A bold "JUDGE ME" button. Triggers a local LLM inference passing the day's stats and persona prompt to generate a text reaction.|
|**Data Persistence**|Local storage of habits and daily logs using SwiftData.|

---

## 4. Core User Flow

1. **Onboarding:** User launches the app, sees the brutalist design system, and is prompted to add their first 3 daily habits.
2. **Persona Selection:** User selects their preferred abusive AI companion from a visual menu.
3. **The Daily Grind:** User opens the app throughout the day. The home screen displays massive, bold numbers for their habits. They tap to increment.
4. **The Judgment:** The user taps the "JUDGE ME" button at the bottom of the screen.
5. **The Output:** A loading state (using animated SF Symbols) appears briefly while the local model thinks. The screen is then taken over by a massive text block delivering the custom roast or toast, accompanied by a heavy haptic vibration.

---

## 5. Technical Architecture

- **UI Framework:** SwiftUI.
- **Concurrency:** Swift 6 strict concurrency to ensure the UI thread never blocks during model inference.
- **Data Layer:** `SwiftData` for local persistence.
    - Models needed: `Habit` (defines the goal), `DailyLog` (tracks the current day's progress linked to a Habit).
- **Intelligence Layer:** * `MLX Swift` to run a small, quantized model locally (like Llama 3 8B or Mistral 7B) OR the native iOS 18 Apple Intelligence text generation APIs.
    - An `actor RoastGenerator` to safely handle the text generation off the main thread.
- **Haptics:** `CoreHaptics` for tactile feedback during increments and model outputs.

---

## 6. UI / UX Design System

- **Aesthetic:** Neo-Brutalist. No shadows, no gradients. Hard lines and solid blocks of color.
- **Color Palette:** Pure black (`#000000`) backgrounds, stark white (`#FFFFFF`) text, and aggressive accent colors like Toxic Green (`#39FF14`) or Warning Orange (`#FF4500`).
- **Typography:** Over-sized, heavy sans-serif fonts (e.g., SF Pro Display Black). The numbers and the roasts should take up maximum screen real estate.
- **Animations:** Snappy, rigid transitions. No slow fades.

---

## 7. Future Roadmap (Post-MVP)

- **V2:** Automatic data collection via HealthKit (steps, sleep) and Screen Time APIs.
- **V3:** Background generation via App Intents, delivering roasts directly to the lock screen via Push Notifications and interactive Widgets.
- **V4:** Custom user-written personas.
