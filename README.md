# NTYAmrConverter

<p align="left">

<a href="https://travis-ci.org/ninty90/NTYAmrConverter"><img src="https://travis-ci.org/ninty90/NTYAmrConverter.svg?branch=master"></a>

<a href="https://github.com/Carthage/Carthage/"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>

<a href="http://cocoadocs.org/docsets/NTYAmrConverter"><img src="https://img.shields.io/cocoapods/v/NTYAmrConverter.svg?style=flat"></a>

<a href="https://raw.githubusercontent.com/ninty90/NTYAmrConverter/master/LICENSE"><img src="https://img.shields.io/cocoapods/l/NTYAmrConverter.svg?style=flat"></a>

<a href="http://cocoadocs.org/docsets/NTYAmrConverter"><img src="https://img.shields.io/cocoapods/p/NTYAmrConverter.svg?style=flat"></a>

</p>

Converter between .amr and .wav file

## Requirements

* iOS 8.0+
* Xcode 7.3 or above

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

``` bash
$ gem install cocoapods
```

To integrate NTYAmrConverter into your Xcode project using CocoaPods, specify it in your `Podfile`:

``` ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'NTYAmrConverter', '~> 0.1'
```

Then, run the following command:

``` bash
$ pod install
```

You should open the `{Project}.xcworkspace` instead of the `{Project}.xcodeproj` after you installed anything from CocoaPods.

For more information about how to use CocoaPods, I suggest [this tutorial](http://www.raywenderlich.com/64546/introduction-to-cocoapods-2).

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager for Cocoa application. To install the carthage tool, you can use [Homebrew](http://brew.sh).

``` bash
$ brew update
$ brew install carthage
```

To integrate NTYAmrConverter into your Xcode project using Carthage, specify it in your `Cartfile`:

``` ogdl
github "ninty90/NTYAmrConverter" ~> 0.1
```

Then, run the following command to build the NTYAmrConverter framework:

``` bash
$ carthage update

```

At last, you need to set up your Xcode project manually to add the NTYAmrConverter framework.

On your application targets’ “General” settings tab, in the “Linked Frameworks and Libraries” section, drag and drop each framework you want to use from the Carthage/Build folder on disk.

On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase”. Create a Run Script with the following content:

``` 
/usr/local/bin/carthage copy-frameworks
```

and add the paths to the frameworks you want to use under “Input Files”:

``` 
$(SRCROOT)/Carthage/Build/iOS/NTYAmrConverter.framework
```

For more information about how to use Carthage, please see its [project page](https://github.com/Carthage/Carthage).

### Manually

It is not recommended to install the framework manually, but if you prefer not to use either of the aforementioned dependency managers, you can integrate NTYAmrConverter into your project manually. A regular way to use NTYAmrConverter in your project would be using Embedded Framework.

- Add NTYAmrConverter as a [submodule](http://git-scm.com/docs/git-submodule). In your favorite terminal, `cd` into your top-level project directory, and entering the following command:

``` bash
$ git submodule add https://github.com/ninty90/NTYAmrConverter.git
```

- Open the `NTYAmrConverter` folder, and drag `NTYAmrConverter.xcodeproj` into the file navigator of your app project, under your app project.
- In Xcode, navigate to the target configuration window by clicking on the blue project icon, and selecting the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "Build Phases" panel.
- Expand the "Target Dependencies" group, and add `NTYAmrConverter.framework`.
- Click on the `+` button at the top left of "Build Phases" panel and select "New Copy Files Phase". Rename this new phase to "Copy Frameworks", set the "Destination" to "Frameworks", and add `NTYAmrConverter.framework` of the platform you need.

## Usage

In your swift project, use like this:

``` swift
import NTYAmrConverter

// encode wav to amr
NTYAmrCoder.encodeWavFile(wavPath, toAmrFile: amrPath)

// decode amr to wav
NTYAmrCoder.decodeAmrFile(amrPath, toWavFile: convertedWavPath)

```

You can find the full API documentation at [CocoaDocs](http://cocoadocs.org/docsets/NTYAmrConverter/).

You can also see the Demo, 
to run the Demo, use `pod install` first.

## License

NTYAmrConverter is released under the MIT license. See LICENSE for details.
