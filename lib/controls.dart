// Copyright 2019 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a MIT license that can be found
// in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:youtube_player/youtube_player.dart';

typedef YoutubeQualityChangeCallback(String quality, Duration position);
typedef ControlsShowingCallback(bool showing);

class Controls extends StatefulWidget {
  final bool showControls;
  final double width;
  final double height;
  final String videoId;
  final String defaultQuality;
  final bool defaultCall;
  final YoutubeQualityChangeCallback qualityChangeCallback;
  final VideoPlayerController controller;
  final VoidCallback fullScreenCallback;
  final bool isFullScreen;
  final ControlsShowingCallback controlsShowingCallback;
  final ControlsColor controlsColor;
  final bool controlsActiveBackgroundOverlay;
  final Duration controlsTimeOut;
  final bool isLive;
  final bool switchFullScreenOnLongPress;
  final bool hideShareButton;

  Controls({
    this.isLive,
    this.showControls,
    this.controller,
    this.height,
    this.width,
    this.qualityChangeCallback,
    this.videoId,
    this.defaultCall,
    this.defaultQuality,
    this.fullScreenCallback,
    this.controlsShowingCallback,
    this.isFullScreen = false,
    this.controlsColor,
    this.controlsActiveBackgroundOverlay,
    this.controlsTimeOut,
    this.switchFullScreenOnLongPress,
    this.hideShareButton,
  });

  @override
  _ControlsState createState() => _ControlsState();
}

class _ControlsState extends State<Controls> {
  bool _showControls;
  double currentPosition = 0;
  String _currentPositionString = "00:00";
  String _remainingString = "- 00:00";
  String _selectedQuality;
  bool _buffering = false;
  Timer _timer;
  bool _showFast = false;
  bool _showRewind = false;
  int seekCount = 0;

  @override
  void initState() {
    if (widget.defaultQuality == '720p') {
      _selectedQuality = 'HD';
    } else if (widget.defaultQuality == '1080p') {
      _selectedQuality = 'Full HD';
    } else {
      _selectedQuality = widget.defaultQuality.toUpperCase();
    }
    widget.controller.addListener(listener);
    _showControls = widget.showControls;
    widget.controlsShowingCallback(_showControls);
    super.initState();
  }

  listener() {
    if (widget.controller.value != null) {
      if (widget.controller.value.position != null &&
          widget.controller.value.duration != null) {
        if (mounted && widget.controller.value.isPlaying) {
          setState(() {
            currentPosition =
                (widget.controller.value.position.inSeconds ?? 0) /
                    widget.controller.value.duration.inSeconds;
            _buffering = widget.controller.value.isBuffering;
            _currentPositionString =
                formatDuration(widget.controller.value.position);
            _remainingString = "- " +
                formatDuration(widget.controller.value.duration -
                    widget.controller.value.position);
          });
        }
      }
    }
  }

  @override
  void didUpdateWidget(Controls oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller.removeListener(listener);
    widget.controller.addListener(listener);
  }

  @override
  void deactivate() {
    widget.controller.removeListener(listener);
    super.deactivate();
  }

  @override
  void dispose() {
    if (!widget.isFullScreen) {
      widget.controller?.setVolume(0);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFullScreen) YoutubePlayer.keepOn(true);
    return Stack(
      children: <Widget>[
        _showControls
            ? Container(
                color: Color(0x88000000),
                height: widget.height,
                width: widget.width,
              )
            : Container(),
        GestureDetector(
          onLongPress: () {
            if (widget.switchFullScreenOnLongPress)
              widget.isFullScreen
                  ? Navigator.pop(context)
                  : widget.fullScreenCallback();
          },
          onTap: onTapAction,
          child: AnimatedContainer(
            duration: Duration(seconds: 1),
            color: Colors.transparent,
            height: widget.height,
            width: widget.width,
            child: AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: Duration(seconds: 1),
              child: AnimatedContainer(
                width: widget.width,
                height: widget.height,
                duration: Duration(seconds: 1),
                child: Material(
                    color: Colors.transparent,
                    child: Stack(
                      children: <Widget>[
                        _buildTopControls(),
                        Center(
                          child: _playButton(),
                        ),
                        _buildBottomControls(),
                      ],
                    )),
              ),
            ),
          ),
        ),
        _fastForward(widget.height, widget.width),
        _rewind(widget.height, widget.width),
      ],
    );
  }

  Widget _fastForward(double _height, double _width) {
    return Positioned(
      right: 0,
      top: 40,
      child: GestureDetector(
        onTap: onTapAction,
        onDoubleTap: () {
          if (mounted) {
            setState(() {
              _showFast = true;
              seekCount += 10;
            });
            widget.controller.seekTo(
              Duration(
                  seconds: widget.controller.value.position.inSeconds + 10),
            );
            Timer(Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _showFast = false;
                  seekCount = 0;
                });
              }
            });
          }
        },
        child: Container(
          color: Colors.transparent,
          width: _width / 2.5,
          height: _height - 80,
          child: _showFast
              ? Center(
                  child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.fast_forward,
                      size: 40.0,
                      color: Colors.white,
                    ),
                    Text(
                      " ${seekCount.toString()} secs",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ))
              : Container(),
        ),
      ),
    );
  }

  Widget _rewind(double _height, double _width) {
    return Positioned(
      left: 0,
      top: 40,
      child: GestureDetector(
        onTap: onTapAction,
        onDoubleTap: () {
          if (mounted) {
            setState(() {
              _showRewind = true;
              seekCount += 10;
            });
            widget.controller.seekTo(
              Duration(
                  seconds: widget.controller.value.position.inSeconds - 10),
            );
            Timer(Duration(seconds: 2), () {
              if (mounted) {
                setState(() {
                  _showRewind = false;
                  seekCount = 0;
                });
              }
            });
          }
        },
        child: Container(
          width: _width / 2.5,
          height: _height - 80,
          color: Colors.transparent,
          child: _showRewind
              ? Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        " ${seekCount.toString()} secs",
                        style: TextStyle(color: Colors.white),
                      ),
                      Icon(
                        Icons.fast_rewind,
                        size: 40.0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                )
              : Container(),
        ),
      ),
    );
  }

  void onTapAction() {
    if (_timer != null) _timer.cancel();
    if (mounted) {
      setState(() {
        _showControls = !_showControls;
        widget.controlsShowingCallback(_showControls);
      });
    }
    if (_showControls) {
      _timer = Timer(widget.controlsTimeOut, () {
        if (mounted) {
          setState(() {
            _showControls = false;
            widget.controlsShowingCallback(_showControls);
          });
        }
      });
    }
    if (!widget.controller.value.isPlaying) widget.controller.play();
  }

  Widget _playButton() {
    return IgnorePointer(
      ignoring: !_showControls,
      child: Material(
        borderRadius: BorderRadius.circular(100.0),
        color: widget.controlsColor.controlsBackgroundColor,
        child: InkWell(
          splashColor: Colors.grey[350],
          borderRadius: BorderRadius.circular(100.0),
          onTap: () {
            if (mounted) {
              setState(() {
                _showControls = false;
                widget.controlsShowingCallback(_showControls);
              });
            }
            if (!_buffering) {
              togglePlaying();
            }
          },
          child: _buffering
              ? CircularProgressIndicator()
              : Icon(
                  widget.controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: widget.controlsColor.playPauseColor,
                  size: widget.width * 0.15,
                ),
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 0,
      right: 0,
      child: Row(
        children: <Widget>[
          widget.isLive
              ? Icon(
                  Icons.wifi_tethering,
                  color: widget.controlsColor.seekBarPlayedColor,
                )
              : InkWell(
                  onTap: () {
                    if (widget.isFullScreen) {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Quality cannot be changed in fullscreen mode."),
                          action: SnackBarAction(
                            label: "Exit FullScreen Mode",
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      );
                    } else {
                      _resolutionBottomSheet();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _selectedQuality,
                      style: TextStyle(
                        color: widget.controlsColor.buttonColor,
                        fontWeight: FontWeight.w900,
                        fontSize: widget.isFullScreen ? 22 : 16,
                      ),
                    ),
                  ),
                ),
          widget.hideShareButton
              ? Container()
              : IconButton(
                  icon: Icon(
                    Icons.share,
                    color: widget.controlsColor.buttonColor,
                  ),
                  onPressed: shareVideo,
                ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    int totalLength = widget.controller.value.duration.inSeconds ?? 0;
    return Positioned(
      bottom: 0.0,
      child: Container(
        color: widget.controlsColor.controlsBackgroundColor,
        width: widget.width,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            widget.isLive
                ? Container()
                : Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      _currentPositionString,
                      style: TextStyle(
                          color: widget.controlsColor.timerColor,
                          fontSize: 12.0),
                    ),
                  ),
            Expanded(
              child: Container(
                height: 20,
                child: Slider(
                  activeColor: widget.controlsColor.seekBarPlayedColor,
                  inactiveColor: widget.controlsColor.seekBarUnPlayedColor,
                  value: currentPosition,
                  onChanged: (position) {
                    if (mounted) {
                      setState(() {
                        currentPosition = position;
                      });
                    }
                    widget.controller.seekTo(
                      Duration(
                        seconds: (position * totalLength).floor(),
                      ),
                    );
                    widget.controller.play();
                  },
                ),
              ),
            ),
            widget.isLive
                ? Container()
                : Text(
                    _remainingString,
                    style: TextStyle(
                      color: widget.controlsColor.timerColor,
                      fontSize: 12.0,
                    ),
                  ),
            widget.isLive
                ? Text(
                    "LIVE",
                    style: TextStyle(
                      color: widget.controlsColor.timerColor,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Container(),
            Padding(
              padding: EdgeInsets.all(widget.width <= 200 ? 4.0 : 10.0),
              child: InkWell(
                splashColor: Colors.grey[350],
                onTap: () {
                  widget.isFullScreen
                      ? Navigator.pop(context)
                      : widget.fullScreenCallback();
                },
                child: Icon(
                  widget.isFullScreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                  color: widget.controlsColor.buttonColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void togglePlaying() {
    if (widget.controller.value.isPlaying == true) {
      widget.controller.pause();
      if (mounted) {
        setState(() {
          _showControls = true;
          widget.controlsShowingCallback(_showControls);
        });
      }
    } else {
      widget.controller.play();
    }
  }

  void shareVideo() {
    final RenderBox box = context.findRenderObject();
    Share.share("https://youtu.be/${widget.videoId}",
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  void _resolutionBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _qualityRow('1080p'),
              _qualityRow('720p'),
              _qualityRow('480p'),
              _qualityRow('360p'),
              _qualityRow('240p'),
              _qualityRow('144p'),
            ],
          ),
        );
      },
    );
  }

  Widget _qualityRow(String quality) {
    String currentQuality;
    if (quality == '1080p') {
      currentQuality = 'Full HD';
    } else if (quality == '720p') {
      currentQuality = 'HD';
    } else {
      currentQuality = quality.toUpperCase();
    }
    return InkWell(
      onTap: () {
        widget.qualityChangeCallback(
          quality.toLowerCase(),
          widget.controller.value.position,
        );
        Navigator.pop(context);
      },
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: currentQuality == _selectedQuality
                ? Icon(
                    Icons.check,
                  )
                : Container(
                    height: 30,
                    width: 30,
                  ),
          ),
          Text(
            quality,
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  String formatDuration(Duration position) {
    final ms = position.inMilliseconds;
    int seconds = ms ~/ 1000;
    final int hours = seconds ~/ 3600;
    seconds = seconds % 3600;
    var minutes = seconds ~/ 60;
    seconds = seconds % 60;
    final hoursString = hours >= 10 ? '$hours' : hours == 0 ? '00' : '0$hours';
    final minutesString =
        minutes >= 10 ? '$minutes' : minutes == 0 ? '00' : '0$minutes';
    final secondsString =
        seconds >= 10 ? '$seconds' : seconds == 0 ? '00' : '0$seconds';
    final formattedTime =
        '${hoursString == '00' ? '' : hoursString + ':'}$minutesString:$secondsString';
    return formattedTime;
  }
}
