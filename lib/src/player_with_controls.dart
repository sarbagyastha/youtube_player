import 'dart:ui';

import 'chewie_player.dart';
import 'cupertino_controls.dart';
import 'material_controls.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player/youtube_player.dart';

class PlayerWithControls extends StatelessWidget {
  PlayerWithControls({Key key, this.controlsColor, this.controlsBackgroundColor}) : super(key: key);
  final Color controlsBackgroundColor;
  final Color controlsColor;

  @override
  Widget build(BuildContext context) {
    final YoutubePlayerController chewieController = YoutubePlayerController.of(context);

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: AspectRatio(
          aspectRatio:
          chewieController.aspectRatio ?? _calculateAspectRatio(context),
          child: _buildPlayerWithControls(chewieController, context),
        ),
      ),
    );
  }

  Container _buildPlayerWithControls(
      YoutubePlayerController chewieController, BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          chewieController.placeholder ?? Container(),
          Center(
            child: Hero(
              tag: chewieController.videoPlayerController,
              child: AspectRatio(
                aspectRatio: chewieController.aspectRatio ??
                    _calculateAspectRatio(context),
                child: VideoPlayer(chewieController.videoPlayerController),
              ),
            ),
          ),
          _buildControls(context, chewieController),
        ],
      ),
    );
  }

  Widget _buildControls(
      BuildContext context,
      YoutubePlayerController chewieController,
      ) {
    return chewieController.showControls
        ? chewieController.customControls != null
        ? chewieController.customControls
        : Theme.of(context).platform == TargetPlatform.android
        ? MaterialControls(controlsColor: controlsColor,controlsBackgroundColor: controlsBackgroundColor,)
        : CupertinoControls(
      backgroundColor: Color.fromRGBO(41, 41, 41, 0.7),
      iconColor: Color.fromARGB(255, 200, 200, 200),
    )
        : Container();
  }

  double _calculateAspectRatio(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return width > height ? width / height : height / width;
  }
}