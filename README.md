# PerseusGeoLocationKit — Xcode 14.2+

[`iOS approbation app`](https://github.com/perseusrealdeal/iOS.DarkMode.Discovery) [`macOS approbation app`](https://github.com/perseusrealdeal/macOS.DarkMode.Discovery)

`PerseusGeoLocationKit` is a single author and personale solution developed in `person-to-person` relationship paradigm.

[![Actions Status](https://github.com/perseusrealdeal/PerseusGeoLocationKit/actions/workflows/main.yml/badge.svg)](https://github.com/perseusrealdeal/PerseusGeoLocationKit/actions/workflows/main.yml)
[![Style](https://github.com/perseusrealdeal/PerseusGeoLocationKit/actions/workflows/swiftlint.yml/badge.svg)](https://github.com/perseusrealdeal/PerseusGeoLocationKit/actions/workflows/swiftlint.yml)
[![Version](https://img.shields.io/badge/Version-1.0.0-green.svg)](/CHANGELOG.md)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%2010.13+_|_iOS%2011.0+-orange.svg)](https://en.wikipedia.org/wiki/List_of_Apple_products)
[![Xcode 14.2](https://img.shields.io/badge/Xcode-14.2+-red.svg)](https://en.wikipedia.org/wiki/Xcode)
[![Swift 5.7](https://img.shields.io/badge/Swift-5.7-red.svg)](https://www.swift.org)
[![License](http://img.shields.io/:License-MIT-blue.svg)](/LICENSE)

## Integration Capabilities

[![Standalone](https://img.shields.io/badge/Standalone%20-available-informational.svg)](/PerseusGeoStar.swift)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-4BC51D.svg)](/Package.swift)

## Approbation Matrix

> [A3 Environment](https://docs.google.com/document/d/1K2jOeIknKRRpTEEIPKhxO2H_1eBTof5uTXxyOm5g6nQ/edit?usp=sharing) / [Approbation Results](/APPROBATION.md) / [CHANGELOG](/CHANGELOG.md) for details.

## In brief > Idea to use, the Why

Package in Swift designed as a wrapper for Location Services API both for iOS and macOS apps.

## Build system requirements

- [macOS Monterey 12.7.6+](https://apps.apple.com/by/app/macos-monterey/id1576738294) / [Xcode 14.2+](https://developer.apple.com/services-account/download?path=/Developer_Tools/Xcode_14.2/Xcode_14.2.xip)

# First-party software

- [ConsolePerseusLogger](https://github.com/perseusrealdeal/ConsolePerseusLogger) / [1.0.3](https://github.com/perseusrealdeal/ConsolePerseusLogger/releases/tag/1.0.3)

# Installation

## Standalone

Use the single source code file [PerseusGeoStar.swift](https://github.com/perseusrealdeal/PerseusGeoLocationKit/blob/b7f41e09869f264a501807bb1b7a25c2b5b9e08b/PerseusGeoStar.swift) directly in your project.

## Swift Package Manager

`Project in the Navigator > Package Dependencies > Add Package Dependency`

> Put the following line in the package search field:

`https://github.com/perseusrealdeal/PerseusGeoLocationKit`

> Dependency rule: 

`Up to Next Major Version`

# Usage

`Step 1:` Put Location Services Declaration messages to Info.plist

| Info.plist                                   | iOS 16.2 .always | macOS 12.7.6 |
| -------------------------------------------- | ---------------- | ------------ |
| NSLocationUsageDescription                   |                  | required     |
| NSLocationAlwaysUsageDescription             |                  |              |
| NSLocationWhenInUseUsageDescription          | required         |              |
| NSLocationAlwaysAndWhenInUseUsageDescription | required         |              |

`Step 2:` Install the package dependency in the prefered way either Standalone or SPM

`Step 3:` Locate Location Services Agent globally (recommended) kinda custom service object in your app

`Setp 4:` Configure Accuracy and GoTo Settings Alert 

`Step 5:` Deal with Location Services permission 

`Step 6:` Process Location Services events

`Step 7 A:` Request current location

`Step 7 B:` Request start/stop location updates


# Third-party software

- Style [SwiftLint](https://github.com/realm/SwiftLint) / [Shell Script](/SucceedsPostAction.sh)
- Action [mxcl/xcodebuild@v3.3](https://github.com/mxcl/xcodebuild/releases/tag/v3.3.0)
- Action [cirruslabs/swiftlint-action@v1](https://github.com/cirruslabs/swiftlint-action/releases/tag/v1.0.0)

# Points taken into account

- Preconfigured Swift Package manifest [Package.swift](/Package.swift)
- Preconfigured SwiftLint config [.swiftlint.yml](/.swiftlint.yml)
- Preconfigured SwiftLint CI [swiftlint.yml](/.github/workflows/swiftlint.yml)
- Preconfigured GitHub config [.gitignore](/.gitignore)
- Preconfigured GitHub CI [main.yml](/.github/workflows/main.yml)

# License MIT

Copyright © 7531 - 7533 Mikhail A. Zhigulin of Novosibirsk<br/>
Copyright © 7533 PerseusRealDeal

- The year starts from the creation of the world according to a Slavic calendar.
- September, the 1st of Slavic year. It means that "Sep 01, 2024" is the beginning of 7533.

[LICENSE](/LICENSE) for details.

## Credits

<table>
<tr>
    <td>Balance and Control</td>
    <td>kept by</td>
    <td>Mikhail A. Zhigulin</td>
</tr>
<tr>
    <td>Source Code</td>
    <td>written by</td>
    <td>Mikhail A. Zhigulin</td>
</tr>
<tr>
    <td>Documentation</td>
    <td>prepared by</td>
    <td>Mikhail A. Zhigulin</td>
</tr>
<tr>
    <td>Product Approbation</td>
    <td>tested by</td>
    <td>Mikhail A. Zhigulin</td>
</tr>
</table>

- Language support: [Reverso](https://www.reverso.net/)
- Git client: [SmartGit](https://syntevo.com/)

# Author

> Mikhail A. Zhigulin of Novosibirsk.
