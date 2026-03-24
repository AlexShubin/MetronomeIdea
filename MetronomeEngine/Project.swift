import ProjectDescription

let project = Project(
    name: "MetronomeEngine",
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.0",
            "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
            "SWIFT_EMIT_LOC_STRINGS": "YES",
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
        .target(
            name: "MetronomeEngineTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.alexshubin.MetronomeEngineTests",
            deploymentTargets: .iOS("26.0"),
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "MetronomeEngine"),
            ]
        ),
    ]
)
