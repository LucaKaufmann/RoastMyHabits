import ProjectDescription

let organizationName = "Luca Kaufmann"
let bundleIdentifier = "com.lucakaufmann.RoastMyHabits"

let baseSettings: SettingsDictionary = [
    "SWIFT_VERSION": "6.0",
    "SWIFT_STRICT_CONCURRENCY": "complete",
    "SWIFT_UPCOMING_FEATURE_DISABLE_OUTWARD_ACTOR_INFERENCE": "YES",
    "SWIFT_UPCOMING_FEATURE_GLOBAL_CONCURRENCY": "YES",
    "SWIFT_UPCOMING_FEATURE_INFER_SENDABLE_FROM_CAPTURES": "YES",
    "SWIFT_EMIT_LOC_STRINGS": "YES"
]

let appSettings = baseSettings.merging([
    "PRODUCT_BUNDLE_IDENTIFIER": .string(bundleIdentifier)
])

let testSettings = baseSettings.merging([
    "PRODUCT_BUNDLE_IDENTIFIER": .string("\(bundleIdentifier).tests")
])

let project = Project(
    name: "RoastMyHabits",
    organizationName: organizationName,
    settings: .settings(
        base: baseSettings,
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release")
        ]
    ),
    targets: [
        .target(
            name: "RoastMyHabits",
            destinations: .iOS,
            product: .app,
            bundleId: bundleIdentifier,
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "RoastMyHabits",
                "UILaunchScreen": [:],
                "UIUserInterfaceStyle": "Dark"
            ]),
            buildableFolders: [
                "App"
            ],
            settings: .settings(base: appSettings)
        ),
        .target(
            name: "RoastMyHabitsTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "\(bundleIdentifier).tests",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            buildableFolders: [
                "Tests"
            ],
            dependencies: [
                .target(name: "RoastMyHabits")
            ],
            settings: .settings(base: testSettings)
        )
    ]
)
