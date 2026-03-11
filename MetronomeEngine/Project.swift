import ProjectDescription

let project = Project(
    name: "MetronomeEngine",
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.0",
            "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release"),
        ]
    ),
    targets: [
        .target(
            name: "MetronomeEngine",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.alexshubin.MetronomeEngine",
            deploymentTargets: .iOS("26.0"),
            sources: ["Sources/**"],
            resources: ["Resources/**"]
        ),
    ]
)
