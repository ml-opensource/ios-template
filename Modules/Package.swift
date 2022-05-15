// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.

        .library(name: "APIClient", targets: ["APIClient"]),
        .library(name: "APIClientLive", targets: ["APIClientLive"]),
        .library(name: "AppFeature", targets: ["AppFeature"]),
        .library(name: "AppVersion", targets: ["AppVersion"]),
        .library(name: "Helpers", targets: ["Helpers"]),
        .library(name: "Localizations", targets: ["Localizations"]),
        .library(name: "LoginFeature", targets: ["LoginFeature"]),
        .library(name: "MainFeature", targets: ["MainFeature"]),
        .library(name: "Model", targets: ["Model"]),
        .library(name: "NetworkClient", targets: ["NetworkClient"]),
        .library(name: "PersistenceClient", targets: ["PersistenceClient"]),
        .library(name: "ProductFeature", targets: ["ProductFeature"]),
        .library(name: "Style", targets: ["Style"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.6.0"),
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "0.3.2"),
        .package(url: "https://github.com/pointfreeco/combine-schedulers", from: "0.5.3"),
        .package(url: "https://github.com/pointfreeco/swiftui-navigation", from: "0.1.0"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "0.2.1"),
        .package(url: "https://github.com/nstack-io/nstack-ios-sdk", branch: "feature/spm-support"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "APIClient",
            dependencies: [
                "Model", .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
            ],
            resources: []
        ),
        .target(
            name: "APIClientLive",
            dependencies: ["APIClient", "Model"],
            resources: []
        ),
        .testTarget(
            name: "APIClientLiveTests",
            dependencies: [
                "APIClientLive"
            ]),
        .target(
            name: "AppFeature",
            dependencies: [
                "APIClient", "LoginFeature", "MainFeature", "NetworkClient",
                "PersistenceClient",
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
                .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
            ],
            resources: []
        ),
        .target(
            name: "AppVersion",
            dependencies: [
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
            ],
            resources: []
        ),
        .target(
            name: "Helpers",
            dependencies: [],
            resources: []
        ),
        .target(
            name: "LoginFeature",
            dependencies: [
                "APIClient", "AppVersion",
                .product(name: "CombineSchedulers", package: "combine-schedulers"), "Localizations",
                "Model", "Style",
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
            ],
            resources: []
        ),
        .testTarget(
            name: "LoginFeatureTests",
            dependencies: [
                "LoginFeature", .product(name: "CombineSchedulers", package: "combine-schedulers"),
            ]),
        .target(
            name: "Localizations",
            dependencies: [.product(name: "NStackSDK", package: "nstack-ios-sdk")],
            exclude: ["SKLocalizations.swift"],
            resources: [.copy("Localizations_da-DK.json")]
        ),
        .target(
            name: "MainFeature",
            dependencies: [
                "APIClient", "AppVersion",
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                "Localizations",
                "Model", "Style",
                .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
            ],
            resources: []
        ),
        .testTarget(
            name: "MainFeatureTests",
            dependencies: [
                "MainFeature", .product(name: "CombineSchedulers", package: "combine-schedulers"),
            ]
        ),
        .target(
            name: "ProductFeature",
            dependencies: [
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                "Localizations", "Model", "Style",
                .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
            ],
            resources: []
        ),
        .testTarget(
            name: "ProductFeatureTests",
            dependencies: [
                "ProductFeature",
                .product(name: "CombineSchedulers", package: "combine-schedulers"),
            ]),
        .target(
            name: "Model",
            dependencies: [
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
            ],
            resources: []),
        .target(
            name: "NetworkClient",
            dependencies: [
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay")
            ],
            resources: []
        ),

        .target(
            name: "PersistenceClient",
            dependencies: ["Model"],
            resources: []
        ),

        .target(
            name: "Style",
            dependencies: [
                "Helpers", .product(name: "SwiftUINavigation", package: "swiftui-navigation"),
            ],
            resources: [.process("Colors.xcassets"), .process("Fonts")]),
    ]
)
