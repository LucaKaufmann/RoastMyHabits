# Getting Started

## Prerequisites

- Xcode 26.3 or newer
- Swift 6.2+
- Tuist 4.152.0 or newer

## Initial Setup

Generate the workspace from the Tuist manifests:

```bash
tuist generate --no-open
```

Open the generated workspace when you want to work in Xcode:

```bash
open RoastMyHabits.xcworkspace
```

## Build

Build the app target for the iOS simulator:

```bash
xcodebuild build \
  -workspace RoastMyHabits.xcworkspace \
  -scheme RoastMyHabits \
  -destination "platform=iOS Simulator,name=iPhone 16"
```

## Test

Run the Swift Testing suite:

```bash
xcodebuild test \
  -workspace RoastMyHabits.xcworkspace \
  -scheme RoastMyHabits \
  -destination "platform=iOS Simulator,name=iPhone 16"
```

`swift test` is not used for this scaffold because the repository is an iOS app generated from Tuist manifests rather than a standalone Swift package.

## Project Layout

```text
App/
  Models/
  Config/
  Repository/
  Service/
  ViewModel/
  View/
Tests/
docs/
Project.swift
Workspace.swift
```

## Notes

- The current `RoastGenerator` is a local scaffold that preserves the actor boundary and prompt-building flow so MLX Swift or Apple Intelligence can be integrated without changing the rest of the app architecture.
- SwiftData storage records are intentionally isolated to the repository layer so app-facing models remain `Sendable` value types.
