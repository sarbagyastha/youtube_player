import 'package:flutter/material.dart';
import 'package:youtube_player/youtube_player.dart';
import 'package:youtube_player/yp_chewie.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: MyHomePage(title: 'Youtube Player Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _idController = TextEditingController();
  TextEditingController _seekToController = TextEditingController();
  TextEditingController _volumeController = TextEditingController();
  YoutubePlayerController _controller;
  String position = "Get Current Position";
  String status = "Get Player Status";
  String videoDuration = "Get Video Duration";
  String id = "nPt8bK2gbaU";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              YoutubePlayer(
                source: id,
                quality: YoutubeQuality.HD,
                callbackController: (controller) {
                  _controller = controller;
                },
              ),
              SizedBox(
                height: 10.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _idController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: "Enter youtube \<video id\> or \<link\>"),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          id = _idController.text;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 16.0,
                        ),
                        color: Colors.pink,
                        child: Text(
                          "PLAY",
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.play_arrow),
                            onPressed: () => _controller.videoPlayerController.value.isPlaying? null : _controller.play()),
                        IconButton(
                            icon: Icon(Icons.pause),
                            onPressed: () => _controller.pause()),
                        IconButton(
                            icon: Icon(Icons.fullscreen),
                            onPressed: () => _controller.enterFullScreen()),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextField(
                      controller: _seekToController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Seek to seconds",
                        suffixIcon: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: OutlineButton(
                              child: Text("Seek"),
                              onPressed: () => _controller.seekTo(Duration(
                                  seconds: int.parse(_seekToController.text)))),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextField(
                      controller: _volumeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Volume Level [0-10]",
                        suffixIcon: Padding(
                          padding: EdgeInsets.all(5.0),
                          child: OutlineButton(
                              child: Text("Adjust"),
                              onPressed: () => _controller.setVolume(
                                  double.parse(_volumeController.text) * 10)),
                        ),
                      ),
                    ),
                    OutlineButton(
                        child: Text(position),
                        onPressed: () => _controller
                                .videoPlayerController.position
                                .then((currentPosition) {
                              setState(() {
                                position =
                                    currentPosition.inSeconds.toString() +
                                        " th second";
                              });
                            })),
                    OutlineButton(
                        child: Text(videoDuration),
                        onPressed: () {
                          setState(() {
                            videoDuration = _controller
                                .videoPlayerController.value.duration.inSeconds
                                .toString() +" seconds";
                          });
                        }),
                    OutlineButton(
                        child: Text(status),
                        onPressed: () {
                          setState(() {
                            _controller.videoPlayerController.value.isPlaying
                                ? status = "Playing"
                                : status = "Paused";
                          });
                        }),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
