# Youtube Player Plugin

[![pub package](https://img.shields.io/badge/pub-v3.2.1-green.svg)](https://pub.dartlang.org/packages/youtube_player) [![Build Status](https://travis-ci.org/sarbagyastha/youtube_player.svg?branch=master)](https://travis-ci.org/sarbagyastha/youtube_player) [![licence](https://img.shields.io/badge/Licence-MIT-orange.svg)](https://github.com/sarbagyastha/youtube_player/blob/master/LICENSE)


A flutter plugin to play Youtube Videos "inline" without API Key in range of Qualities(240p, 360p, 480p, 720p and 1080p).

## Released *New* Youtube Player based on Official Iframe API
This plugin only supports Android and is a bit hacky approach to playing YouTube videos.

So, published a new plugin [youtube_player_flutter](https://pub.dartlang.org/packages/youtube_player_flutter) which is an officially provided way of playing youtube videos, supporting both **Android** and **iOS** platforms.

Note: will keep on updating this plugin too.

## Salient Features
  - Inline playback
  - Thumbnail Support
  - Youtube-like controls
  - Customizable Controls
  - Supports HD and Full HD quality
  - Playable through <video id> or <link>
  - No need for API Key and no Limitations
  - Supports Live Stream Videos

![DEMO](example_demo.gif) 

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
  youtube_player: ^3.2.1
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
      _videoController = controller;
    },
),
```
         
#### 5\. Playing livestream videos
Must set isLive property to true in order to play livestream videos.

```dart
YoutubePlayer(
    context: context,
    source: "ddFvjfvPnqk",
    quality: YoutubeQuality.HD,
    **isLive: true,**
),
```

## Note:
In scenario, where one need to navigate to next page and return. 
You'll need to pause the video before navigating, otherwise the video will keep on playing.

```dart
RaisedButton(
    child: Text("Next Page"),
    onPressed: () {
          _videoController.pause();
          Navigator.of(context).push(
               MaterialPageRoute(builder: (context) => NextPage()),
          );
    },
),
```

## Didn't like the controls ?
Don't worry, Got a solution for you. 😉
Set the playermode to NO_CONTROLS, then you can create your own custom controls using the controller obtained from callbackController property.

```dart
YoutubePlayer(
    context: context,
    source: "ddFvjfvPnqk",
    playerMode: YoutubePlayerMode.NO_CONTROLS,
    callbackController: (controller) {
      _videoController = controller;
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
| controlsTimeOut | Timeout for showing controls like play, pause, etc. | Optional. Default = 3 seconds |
| startAt | Sets the starting position of the video. | Optional. |
| showThumbnail | Shows thumbnail when video is initializing. | Optional. Default = true |
| keepScreenOn | Triggers screen to be on when not in fullscreen. | Optional. Default = true |
| showVideoProgressBar | Shows progressbar below the video. | Optional. Default = true |
| startFullScreen | Start video in a full screen. | Optional. Default = false |
| playerMode | Sets player mode. YoutubePlayerMode.NO_CONTROLS hides the controls from player. *Useful when custom controls are to be build.* | Optional. Default = YoutubePlayerMode.DEFAULT |
| onError | Callback which reports error. | Optional.|
| onVideoEnded | Callback which reports end of video. | Optional.|
| callbackController | Callback which provides current Video Controller. | Optional.|



## Example

[Example sources](https://github.com/sarbagyastha/youtube_player/tree/master/example)


### Limitation
* Only Available for Android

### Download
[Download apk](youtube_player_example.apk) and try the plugin.

***Credit***

This plugin is a fork of [video_player](https://github.com/flutter/plugins/tree/master/packages/video_player), developed by [@Flutter Team](https://github.com/flutter).


## License

```
Copyright (c) 2019 Sarbagya Dhaubanjar

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

