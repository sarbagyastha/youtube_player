# Youtube Player Plugin 

[![pub package](https://img.shields.io/badge/pub-v1.0.1-brightgreen.svg)](https://pub.dartlang.org/packages/youtube_player)

A flutter plugin to play Youtube Videos "inline" without API Key in ranges of Quality(240p, 360p, 480p, 720p and 1080p).

### Salient Features
* Inline playback
* Supports HD and Full HD quality
* No need for API Key and no Limitations
* Thumbnail Support
* Playable through <video id> or <link>
* Customizable Controls


![DEMO](demo.gif) 

## Usage

#### 1\. Depend

Add this to you package's `pubspec.yaml` file:

```yaml
dependencies:
  youtube_player: ^1.0.1
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
/// "showThumbnail" Default is true.
/// "acpectRatio" Default is 16/9
/// "autoPlay" Default is true
///
YoutubePlayer(
          source: "nPt8bK2gbaU",
          quality: YoutubeQuality.HD,
          aspectRatio: 16/9,
          autoPlay: false,
          showThumbnail: true,
          // callbackController is (optional). 
          // use it to control player on your own.
          callbackController: (controller) {
            _controller = controller;
            },
),
```


## Example

[Example sources](https://github.com/sarbagyastha/youtube_player/tree/master/example)

### Limitation
* Only Available for Android (Currently)

### Future
* Support for ios
* Adaptive playback as per the internet bandwidth



***Credit***

This plugin is a fork of [video_player](https://github.com/flutter/plugins/tree/master/packages/video_player), which supports youtube playback.
The controls used in the plugin is derived from [chewie](https://github.com/brianegan/chewie).

Cheers to [@Flutter Team](https://flutter.io) and [@Brian Egan](https://github.com/brianegan) for developing such useful plugin and packages.


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
