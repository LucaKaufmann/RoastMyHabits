# Codex Harness Plan — RoastMyHabits

> The model matters, but the repeatable advantage is the environment around it.

This document defines how Codex should operate in this repository: what context it reads, what constraints it must obey, how it gets feedback, and how we improve the harness when it fails.

The goal is not "let the model improvise." The goal is a repo that makes correct changes easy, incorrect changes obvious, and recurring mistakes cheaper to eliminate than to tolerate.

## 1. What Harness Engineering Means Here

Harness engineering is the full system around the model:

| Layer | Question | Repo Mechanism |
|---|---|---|
| Prompting | What is Codex being asked to do? | Task request, agent persona, file-local instructions |
| Context | What should Codex read before acting? | `AGENTS.md`, nearby docs, execution plans, code structure |
| Harness | How do we keep output reliable? | Build/test/lint gates, evals, review rules, maintenance loops |

Operating principle:

1. If Codex makes a one-off mistake, fix the code.
2. If Codex makes a repeatable mistake, fix the harness.

## 2. Codex Operating Model

Codex works best when the repo is legible and local:

- Keep instructions in the repository, not only in chat history.
- Prefer short, navigational docs over giant encyclopedias.
- Make plans executable and checkable.
- Make failures machine-readable and specific.
- Optimize for many small, reviewable diffs rather than large heroic patches.

This is the model the OpenAI harness engineering guidance pushes toward: treat the repo like a workshop designed for agents, not just humans.

## 3. Source of Truth

### 3.1 `AGENTS.md` is the entry point

For Codex, `AGENTS.md` should replace the old `CLAUDE.md` role. It should stay short, roughly 80-150 lines, and function as a map:

- what the app is
- build, test, and lint commands
- architecture constraints
- where deeper docs live
- task-specific instructions for working safely

`AGENTS.md` should not duplicate full architecture docs. It should route Codex to the right place.

Suggested shape:

```text
AGENTS.md
├── Project summary
├── Build / test / lint commands
├── Architecture rules
├── AI-specific eval requirements
├── File map for docs/
└── Working norms for Codex
```

### 3.2 Docs live close to decisions

Repository-local documentation is preferred over external memory. For this project:

```text
docs/
├── architecture/
│   ├── overview.md
│   ├── dependency-layers.md
│   └── data-model.md
├── design/
│   ├── brutalist-system.md
│   ├── components.md
│   └── haptics.md
├── ai/
│   ├── personas.md
│   ├── roast-engine.md
│   └── model-config.md
├── exec-plans/
│   ├── mvp.md
│   ├── current-sprint.md
│   └── templates/
└── conventions/
    ├── swift-style.md
    ├── swiftui-patterns.md
    └── testing.md
```

Rules:

- Prefer small docs with explicit owners and update triggers.
- Read the nearest relevant doc first; avoid scanning the whole repo.
- If code changes invalidate a doc, update both in the same patch.

### 3.3 Execution plans are first-class artifacts

Codex performs better when implementation work starts from a concrete plan in the repo. Use `docs/exec-plans/` for work that spans multiple commits or files.

Each execution plan should contain:

- goal
- non-goals
- constraints
- file touch list
- ordered task list
- validation steps
- rollback notes if relevant

This keeps work inspectable and lets Codex resume without relying on chat context.

## 4. Project Constraints

RoastMyHabits is an iOS 18+ SwiftUI app with:

- Swift 6 strict concurrency
- SwiftData persistence
- on-device AI via MLX Swift or Apple Intelligence
- a neo-brutalist UI
- three fixed roast personas for MVP

The app promise is local, funny, judgmental habit tracking without cloud dependency. The harness should preserve that promise mechanically.

## 5. Architecture Rules

### 5.1 Dependency layering

Use strict one-way dependencies:

```text
Models → Config → Repository → Service → ViewModel → View
```

Allowed responsibilities:

| Layer | Responsibility | Allowed Dependencies |
|---|---|---|
| Models | `Habit`, `DailyLog`, value types | Foundation only |
| Config | constants, design tokens, persona templates | Models |
| Repository | SwiftData reads/writes | Models, Config |
| Service | `RoastGenerator`, business logic, haptics orchestration | Repository, Config, Models |
| ViewModel | presentation state, intents, async coordination | Service, Repository, Config, Models |
| View | rendering and user input wiring | ViewModel, Config |

Enforcement should fail with actionable messages, for example:

```text
Architectural violation: HabitListView.swift depends on HabitRepository.
Views must depend on ViewModels, not Repositories.
Fix: move data access behind HabitListViewModel.
See: docs/architecture/dependency-layers.md
```

### 5.2 Additional code constraints

- No business logic in SwiftUI views.
- All AI inference runs off the main thread behind `actor RoastGenerator`.
- No force unwraps in production code.
- No `print()` in app code; use structured logging.
- Keep files small enough to review quickly; target under 200 lines unless justified.
- Prefer one primary type per file.

### 5.3 Naming conventions

Use explicit suffixes so Codex can infer intent from filenames:

```text
Habit.swift
HabitRepository.swift
RoastService.swift
HabitListViewModel.swift
HabitListView.swift
HabitListViewTests.swift
```

## 6. Codex-Legible Feedback Loops

The article's strongest practical point is that agents need environments they can read, not just pass through. That means every tool in the loop should emit concise, specific, remediation-friendly output.

### 6.1 Local commands must be stable

Standardize a small command surface in `AGENTS.md`:

- `xcodebuild -scheme RoastMyHabits build`
- `swift test`
- `swift test --filter RoastQualityEvals`
- `swiftlint`
- structural check scripts, if added

Avoid undocumented one-off scripts. If a command matters to shipping, document it.

### 6.2 Lints should teach

Prefer failures that explain both the rule and the repair:

```text
SwiftLint [roast_persona_format]:
Persona definition in GenZBestiePrompt.swift is missing required sections.
Required order: ROLE → TONE → CONSTRAINTS → OUTPUT FORMAT.
See: docs/ai/personas.md
```

### 6.3 CI should optimize for agent iteration

Recommended pipeline:

1. Build
2. Lint
3. Unit tests
4. Structural architecture checks
5. Roast evals
6. Coverage and regression summaries

Output requirements:

- label the failing subsystem
- identify the file when possible
- give a likely fix
- link to the closest repo doc
- avoid noisy logs before the actionable lines

## 7. Evals

This project needs two eval tracks: code correctness and roast quality.

### 7.1 Code evals

| Metric | Target |
|---|---|
| Build success | 100% |
| Test pass rate | 100% |
| Lint violations | 0 |
| Architecture violations | 0 |
| Coverage | high enough to protect behavior; start with meaningful service/view model coverage |

### 7.2 Roast quality evals

Because the core feature is creative generation, evals must check more than "it compiled."

Use structured cases like:

```swift
struct RoastEvalCase {
    let persona: Persona
    let habitData: [HabitSnapshot]
    let expectedTraits: [String]
}
```

Evaluate:

- persona consistency
- grounding in actual habit data
- tone calibration: harsh, funny, not genuinely abusive
- output length constraints
- safety boundaries

Trait checks can be mixed:

- deterministic assertions for length, presence of referenced metrics, banned terms
- judge-model or rubric-based scoring for tone/persona consistency

### 7.3 Eval gate policy

Any change to one of these areas should run roast evals before merge:

- persona prompts
- roast engine logic
- model configuration
- output formatting constraints

## 8. Planning and Review Workflow

OpenAI's guidance also emphasizes that agent throughput changes how teams should structure work. For this repo that means:

### 8.1 Prefer small, mergeable tasks

Break work into narrow slices:

- scaffold model
- add repository
- wire view model
- add one screen
- add evals

This reduces review cost and lets Codex recover quickly from mistakes.

### 8.2 Review for systemic issues, not only style

Review should ask:

- did this preserve layering?
- did docs stay in sync?
- did we add or expand tests where behavior changed?
- is the change legible enough that Codex can safely modify it later?

### 8.3 Raise the merge rate

Do not batch unrelated changes just because the agent can produce them. A higher merge cadence with smaller diffs is better for both humans and Codex.

## 9. Entropy Management

The harness should include recurring cleanup work, not only feature work.

### 9.1 Recurring maintenance

| Task | Frequency | Purpose |
|---|---|---|
| Dead code sweep | Weekly | Keep context small and legible |
| Doc freshness pass | Per feature PR | Keep repo docs trustworthy |
| Dependency audit | Weekly or monthly | Remove stale packages and drift |
| Architecture drift scan | Per PR | Catch boundary erosion early |
| Roast eval regression run | Per AI-related PR | Protect product quality |

### 9.2 Documentation freshness rule

If a code change alters one of these areas, update the paired doc in the same patch:

- data model
- dependency rules
- persona design
- model selection/configuration
- testing approach
- build/run workflow

### 9.3 Keep the repo easy for agents to read

Practical cleanup rules:

- remove abandoned scripts
- delete obsolete docs instead of layering replacements on top
- prefer one canonical doc per topic
- rename ambiguous files
- keep generated output out of tracked source unless necessary

## 10. Suggested Repository Shape

```text
RoastMyHabits/
├── AGENTS.md
├── HARNESS.md
├── docs/
├── App/
│   ├── RoastMyHabitsApp.swift
│   ├── Models/
│   ├── Config/
│   ├── Repository/
│   ├── Service/
│   ├── ViewModel/
│   └── View/
├── Tests/
│   ├── Unit/
│   ├── Integration/
│   └── Evals/
├── Scripts/
│   ├── check-dependency-layers.sh
│   ├── check-doc-freshness.sh
│   └── run-roast-evals.sh
└── .swiftlint.yml
```

## 11. Immediate Gaps To Add

Based on the OpenAI post, the current harness should add these items if they do not already exist:

1. An `AGENTS.md` file that acts as Codex's short repo map.
2. Repository-local execution plans in `docs/exec-plans/`.
3. A documented command surface for build, test, lint, and eval runs.
4. Machine-readable structural checks for dependency boundaries.
5. A recurring cleanup loop for dead code, stale docs, and agent-hostile clutter.
6. Review norms that favor small PRs and frequent merges.

## 12. Summary

The harness for RoastMyHabits should optimize for four things:

1. Legibility: Codex can find the right context quickly.
2. Constraint: architecture and product promises are enforced mechanically.
3. Feedback: failures are short, actionable, and local to the repo.
4. Maintenance: the repo gets easier for agents to work in over time, not harder.

If Codex repeatedly fails in the same way, the next change should usually be to `AGENTS.md`, docs, checks, evals, or workflow, not just to the last patch.

## Sources

- [OpenAI, "Harness engineering"](https://openai.com/index/harness-engineering/)
- [PRD Roast My Habits (MVP)](/Users/luca/git/RoastMyHabits/PRD%20Roast%20My%20Habits%20%28MVP%29.md)
