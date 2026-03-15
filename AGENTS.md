# RoastMyHabits Agent Guide

## Project Summary

RoastMyHabits is an iOS 18+ SwiftUI app for tracking up to five habits and generating local-only comedic "roasts" about the user's daily progress. The UI is neo-brutalist, the architecture is layered, and all inference must stay on-device.

## Setup Commands

```bash
tuist generate --no-open
xcodebuild build -workspace RoastMyHabits.xcworkspace -scheme RoastMyHabits -destination "platform=iOS Simulator,name=iPhone 16"
xcodebuild test -workspace RoastMyHabits.xcworkspace -scheme RoastMyHabits -destination "platform=iOS Simulator,name=iPhone 16"
```

## Architecture Rules

- Dependency flow is one way only: `Models -> Config -> Repository -> Service -> ViewModel -> View`.
- `App/Models` contains Foundation-only value types.
- SwiftData storage types stay inside `App/Repository`.
- Views stay thin and only coordinate input and rendering.
- AI inference lives behind `actor RoastGenerator`.
- Use `os.Logger`, never `print()`.

## File Map

- [PRD Roast My Habits (MVP).md](/Users/luca/symphony-workspaces/COD-8/PRD%20Roast%20My%20Habits%20(MVP).md)
- [TECH_SPEC.md](/Users/luca/symphony-workspaces/COD-8/TECH_SPEC.md)
- [docs/getting-started.md](/Users/luca/symphony-workspaces/COD-8/docs/getting-started.md)
- [HARNESS.md](/Users/luca/symphony-workspaces/COD-8/HARNESS.md)

## Working Norms

- Build in dependency order.
- Keep files under 200 lines unless there is a clear reason not to.
- Prefer small, focused patches.
- Update docs alongside structural changes.
