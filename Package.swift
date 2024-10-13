// swift-tools-version:5.8
//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2017-2021 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import PackageDescription

// Used only for environment variables, does not make its way
// into the product code.
import class Foundation.ProcessInfo

// This package contains a vendored copy of BoringSSL. For ease of tracking
// down problems with the copy of BoringSSL in use, we include a copy of the
// commit hash of the revision of BoringSSL included in the given release.
// This is also reproduced in a file called hash.txt in the
// Sources/CNIOBoringSSL directory. The source repository is at
// https://boringssl.googlesource.com/boringssl.
//
// BoringSSL Commit: d0a175601b9e180ce58cb1e33649057f5c484146

/// This function generates the dependencies we want to express.
///
/// Importantly, it tolerates the possibility that we are being used as part
/// of the Swift toolchain, and so need to use local checkouts of our
/// dependencies.
func generateDependencies() -> [Package.Dependency] {
    if ProcessInfo.processInfo.environment["SWIFTCI_USE_LOCAL_DEPS"] == nil {
        return [
            .package(url: "https://github.com/apple/swift-nio.git", from: "2.54.0"),
            .package(url: "https://github.com/swiftlang/swift-docc-plugin.git", from: "1.0.0"),
        ]
    } else {
        return [
            .package(path: "../swift-nio"),
        ]
    }
}

// This doesn't work when cross-compiling: the privacy manifest will be included in the Bundle and
// Foundation will be linked. This is, however, strictly better than unconditionally adding the
// resource.
#if canImport(Darwin)
let includePrivacyManifest = true
#else
let includePrivacyManifest = false
#endif

let package = Package(
    name: "swift-boring-ssl",
    products: [
        .library(name: "CBoringSSL", type: .static, targets: ["CBoringSSL"]),
    ],
    dependencies: generateDependencies(),
    targets: [
        .target(
            name: "CBoringSSL",
            cSettings: [
              .define("_GNU_SOURCE"),
              .define("_POSIX_C_SOURCE", to: "200112L"),
              .define("_DARWIN_C_SOURCE")
            ]),
    ],
    cxxLanguageStandard: .cxx14
)
