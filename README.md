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

Specify your `Podfile`:

``` ruby
pod 'NTYAmrConverter', '~> 0.1'
```

### Carthage

Specify your `Cartfile`:

``` ogdl
github "ninty90/NTYAmrConverter" ~> 0.1
```

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
