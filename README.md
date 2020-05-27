# kaltura-meetings-ios

This is a simple iOS app showing how to launch a Kaltura Meetings room in an embedded Safari browser, leveraging the Kaltura Application Framework (KAF). See the [Kaltura Meetings integration guide](https://pitch.kaltura-pitch.com/message/5477b884c5447a4bbd0633efb1556345cf459f9915c38c6186ae4235fa12) for more information.

## Prerequisites

- Xcode 10.0+
- Physical iOS device

## Quick Start

1. From the command line, execute "pod install" to acquire the necessary pods to build and execute this app.
2. Open *KalturaMeetings.xcworkspace* in Xcode.
3. In ViewController.swift, fill in the necessary parameters in the TODO section (userSecret, partnerId, kafEndpoint, resourceId).
4. Connect your iOS device, select it as your build target, build and run the app.
