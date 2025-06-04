# Music Repeater - iOS App

## Overview

Music Repeater is an iOS app that synchronizes play counts between different versions of the same song (e.g., single version vs. album version) by using fast-forwarded playback to quickly increment the play count of the album version to match the single version.

## Architecture

The app follows the MVVM (Model-View-ViewModel) pattern:

### 1. **Track Selection (MPMediaPickerController)**
- **Location**: `ContentView.swift` - `MediaPickerView` struct
- Uses `MPMediaPickerController` wrapped in a UIViewControllerRepresentable for SwiftUI
- Allows users to select individual tracks from their music library
- Handles delegate callbacks to pass selected items back to the view model

### 2. **Play Count Retrieval**
- **Location**: `MusicRepeaterViewModel.swift` - `selectSingleTrack()` and `selectAlbumTrack()` methods
- Retrieves play counts using `MPMediaItem.playCount` property
- Stores track information including title, artist, and current play count
- Updates UI bindings through `@Published` properties

### 3. **Fast-Forwarded Repeat Logic**
- **Location**: `MusicPlayerManager.swift` - `playNextIteration()` method
- Key steps:
  1. Calculates seek time as `duration - 30` seconds (or 85% of duration)
  2. Creates single-item queue with `MPMediaItemCollection`
  3. Uses `prepareToPlay()` followed by `currentPlaybackTime` setter
  4. Monitors `MPMusicPlayerControllerPlaybackStateDidChange` notifications
  5. Increments counter when playback reaches `.stopped` state
  6. Loops until all iterations complete

### 4. **Project Setup Requirements**

#### Info.plist Entries
Add the following to your Info.plist:

```xml
<key>NSAppleMusicUsageDescription</key>
<string>This app needs access to your music library to match play counts between versions of a song.</string>
```

#### Capabilities
No special capabilities are required, but ensure your app has a valid bundle identifier and development team.

## File Structure

```
MusicRepeater/
├── MusicRepeaterApp.swift      # App entry point
├── ContentView.swift           # Main UI and media picker integration
├── MusicRepeaterViewModel.swift # Business logic and data management
├── MusicPlayerManager.swift    # Music playback and fast-forward logic
└── Info.plist                  # Required privacy descriptions
```

## Testing Instructions

### Requirements
- **Real Device Required**: The iOS Simulator does not have a music library or realistic play count behavior
- **iOS 17.0+**: Target device must run iOS 17 or later
- **Music Library**: Device must have songs in the Music app with existing play counts

### Test Scenario
1. Add two versions of the same song to your library:
   - Single version (e.g., "Song Title - SINGLE")
   - Album version (e.g., "Song Title - Album Name")

2. Play the single version multiple times to build up a play count

3. Launch the Music Repeater app

4. Tap "Choose Single Version" and select the single track

5. Tap "Choose Album Version" and select the album track

6. Tap "Match Play Count" to begin the fast-forwarded playback process

7. Monitor progress as the app plays through iterations

### Audio Note
**Important**: The app will play audible audio during the fast-forwarded sections. Please mute your device or use headphones when running rapid iterations.

## How It Works

### Play Count Matching Algorithm
```swift
timesToPlay = max(singlePlayCount - albumPlayCount, 0)
```

- If album already has equal or more plays: Shows message, no playback needed
- Otherwise: Performs `timesToPlay` fast-forwarded iterations

### Fast-Forward Technique
- Seeks to 30 seconds before the end of the track (or 85% through)
- iOS still counts this as a complete play for incrementing play count
- Each iteration takes only a few seconds instead of the full song duration

### Error Handling
- Checks for Music Library authorization on app launch
- Validates track selection before starting process
- Handles playback errors gracefully with user alerts
- Prevents starting if tracks aren't selected

## Limitations

1. Cannot directly modify play counts - must simulate actual playback
2. Requires physical device with Music library access
3. Will produce audio output during fast-forwarded sections
4. Play count updates may not reflect immediately in Music app (may require app restart)

## Development Notes

- Uses `MPMusicPlayerController.applicationMusicPlayer` to avoid interfering with system music
- Implements proper observer cleanup to prevent memory leaks
- Handles background/foreground transitions appropriately
- All UI updates performed on main thread