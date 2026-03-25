import ProjectDescription

let project = Project(
    name: "MetronomeApp",
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.0",
            "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
            "SWIFT_EMIT_LOC_STRINGS": "YES",
            "CODE_SIGN_STYLE": "Manual",
            "CODE_SIGN_IDENTITY": "Apple Development",
            "DEVELOPMENT_TEAM": "",
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release"),
        ]
    ),
    targets: [
        .target(
            name: "MetronomeApp",
            destinations: .iOS,
            product: .app,
            bundleId: "com.alexshubin.MetronomeApp",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": ["UIColorName": "", "UIImageName": ""],
            ]),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "MetronomeEngine", path: "../MetronomeEngine"),
            ]
        ),
        .target(
            name: "MetronomeAppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.alexshubin.MetronomeAppTests",
            deploymentTargets: .iOS("26.0"),
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "MetronomeApp"),
                .project(target: "MetronomeEngine", path: "../MetronomeEngine"),
                .project(target: "MetronomeEngineTestSupport", path: "../MetronomeEngine"),
            ]
        ),
    ]
)
