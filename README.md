# MemeMe

This iOS app allows the user to record to create a meme using a personal photo and custom text. It was submitted to Udacity as a project for their iOS Nanodegree Program. The project met specifications.

MemeMe was written in Swift 2.2

## Install

In order to run this app you will need Xcode 7.3. If using a personal iOS device, it will need to have iOS 9.2 or later installed.

1. Open `Pitch Perfect.xcodeproj` in Xcode
2. Build and run the project on the simulator or on a personal iOS device.

## Known Issues

The following error appears in the debugger when the camera is selected to take a new photo for the meme.

> Snapshotting a view that has not been rendered results in an empty snapshot. Ensure your view has been rendered at least once before snapshotting or snapshot after screen updates.

There is no apparent effect on user experience. It appears to be a reported bug regarding the UIImagePickerController.

## Attributions

The table and collection icons were provided by Udacity.
