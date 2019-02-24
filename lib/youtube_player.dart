// Copyright 2019 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a Apache license that can be found
// in the LICENSE file.

/// Youtube Player
/// Author: Sarbagya Dhaubanjar
///
///                               ,,
///    .M"""bgd                  *MM
///   ,MI    "Y                   MM
///   `MMb.      ,6"Yb.  `7Mb,od8 MM,dMMb.   ,6"Yb.  .P"Ybmmm `7M'   `MF',6"Yb.
///     `YMMNq. 8)   MM    MM' "' MM    `Mb 8)   MM :MI  I8     VA   ,V 8)   MM
///   .     `MM  ,pm9MM    MM     MM     M8  ,pm9MM  WmmmP"      VA ,V   ,pm9MM
///   Mb     dM 8M   MM    MM     MM.   ,M9 8M   MM 8M            VVV   8M   MM
///   P"Ybmmd"  `Moo9^Yo..JMML.   P^YbmdP'  `Moo9^Yo.YMMMMMb      ,V    `Moo9^Yo.
///                                              6'     dP    ,V
///                                              Ybmmmd'   OOb"
///
///
///                ,,                           ,,                             ,,
///   `7MM"""Yb. `7MM                          *MM                             db
///     MM    `Yb. MM                           MM
///     MM     `Mb MMpMMMb.   ,6"Yb.`7MM  `7MM  MM,dMMb.   ,6"Yb.  `7MMpMMMb.`7MM  ,6"Yb.  `7Mb,od8
///     MM      MM MM    MM  8)   MM  MM    MM  MM    `Mb 8)   MM    MM    MM  MM 8)   MM    MM' "'
///     MM     ,MP MM    MM   ,pm9MM  MM    MM  MM     M8  ,pm9MM    MM    MM  MM  ,pm9MM    MM
///     MM    ,dP' MM    MM  8M   MM  MM    MM  MM.   ,M9 8M   MM    MM    MM  MM 8M   MM    MM
///   .JMMmmmdP' .JMML  JMML.`Moo9^Yo.`Mbod"YML.P^YbmdP'  `Moo9^Yo..JMML  JMML.MM `Moo9^Yo..JMML.
///                                                                         QO MP
///                                                                         `bmP

/// Website: https://sarbagyastha.com.np
/// Github: https://github.com/sarbagyastha/youtube_player
///

import 'dart:io';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player/controls.dart';

enum YoutubeQuality { LOW, MEDIUM, HIGH, HD, FHD }
enum YoutubePlayerMode { DEFAULT, NO_CONTROLS }

final MethodChannel _channel =
    const MethodChannel('sarbagyastha.com.np/youtubePlayer')
      ..invokeMethod('init');

class DurationRange {
  DurationRange(this.start, this.end);

  final Duration start;
  final Duration end;

  double startFraction(Duration duration) {
    return start.inMilliseconds / duration.inMilliseconds;
  }

  double endFraction(Duration duration) {
    return end.inMilliseconds / duration.inMilliseconds;
  }

  @override
  String toString() => '$runtimeType(start: $start, end: $end)';
}

/// The duration, current position, buffering state, error state and settings
/// of a [VideoPlayerController].
class VideoPlayerValue {
  VideoPlayerValue({
    @required this.duration,
    this.size,
    this.position = const Duration(),
    this.buffered = const <DurationRange>[],
    this.isPlaying = false,
    this.isLooping = false,
    this.isBuffering = false,
    this.volume = 1.0,
    this.errorDescription,
  });

  VideoPlayerValue.uninitialized() : this(duration: null);

  VideoPlayerValue.erroneous(String errorDescription)
      : this(duration: null, errorDescription: errorDescription);

  /// The total duration of the video.
  ///
  /// Is null when [initialized] is false.
  final Duration duration;

  /// The current playback position.
  final Duration position;

  /// The currently buffered ranges.
  final List<DurationRange> buffered;

  /// True if the video is playing. False if it's paused.
  final bool isPlaying;

  /// True if the video is looping.
  final bool isLooping;

  /// True if the video is currently buffering.
  final bool isBuffering;

  /// The current volume of the playback.
  final double volume;

  /// A description of the error if present.
  ///
  /// If [hasError] is false this is [null].
  final String errorDescription;

  /// The [size] of the currently loaded video.
  ///
  /// Is null when [initialized] is false.
  final Size size;

  bool get initialized => duration != null;
  bool get hasError => errorDescription != null;
  double get aspectRatio => size != null ? size.width / size.height : 1.0;

  VideoPlayerValue copyWith({
    Duration duration,
    Size size,
    Duration position,
    List<DurationRange> buffered,
    bool isPlaying,
    bool isLooping,
    bool isBuffering,
    double volume,
    String errorDescription,
  }) {
    return VideoPlayerValue(
      duration: duration ?? this.duration,
      size: size ?? this.size,
      position: position ?? this.position,
      buffered: buffered ?? this.buffered,
      isPlaying: isPlaying ?? this.isPlaying,
      isLooping: isLooping ?? this.isLooping,
      isBuffering: isBuffering ?? this.isBuffering,
      volume: volume ?? this.volume,
      errorDescription: errorDescription ?? this.errorDescription,
    );
  }

  @override
  String toString() {
    return '$runtimeType('
        'duration: $duration, '
        'size: $size, '
        'position: $position, '
        'buffered: [${buffered.join(', ')}], '
        'isPlaying: $isPlaying, '
        'isLooping: $isLooping, '
        'isBuffering: $isBuffering'
        'volume: $volume, '
        'errorDescription: $errorDescription)';
  }
}

enum DataSourceType { asset, network, file }

/// Controls a platform video player, and provides updates when the state is
/// changing.
///
/// Instances must be initialized with initialize.
///
/// The video is displayed in a Flutter app by creating a [VideoPlayer] widget.
///
/// To reclaim the resources used by the player call [dispose].
///
/// After [dispose] all further calls are ignored.
class VideoPlayerController extends ValueNotifier<VideoPlayerValue> {
  /// Constructs a [VideoPlayerController] playing a video from an asset.
  ///
  /// The name of the asset is given by the [dataSource] argument and must not be
  /// null. The [package] argument must be non-null when the asset comes from a
  /// package and null otherwise.
  VideoPlayerController.asset(this.dataSource, {this.package})
      : dataSourceType = DataSourceType.asset,
        super(VideoPlayerValue(duration: null));

  /// Constructs a [VideoPlayerController] playing a video from obtained from
  /// the network.
  ///
  /// The URI for the video is given by the [dataSource] argument and must not be
  /// null.
  VideoPlayerController.network(this.dataSource)
      : dataSourceType = DataSourceType.network,
        package = null,
        super(VideoPlayerValue(duration: null));

  /// Constructs a [VideoPlayerController] playing a video from a file.
  ///
  /// This will load the file from the file-URI given by:
  /// `'file://${file.path}'`.
  VideoPlayerController.file(File file)
      : dataSource = 'file://${file.path}',
        dataSourceType = DataSourceType.file,
        package = null,
        super(VideoPlayerValue(duration: null));

  int _textureId;
  final String dataSource;

  /// Describes the type of data source this [VideoPlayerController]
  /// is constructed with.
  final DataSourceType dataSourceType;

  final String package;
  Timer _timer;
  bool _isDisposed = false;
  Completer<void> _creatingCompleter;
  StreamSubscription<dynamic> _eventSubscription;
  _VideoAppLifeCycleObserver _lifeCycleObserver;

  @visibleForTesting
  int get textureId => _textureId;

  Future<void> initialize() async {
    _lifeCycleObserver = _VideoAppLifeCycleObserver(this);
    _lifeCycleObserver.initialize();
    _creatingCompleter = Completer<void>();
    Map<dynamic, dynamic> dataSourceDescription;
    switch (dataSourceType) {
      case DataSourceType.asset:
        dataSourceDescription = <String, dynamic>{
          'asset': dataSource,
          'package': package
        };
        break;
      case DataSourceType.network:
        dataSourceDescription = <String, dynamic>{'uri': dataSource};
        break;
      case DataSourceType.file:
        dataSourceDescription = <String, dynamic>{'uri': dataSource};
    }
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final Map<dynamic, dynamic> response = await _channel.invokeMethod(
      'create',
      dataSourceDescription,
    );
    _textureId = response['textureId'];
    if (!_creatingCompleter.isCompleted) {
      _creatingCompleter.complete(null);
    }
    final Completer<void> initializingCompleter = Completer<void>();

    DurationRange toDurationRange(dynamic value) {
      final List<dynamic> pair = value;
      return DurationRange(
        Duration(milliseconds: pair[0]),
        Duration(milliseconds: pair[1]),
      );
    }

    void eventListener(dynamic event) {
      final Map<dynamic, dynamic> map = event;
      switch (map['event']) {
        case 'initialized':
          value = value.copyWith(
            duration: Duration(milliseconds: map['duration']),
            size: Size(map['width']?.toDouble() ?? 0.0,
                map['height']?.toDouble() ?? 0.0),
          );
          initializingCompleter.complete(null);
          _applyLooping();
          _applyVolume();
          _applyPlayPause();
          break;
        case 'completed':
          value = value.copyWith(isPlaying: false);
          _timer?.cancel();
          break;
        case 'bufferingUpdate':
          final List<dynamic> values = map['values'];
          value = value.copyWith(
            buffered: values.map<DurationRange>(toDurationRange).toList(),
          );
          break;
        case 'bufferingStart':
          value = value.copyWith(isBuffering: true);
          break;
        case 'bufferingEnd':
          value = value.copyWith(isBuffering: false);
          break;
      }
    }

    void errorListener(Object obj) {
      final PlatformException e = obj;
      value = VideoPlayerValue.erroneous(e.message);
      _timer?.cancel();
    }

    _eventSubscription = _eventChannelFor(_textureId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
    return initializingCompleter.future;
  }

  EventChannel _eventChannelFor(int textureId) {
    return EventChannel(
        'sarbagyastha.com.np/youtubePlayer/videoEvents$textureId');
  }

  @override
  Future<void> dispose() async {
    if (_creatingCompleter != null) {
      await _creatingCompleter.future;
      if (!_isDisposed) {
        _isDisposed = true;
        _timer?.cancel();
        await _eventSubscription?.cancel();
        // https://github.com/flutter/flutter/issues/26431
        // ignore: strong_mode_implicit_dynamic_method
        await _channel.invokeMethod(
          'dispose',
          <String, dynamic>{'textureId': _textureId},
        );
      }
      _lifeCycleObserver.dispose();
    }
    _isDisposed = true;
    super.dispose();
  }

  Future<void> play() async {
    value = value.copyWith(isPlaying: true);
    await _applyPlayPause();
  }

  Future<void> setLooping(bool looping) async {
    value = value.copyWith(isLooping: looping);
    await _applyLooping();
  }

  Future<void> pause() async {
    value = value.copyWith(isPlaying: false);
    await _applyPlayPause();
  }

  Future<void> _applyLooping() async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    _channel.invokeMethod(
      'setLooping',
      <String, dynamic>{'textureId': _textureId, 'looping': value.isLooping},
    );
  }

  Future<void> _applyPlayPause() async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    if (value.isPlaying) {
      // https://github.com/flutter/flutter/issues/26431
      // ignore: strong_mode_implicit_dynamic_method
      await _channel.invokeMethod(
        'play',
        <String, dynamic>{'textureId': _textureId},
      );
      _timer = Timer.periodic(
        const Duration(milliseconds: 500),
        (Timer timer) async {
          if (_isDisposed) {
            return;
          }
          final Duration newPosition = await position;
          if (_isDisposed) {
            return;
          }
          value = value.copyWith(position: newPosition);
        },
      );
    } else {
      _timer?.cancel();
      // https://github.com/flutter/flutter/issues/26431
      // ignore: strong_mode_implicit_dynamic_method
      await _channel.invokeMethod(
        'pause',
        <String, dynamic>{'textureId': _textureId},
      );
    }
  }

  Future<void> _applyVolume() async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await _channel.invokeMethod(
      'setVolume',
      <String, dynamic>{'textureId': _textureId, 'volume': value.volume},
    );
  }

  /// The position in the current video.
  Future<Duration> get position async {
    if (_isDisposed) {
      return null;
    }
    return Duration(
      // https://github.com/flutter/flutter/issues/26431
      // ignore: strong_mode_implicit_dynamic_method
      milliseconds: await _channel.invokeMethod(
        'position',
        <String, dynamic>{'textureId': _textureId},
      ),
    );
  }

  Future<void> seekTo(Duration moment) async {
    if (_isDisposed) {
      return;
    }
    if (moment > value.duration) {
      moment = value.duration;
    } else if (moment < const Duration()) {
      moment = const Duration();
    }
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await _channel.invokeMethod('seekTo', <String, dynamic>{
      'textureId': _textureId,
      'location': moment.inMilliseconds,
    });
    value = value.copyWith(position: moment);
  }

  /// Sets the audio volume of [this].
  ///
  /// [volume] indicates a value between 0.0 (silent) and 1.0 (full volume) on a
  /// linear scale.
  Future<void> setVolume(double volume) async {
    value = value.copyWith(volume: volume.clamp(0.0, 1.0));
    await _applyVolume();
  }
}

class _VideoAppLifeCycleObserver extends Object with WidgetsBindingObserver {
  _VideoAppLifeCycleObserver(this._controller);

  bool _wasPlayingBeforePause = false;
  final VideoPlayerController _controller;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _wasPlayingBeforePause = _controller.value.isPlaying;
        _controller.pause();
        break;
      case AppLifecycleState.resumed:
        if (_wasPlayingBeforePause) {
          _controller.play();
        }
        break;
      default:
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}

/// Displays the video controlled by [controller].
class VideoPlayer extends StatefulWidget {
  VideoPlayer(this.controller);

  final VideoPlayerController controller;

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  _VideoPlayerState() {
    _listener = () {
      final int newTextureId = widget.controller.textureId;
      if (newTextureId != _textureId) {
        setState(() {
          _textureId = newTextureId;
        });
      }
    };
  }

  VoidCallback _listener;
  int _textureId;

  @override
  void initState() {
    super.initState();
    _textureId = widget.controller.textureId;
    // Need to listen for initialization events since the actual texture ID
    // becomes available after asynchronous initialization finishes.
    widget.controller.addListener(_listener);
  }

  @override
  void didUpdateWidget(VideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller.removeListener(_listener);
    _textureId = widget.controller.textureId;
    widget.controller.addListener(_listener);
  }

  @override
  void deactivate() {
    super.deactivate();
    widget.controller.removeListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    return _textureId == null ? Container() : Texture(textureId: _textureId);
  }
}

class VideoProgressColors {
  VideoProgressColors({
    this.playedColor = const Color.fromRGBO(255, 0, 0, 0.7),
    this.bufferedColor = const Color.fromRGBO(50, 50, 200, 0.2),
    this.backgroundColor = const Color.fromRGBO(200, 200, 200, 0.5),
  });

  final Color playedColor;
  final Color bufferedColor;
  final Color backgroundColor;
}

class _VideoScrubber extends StatefulWidget {
  _VideoScrubber({
    @required this.child,
    @required this.controller,
  });

  final Widget child;
  final VideoPlayerController controller;

  @override
  _VideoScrubberState createState() => _VideoScrubberState();
}

class _VideoScrubberState extends State<_VideoScrubber> {
  bool _controllerWasPlaying = false;

  VideoPlayerController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final RenderBox box = context.findRenderObject();
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller.value.duration * relative;
      controller.seekTo(position);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: widget.child,
      onHorizontalDragStart: (DragStartDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        _controllerWasPlaying = controller.value.isPlaying;
        if (_controllerWasPlaying) {
          controller.pause();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_controllerWasPlaying) {
          controller.play();
        }
      },
      onTapDown: (TapDownDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
    );
  }
}

/// Displays the play/buffering status of the video controlled by [controller].
///
/// If [allowScrubbing] is true, this widget will detect taps and drags and
/// seek the video accordingly.
///
/// [padding] allows to specify some extra padding around the progress indicator
/// that will also detect the gestures.
class VideoProgressIndicator extends StatefulWidget {
  VideoProgressIndicator(
    this.controller, {
    VideoProgressColors colors,
    this.allowScrubbing,
    this.padding = const EdgeInsets.only(top: 5.0),
  }) : colors = colors ?? VideoProgressColors();

  final VideoPlayerController controller;
  final VideoProgressColors colors;
  final bool allowScrubbing;
  final EdgeInsets padding;

  @override
  _VideoProgressIndicatorState createState() => _VideoProgressIndicatorState();
}

class _VideoProgressIndicatorState extends State<VideoProgressIndicator> {
  _VideoProgressIndicatorState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  VoidCallback listener;

  VideoPlayerController get controller => widget.controller;

  VideoProgressColors get colors => widget.colors;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    Widget progressIndicator;
    if (controller.value.initialized) {
      final int duration = controller.value.duration.inMilliseconds;
      final int position = controller.value.position.inMilliseconds;

      int maxBuffering = 0;
      for (DurationRange range in controller.value.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }

      progressIndicator = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          LinearProgressIndicator(
            value: maxBuffering / duration,
            valueColor: AlwaysStoppedAnimation<Color>(colors.bufferedColor),
            backgroundColor: colors.backgroundColor,
          ),
          LinearProgressIndicator(
            value: position / duration,
            valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
            backgroundColor: Colors.transparent,
          ),
        ],
      );
    } else {
      progressIndicator = LinearProgressIndicator(
        value: null,
        valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
        backgroundColor: colors.backgroundColor,
      );
    }
    final Widget paddedProgressIndicator = Padding(
      padding: widget.padding,
      child: progressIndicator,
    );
    if (widget.allowScrubbing) {
      return _VideoScrubber(
        child: paddedProgressIndicator,
        controller: controller,
      );
    } else {
      return paddedProgressIndicator;
    }
  }
}

typedef YPCallBack(VideoPlayerController controller);
typedef ErrorCallback(String error);

class YoutubePlayer extends StatefulWidget {
  final String source;
  final YoutubeQuality quality;
  final BuildContext context;
  final double aspectRatio;
  final double width;
  final bool autoPlay;
  final bool isLive;
  final ControlsColor controlsColor;
  final bool controlsActiveBackgroundOverlay;
  final Duration controlsTimeOut;
  final Duration startAt;
  final bool showThumbnail;
  final bool keepScreenOn;
  final bool showVideoProgressbar;
  final bool startFullScreen;
  final YPCallBack callbackController;
  final ErrorCallback onError;
  final VoidCallback onVideoEnded;
  final YoutubePlayerMode playerMode;

  YoutubePlayer(
      {@required this.source,
      @required this.context,
      @required this.quality,
      this.aspectRatio = 16 / 9,
      this.width,
      this.isLive = false,
      this.autoPlay = true,
      this.controlsColor,
      this.startAt,
      this.showThumbnail = false,
      this.keepScreenOn = true,
      this.showVideoProgressbar = true,
      this.startFullScreen = false,
      this.controlsActiveBackgroundOverlay = false,
      this.controlsTimeOut = const Duration(seconds: 3),
      this.playerMode = YoutubePlayerMode.DEFAULT,
      this.onError,
      this.onVideoEnded,
      this.callbackController})
      : assert(
            (width ?? MediaQuery.of(context).size.width) <=
                MediaQuery.of(context).size.width,
            "Width must be less than Screen Width.\nScreen width:${MediaQuery.of(context).size.width}\nGiven width:$width");

  @override
  State<StatefulWidget> createState() {
    return _YoutubePlayerState();
  }

  static Future<double> get brightness async =>
      (await _channel.invokeMethod('brightness')) as double;
  static Future setBrightness(double brightness) =>
      _channel.invokeMethod('setBrightness', {"brightness": brightness});
  static Future<bool> get isKeptOn async =>
      (await _channel.invokeMethod('isKeptOn')) as bool;
  static Future keepOn(bool on) => _channel.invokeMethod('keepOn', {"on": on});
}

class _YoutubePlayerState extends State<YoutubePlayer> {
  VideoPlayerController _videoController;
  String videoId = "";
  bool initialize = true;
  double width;
  double height;
  bool _showControls;
  String _selectedQuality;
  bool _showVideoProgressBar = true;
  bool _videoEndListenerCalled;
  ControlsColor controlsColor;

  @override
  void initState() {
    _selectedQuality = qualityMapping(widget.quality);
    _showControls = widget.autoPlay ? false : true;
    if (widget.source.contains("http")) {
      videoId = getIdFromUrl(widget.source);
    } else {
      videoId = widget.source;
    }
    if (videoId != null)
      _videoController = VideoPlayerController.network(
          "${videoId}sarbagya${_selectedQuality}sarbagya${widget.isLive}");
    if (controlsColor == null) {
      controlsColor = ControlsColor();
    } else {
      if (widget.controlsActiveBackgroundOverlay)
        controlsColor = ControlsColor(
          buttonColor: widget.controlsColor.buttonColor,
          controlsBackgroundColor: Colors.transparent,
          playPauseColor: widget.controlsColor.playPauseColor,
          progressBarPlayedColor: widget.controlsColor.progressBarPlayedColor,
          progressBarBackgroundColor:
              widget.controlsColor.progressBarBackgroundColor,
          seekBarPlayedColor: widget.controlsColor.seekBarPlayedColor,
          seekBarUnPlayedColor: widget.controlsColor.seekBarUnPlayedColor,
          timerColor: widget.controlsColor.timerColor,
        );
    }
    super.initState();
  }

  @override
  void dispose() {
    _videoController.setVolume(0.0);
    _videoController.dispose();
    super.dispose();
  }

  void initializeYTController() {
    _videoController.initialize().then((_) {
      _videoEndListenerCalled = false;
      if (widget.autoPlay) _videoController.play();
      if (mounted) {
        setState(() {});
      }
      if (widget.startFullScreen) {
        _pushFullScreenWidget(context);
      }
      if (widget.startAt != null) _videoController.seekTo(widget.startAt);
      _videoController.addListener(() {
        if (_videoController.value.duration != null &&
            _videoController.value.position != null) {
          if (_videoController.value.position.inSeconds ==
                  _videoController.value.duration.inSeconds &&
              !_videoEndListenerCalled) {
            widget.onVideoEnded();
            _videoEndListenerCalled = true;
          }
        }
      });
    });
    if (widget.callbackController != null) {
      widget.callbackController(_videoController);
    }
    print("Youtube Video Id: $videoId");
  }

  @override
  Widget build(BuildContext context) {
    if (widget.keepScreenOn) {
      YoutubePlayer.keepOn(true);
    }
    width = widget.width ?? MediaQuery.of(context).size.width;
    height = 1 / widget.aspectRatio * width;
    if (widget.source.contains("http")) {
      if (getIdFromUrl(widget.source) != videoId) {
        _videoController.pause();
        videoId = getIdFromUrl(widget.source);
        if (videoId != null) {
          _videoController = VideoPlayerController.network(
              "${videoId}sarbagya${_selectedQuality}sarbagya${widget.isLive}");
          initializeYTController();
        } else {
          widget.onError("Malformed Video ID or URL");
        }
      }
    } else {
      if (widget.source != videoId) {
        _videoController.pause();
        videoId = widget.source;
        if (videoId != null) {
          _videoController = VideoPlayerController.network(
              "${videoId}sarbagya${_selectedQuality}sarbagya${widget.isLive}");
          initializeYTController();
        }
      }
    }
    if (initialize && videoId != null) {
      initializeYTController();
      initialize = false;
    }
    return _buildVideo(height, width, false);
  }

  Widget _buildVideo(double _height, double _width, bool _isFullScreen) {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      height: _height,
      width: _width,
      color: Colors.black,
      child: AspectRatio(
        aspectRatio: _videoController.value.aspectRatio,
        child: Stack(
          alignment: Alignment(0, 0),
          children: <Widget>[
            AnimatedContainer(
              duration: Duration(seconds: 1),
              height: _height,
              width: _width,
              decoration: widget.showThumbnail && videoId != null
                  ? BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            "https://i3.ytimg.com/vi/$videoId/sddefault.jpg"),
                        fit: BoxFit.cover,
                      ),
                    )
                  : BoxDecoration(),
            ),
            Center(
              child: _videoController.value.initialized
                  ? AnimatedContainer(
                      duration: Duration(seconds: 1),
                      height: _height,
                      child: AspectRatio(
                        aspectRatio: _videoController.value.aspectRatio,
                        child: VideoPlayer(_videoController),
                      ),
                    )
                  : Container(
                      height: _height,
                      width: _width,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
            ),
            AnimatedContainer(
              duration: Duration(seconds: 1),
              height: _height,
              width: _width,
              child: _videoController.value.initialized &&
                      widget.playerMode == YoutubePlayerMode.DEFAULT
                  ? Controls(
                      height: _height,
                      width: _width,
                      isLive: widget.isLive,
                      controller: _videoController,
                      showControls: _showControls,
                      videoId: videoId,
                      defaultQuality: _selectedQuality,
                      isFullScreen: _isFullScreen,
                      controlsActiveBackgroundOverlay:
                          widget.controlsActiveBackgroundOverlay,
                      controlsColor: controlsColor,
                      controlsTimeOut: widget.controlsTimeOut,
                      controlsShowingCallback: (showing) {
                        if (mounted) {
                          Timer(Duration(milliseconds: 200), () {
                            setState(() {
                              _showVideoProgressBar = !showing;
                            });
                          });
                        }
                      },
                      qualityChangeCallback: (quality, position) {
                        _videoController.pause();
                        if (mounted) {
                          setState(() {
                            _selectedQuality = quality;
                            if (videoId != null)
                              _videoController = VideoPlayerController.network(
                                  "${videoId}sarbagya${_selectedQuality}sarbagya${widget.isLive}");
                          });
                        }
                        _videoController.initialize().then((_) {
                          _videoController.seekTo(position);
                          _videoController.play();
                          if (mounted) {
                            setState(() {});
                          }
                        });
                        if (widget.callbackController != null) {
                          widget.callbackController(_videoController);
                        }
                      },
                      fullScreenCallback: () async {
                        await _pushFullScreenWidget(context);
                      },
                    )
                  : Container(),
            ),
            _videoController.value.initialized &&
                    _showVideoProgressBar &&
                    widget.showVideoProgressbar
                ? Positioned(
                    bottom: -3.5,
                    child: Container(
                      width: _width,
                      child: VideoProgressIndicator(
                        _videoController,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          backgroundColor:
                              controlsColor.progressBarBackgroundColor,
                          playedColor: controlsColor.progressBarPlayedColor,
                        ),
                        padding: EdgeInsets.all(0.0),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  String qualityMapping(YoutubeQuality quality) {
    switch (quality) {
      case YoutubeQuality.LOW:
        return '240p';
      case YoutubeQuality.MEDIUM:
        return '360p';
      case YoutubeQuality.HIGH:
        return '480p';
      case YoutubeQuality.HD:
        return '720p';
      case YoutubeQuality.FHD:
        return '1080p';
      default:
        return "Invalid Quality";
    }
  }

  String getIdFromUrl(String url, [bool trimWhitespaces = true]) {
    if (url == null || url.length == 0) return null;

    if (trimWhitespaces) url = url.trim();

    for (var exp in _regexps) {
      Match match = exp.firstMatch(url);
      if (match != null && match.groupCount >= 1) return match.group(1);
    }

    return null;
  }

  List<RegExp> _regexps = [
    new RegExp(
        r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
    new RegExp(
        r"^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$"),
    new RegExp(r"^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$")
  ];

  Future<dynamic> _pushFullScreenWidget(BuildContext context) async {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final TransitionRoute<Null> route = PageRouteBuilder<Null>(
      settings: RouteSettings(isInitialRoute: false),
      pageBuilder: _fullScreenRoutePageBuilder,
    );

    SystemChrome.setEnabledSystemUIOverlays([]);
    if (isAndroid) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    await Navigator.of(context).push(route);

    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations(
      const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    );
  }

  Widget _fullScreenRoutePageBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        return Scaffold(
          body: _buildVideo(MediaQuery.of(context).size.height,
              MediaQuery.of(context).size.width, true),
        );
      },
    );
  }
}

class ControlsColor {
  final Color timerColor;
  final Color seekBarPlayedColor;
  final Color seekBarUnPlayedColor;
  final Color buttonColor;
  final Color playPauseColor;
  final Color progressBarPlayedColor;
  final Color progressBarBackgroundColor;
  final Color controlsBackgroundColor;

  ControlsColor({
    this.buttonColor = Colors.white,
    this.playPauseColor = Colors.white,
    this.progressBarPlayedColor = Colors.red,
    this.progressBarBackgroundColor = Colors.transparent,
    this.seekBarUnPlayedColor = Colors.grey,
    this.seekBarPlayedColor = Colors.red,
    this.timerColor = Colors.white,
    this.controlsBackgroundColor = Colors.transparent,
  });
}
