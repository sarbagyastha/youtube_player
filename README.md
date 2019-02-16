# Youtube Player Plugin

[![pub package](https://img.shields.io/badge/pub-v3.0.1-green.svg)](https://pub.dartlang.org/packages/youtube_player)       [![](https://img.shields.io/badge/Licence-Apache%202-orange.svg)](https://github.com/sarbagyastha/youtube_player/blob/master/LICENSE)

A flutter plugin to play Youtube Videos "inline" without API Key in range of Qualities(240p, 360p, 480p, 720p and 1080p).

## Salient Features
  - Inline playback
  - Thumbnail Support
  - Youtube-like controls
  - Customizable Controls
  - Supports HD and Full HD quality
  - Playable through <video id> or <link>
  - No need for API Key and no Limitations
  - Supports Live Stream Videos

![DEMO](plugindemo.gif) 

## New Features in v3.x.x!
  - Change video quality on-the-fly.
  - Share video with other apps.
  - Fast Forward and Rewind with double tap.
  - Tap-and-hold to enter and exit fullscreen.
  - Auto resize as per the video's aspect ratio.

## Usage

#### 1\. Depend

Add this to you package's `pubspec.yaml` file:

```yaml
dependencies:
  youtube_player: ^3.0.1
```

#### 2\. Install

Run command:

```bash
$ flutter packages get
```

#### 3\. Import

Import in Dart code:

```dart
import 'package:youtube_player/youtube_player.dart';
```

#### 4\. Using Youtube Player

```dart
///
/// LOW = 240p
/// MEDIUM = 360p
/// HIGH = 480p
/// HD = 720p
/// FHD = 1080p
/// "source" can be either youtube video ID or link.
///
YoutubePlayer(
        context: context,
        source: "nPt8bK2gbaU",
        quality: YoutubeQuality.HD,
        // callbackController is (optional). 
        // use it to control player on your own.
        callbackController: (controller) {
            _controller = controller;
        },
),
```

## Details
| Property | Description | Remarks |
| ------ | ------ | ------ |
| source | Source of youtube video. Video ID or URL | Required. | 
| context | BuildContext of parent. | Required. |
| quality | Sets quality for youtube videos. | Required. |
| isLive | Denotes if the source is Live Video | Optional. Default = false.|
| aspectRatio | Sets aspect ratio of player's container  | Optional. Default = 16/9 |
| width | Sets width of player's container | Optional. Default = Screen width. *Must be less than Screen Width.* |
| controlsActiveBackgroundOverlay | Sets video-wide overlay when controls are active | Optional. Default = true.|
| controlsColor | Sets color of controls like play, pause, etc. | Optional. |
| startAt | Sets the starting position of the video. | Optional. |
| showThumbnail | Shows thumbnail when video is initializing. | Optional. Default = true |
| keepScreenOn | Triggers screen to be on when not in fullscreen. | Optional. Default = true |
| showVideoProgressBar | Shows progressbar below the video. | Optional. Default = true |
| playerMode | Sets player mode. YoutubePlayerMode.NO_CONTROLS hides the controls from player. *Useful when custom controls are to be build.* | Optional. Default = YoutubePlayerMode.DEFAULT |
| onError | Callback which reports error. | Optional.|
| onVideoEnded | Callback which reports end of video. | Optional.|
| callbackController | Callback which provides current Video Controller. | Optional.|



## Example

[Example sources](https://github.com/sarbagyastha/youtube_player/tree/master/example)

### Limitation
* Only Available for Android (Currently)

### Todos
* Support for ios
* Adaptive playback as per the internet bandwidth



***Credit***

This plugin is a fork of [video_player](https://github.com/flutter/plugins/tree/master/packages/video_player), developed by [@Flutter Team](https://github.com/flutter).


## License

```
Copyright 2019 Sarbagya Dhaubanjar

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

