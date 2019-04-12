import 'package:flutter/material.dart';
import 'package:youtube_player/youtube_player.dart';

class VideoDetail extends StatefulWidget {
  @override
  _VideoDetailState createState() => _VideoDetailState();
}

class _VideoDetailState extends State<VideoDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Detail"),
      ),
      body: YoutubePlayer(
        context: context,
        source: "7QUtEmBT_-w",
        quality: YoutubeQuality.HD,
        aspectRatio: 16 / 9,
      ),
    );
  }
}
