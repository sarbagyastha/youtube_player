import 'package:flutter/material.dart';
import 'package:youtube_player/youtube_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
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
  VideoPlayerController _controller;
  String position = "Get Current Position";
  String status = "Get Player Status";
  String videoDuration = "Get Video Duration";
  String id = "7QUtEmBT_-w";
  bool isMute = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.grid_on),
            onPressed: () {
              if(_controller.value.initialized){
                _controller.pause();
              }
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => VideoList(),
                ),
              );
            } ,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            YoutubePlayer(
              context: context,
              source: id,
              quality: YoutubeQuality.HD,
              aspectRatio: 16 / 9,
              autoPlay: true,
              showThumbnail: false,
              keepScreenOn: true,
              controlsActiveBackgroundOverlay: true,
              playerMode: YoutubePlayerMode.DEFAULT,
              callbackController: (controller) {
                _controller = controller;
              },
              onError: (error) {
                print(error);
              },
              onVideoEnded: () => print("Video Ended"),
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
                      color: Colors.red,
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
                        onPressed: () => _controller.value.isPlaying
                            ? null
                            : _controller.play(),
                      ),
                      IconButton(
                        icon: Icon(Icons.pause),
                        onPressed: () => _controller.pause(),
                      ),
                      IconButton(
                        icon: Icon(isMute ? Icons.volume_off : Icons.volume_up),
                        onPressed: () {
                          _controller.setVolume(isMute ? 1 : 0);
                          setState(
                            () {
                              isMute = !isMute;
                            },
                          );
                        },
                      ),
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
                                double.parse(_volumeController.text) / 10)),
                      ),
                    ),
                  ),
                  OutlineButton(
                    child: Text(position),
                    onPressed: () => _controller.position.then(
                          (currentPosition) {
                            setState(
                              () {
                                position =
                                    currentPosition.inSeconds.toString() +
                                        " th second";
                              },
                            );
                          },
                        ),
                  ),
                  OutlineButton(
                    child: Text(videoDuration),
                    onPressed: () {
                      setState(
                        () {
                          videoDuration =
                              _controller.value.duration.inSeconds.toString() +
                                  " seconds";
                        },
                      );
                    },
                  ),
                  OutlineButton(
                      child: Text(status),
                      onPressed: () {
                        setState(() {
                          _controller.value.isPlaying
                              ? status = "Playing"
                              : status = "Paused";
                        });
                      }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}

class VideoList extends StatefulWidget {
  @override
  _VideoListState createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("VideoGrid"),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.red, Colors.pink]),
        ),
        padding: EdgeInsets.all(40.0),
        child: ListView(
          children: <Widget>[
            YoutubePlayer(
              context: context,
              quality: YoutubeQuality.HD,
              source: "gQDByCdjUXw",
              autoPlay: false,
              width: MediaQuery.of(context).size.width - 80.0,
            ),
            SizedBox(height: 40.0,),
            YoutubePlayer(
              context: context,
              quality: YoutubeQuality.HD,
              source: "4993sBLAzGA",
              isLive: true,
              autoPlay: false,
              width: MediaQuery.of(context).size.width - 80.0,
            ),
            SizedBox(height: 40.0,),
            YoutubePlayer(
              context: context,
              quality: YoutubeQuality.HD,
              source: "wzFPyTMdoNs",
              autoPlay: false,
              width: MediaQuery.of(context).size.width - 80.0,
            ),
            SizedBox(height: 40.0,),
            YoutubePlayer(
              context: context,
              quality: YoutubeQuality.HD,
              source: "NsaDFtX8t44",
              autoPlay: false,
              width: MediaQuery.of(context).size.width - 80.0,
            ),
            SizedBox(height: 40.0,),
            YoutubePlayer(
              context: context,
              quality: YoutubeQuality.HD,
              source: "40kklGefAcs",
              autoPlay: false,
              width: MediaQuery.of(context).size.width - 80.0,
            ),
            SizedBox(height: 40.0,),
            YoutubePlayer(
              context: context,
              quality: YoutubeQuality.HD,
              source: "AwiP3vxYyZE",
              autoPlay: false,
              width: MediaQuery.of(context).size.width - 80.0,
            ),
          ],
        ),
      ),
    );
  }
}

