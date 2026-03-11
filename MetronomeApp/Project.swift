import ProjectDescription

let project = Project(
    name: "MetronomeApp",
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.0",
            "SWIFT_DEFAULT_ACTOR_ISOLATION": "MainActor",
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
    ]
)
