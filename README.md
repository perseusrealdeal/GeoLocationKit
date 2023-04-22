# PerseusGeoLocationKit — Xcode 10.1+

> This is the component for macOS and iOS apps.

[![Actions Status](https://github.com/perseusrealdeal/PerseusGeoLocationKit/actions/workflows/main.yml/badge.svg)](https://github.com/perseusrealdeal/PerseusGeoLocationKit/actions)
![Version](https://img.shields.io/badge/Version-0.1.0-green.svg)
[![Pod](https://img.shields.io/badge/Pod-0.1.0-informational.svg)](/PerseusGeoLocationKit.podspec)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%209.3+_|_macOS%2010.9+-orange.svg)](https://en.wikipedia.org/wiki/IOS_9)
[![Xcode 10.1](https://img.shields.io/badge/Xcode-10.1+-red.svg)](https://en.wikipedia.org/wiki/Xcode)
[![Swift 4.2](https://img.shields.io/badge/Swift-4.2-red.svg)](https://docs.swift.org/swift-book/RevisionHistory/RevisionHistory.html)
[![License](http://img.shields.io/:License-MIT-blue.svg)](/LICENSE)

## Integration Capabilities

[![Standalone](https://img.shields.io/badge/Standalone%20-available-informational.svg)](/PerseusGeoLocationSingle.swift)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage)
[![CocoaPods manager](https://img.shields.io/badge/CocoaPods-compatible-4BC51D.svg)](https://cocoapods.org)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-4BC51D.svg)](https://github.com/apple/swift-package-manager)

# In Brief

> Collection of tools for easy dealing with native geo location services.

# Requirements

- [macOS 10.13.6+](https://apps.apple.com/us/app/macos-high-sierra/id1246284741?ls=1)
- [Xcode 10.1+](https://stackoverflow.com/questions/10335747/how-to-download-xcode-dmg-or-xip-file)
- Swift 4.2+
- iOS: 9.3+, UIKit SDK
- macOS: 10.9+, AppKit SDK

# First-party software

- [PerseusLogger](https://gist.github.com/perseusrealdeal/df456a9825fcface44eca738056eb6d5)

# Third-party software

- [SwiftLint Shell Script Runner](/SucceedsPostAction.sh)
- [SwiftLint](https://github.com/realm/SwiftLint) / [0.31.0: Busy Laundromat](https://github.com/realm/SwiftLint/releases/tag/0.31.0) for macOS High Sierra

# Usage

`Step 1:` Get ready for location services

| Info.plist                          | iOS      | macOS                  | Location manager's method       |
| ----------------------------------- | -------- | ---------------------- | ------------------------------- |
| NSLocationUsageDescription          |          | macOS 10.6+, optional  | startUpdatingLocation()         |
| NSLocationAlwaysUsageDescription    | required | macOS 10.15+, optional | requestAlwaysAuthorization()    | 
| NSLocationWhenInUseUsageDescription | required | macOS 10.15+, optional | requestWhenInUseAuthorization() |

`Step 2:` Create notification observer

```swift
```

`Step 3:` Ask for current location

```swift
```

# Installation

## Standalone 

Make a copy of the file [`PerseusGeoLocationSingle.swift`](/PerseusGeoLocationSingle.swift) then put it into a place required of a host project.

## Carthage

Cartfile should contain:

```carthage
github "perseusrealdeal/PerseusGeoLocationKit" == 0.1.0
```

Some Carthage usage tips placed [here](https://gist.github.com/perseusrealdeal/8951b10f4330325df6347aaaa79d3cf2).

## CocoaPods

Podfile should contain:

```ruby
target "ProjectTarget" do
  use_frameworks!
  pod 'PerseusGeoLocationKit', '0.1.0'
end
```

## Swift Package Manager

- As a package dependency so Package.swift should contain the following statements:

```swift
dependencies: [
        .package(url: "https://github.com/perseusrealdeal/PerseusGeoLocationKit.git",
            .exact("0.1.0"))
    ],
```

- As an Xcode project dependency: 

`Project in the Navigator > Package Dependencies > Add Package Dependency`

Using "Exact" with the Version field is strongly recommended.

# License MIT

All files from this repository is under license based on MIT.

Copyright © 7531 Mikhail Zhigulin of Novosibirsk.

- The year starts from the creation of the world according to a Slavic calendar
- September, the 1st of Slavic year

Have a look at [LICENSE](/LICENSE) for details.

# Author

> `PerseusGeoLocationKit` was written at Novosibirsk by Mikhail Zhigulin i.e. me, mzhigulin@gmail.com.
