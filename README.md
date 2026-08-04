# Chess Clock

A simple iPhone chess clock for over the board games when there is no physical clock around.

The app is inspired by the clean time control flow in Chess.com, but focused on being a fast local clock you can hand to two players and start using right away.

## Project In Action

<p>
  <img src="ui/images/Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202026-08-04%20at%2013.33.58.png" width="180" alt="Chess Clock splash screen">
  <img src="ui/images/Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202026-08-04%20at%2013.34.01.png" width="180" alt="Time control setup in light mode">
  <img src="ui/images/Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202026-08-04%20at%2013.34.08.png" width="180" alt="Time control setup in dark mode">
</p>

<p>
  <img src="ui/images/Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202026-08-04%20at%2013.34.23.png" width="180" alt="Clock color settings">
  <img src="ui/images/Simulator%20Screenshot%20-%20iPhone%2017%20Pro%20-%202026-08-04%20at%2013.34.32.png" width="180" alt="Active chess clock">
</p>

## What It Does

- Pick common Bullet, Blitz, Rapid, and Daily time controls.
- Expand the setup screen for more options when needed.
- Configure custom time and increment.
- Configure Time Odds with different time and increment values for White and Black.
- Pick clock colors for each side.
- Switch between light and dark mode.
- Run a real two player clock with big tap targets, pause, resume, reset, and exit.

## Running It

Open `ChessClock.xcodeproj` in Xcode, choose the `ChessClock` scheme, and run it on an iPhone simulator or device.

The app currently targets iOS 16 and newer.

## Tech

- Swift
- SwiftUI
- Xcode project based setup

## Notes

This is still being built out. The main setup flow, active clock, color settings, custom controls, and Time Odds flow are already in place.
