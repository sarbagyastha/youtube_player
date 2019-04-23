import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player/youtube_player.dart';

class FakeController extends ValueNotifier<VideoPlayerValue>
    implements VideoPlayerController {
  FakeController() : super(VideoPlayerValue(duration: Duration(seconds: 2)));

  @override
  Future<void> dispose() async {
    super.dispose();
  }

  @override
  int textureId;

  @override
  String get dataSource => '';
  @override
  DataSourceType get dataSourceType => DataSourceType.file;
  @override
  String get package => null;
  @override
  Future<Duration> get position async => value.position;

  @override
  Future<void> seekTo(Duration moment) async {}
  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> initialize() async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> play() async {}
  @override
  Future<void> setLooping(bool looping) async {}
}

void main() {
  testWidgets('update texture', (WidgetTester tester) async {
    final FakeController controller = FakeController();
    await tester.pumpWidget(VideoPlayer(controller));
    expect(find.byType(Texture), findsNothing);

    controller.textureId = 123;
    controller.value = controller.value.copyWith(
      duration: const Duration(milliseconds: 100),
    );

    await tester.pump();
    expect(find.byType(Texture), findsOneWidget);
  });

  testWidgets('update controller', (WidgetTester tester) async {
    final FakeController controller1 = FakeController();
    controller1.textureId = 101;
    await tester.pumpWidget(VideoPlayer(controller1));
    expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Texture && widget.textureId == 101,
        ),
        findsOneWidget);

    final FakeController controller2 = FakeController();
    controller2.textureId = 102;
    await tester.pumpWidget(VideoPlayer(controller2));
    expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Texture && widget.textureId == 102,
        ),
        findsOneWidget);
  });

  testWidgets('checking player', (WidgetTester tester) async {
    final testKey = Key('sarbagya');
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(),
        child: YoutubePlayerTest(key: testKey),
      ),
    );
    expect(find.byKey(testKey), findsOneWidget);
  });
}

class YoutubePlayerTest extends StatefulWidget {
  const YoutubePlayerTest({Key key}) : super(key: key);
  @override
  _YoutubePlayerTestState createState() => _YoutubePlayerTestState();
}

class _YoutubePlayerTestState extends State<YoutubePlayerTest> {
  TextEditingController _idController = TextEditingController();
  TextEditingController _seekToController = TextEditingController();
  TextEditingController _volumeController = TextEditingController();
  VideoPlayerController _videoController;
  String position = "Get Current Position";
  String status = "Get Player Status";
  String videoDuration = "Get Video Duration";
  String id = "7QUtEmBT_-w";
  bool isMute = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Youtube Player Test"),
          centerTitle: true,
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
                startFullScreen: false,
                keepScreenOn: true,
                controlsActiveBackgroundOverlay: true,
                controlsTimeOut: Duration(seconds: 4),
                playerMode: YoutubePlayerMode.DEFAULT,
                isLive: false,
                controlsColor: ControlsColor(
                  timerColor: Colors.red,
                  seekBarUnPlayedColor: Colors.red,
                  seekBarPlayedColor: Colors.red,
                  playPauseColor: Colors.red,
                  controlsBackgroundColor: Colors.red,
                  buttonColor: Colors.red,
                  progressBarBackgroundColor: Colors.red,
                  progressBarPlayedColor: Colors.red,
                ),
                showThumbnail: false,
                startAt: Duration(seconds: 1),
                showVideoProgressbar: true,
                callbackController: (controller) {
                  _videoController = controller;
                },
                onError: (error) {
                  print(error);
                },
                onVideoEnded: () => _showThankYouDialog(),
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
                          onPressed: () => _videoController.value.isPlaying
                              ? null
                              : _videoController.play(),
                        ),
                        IconButton(
                          icon: Icon(Icons.pause),
                          onPressed: () => _videoController.pause(),
                        ),
                        IconButton(
                          icon:
                              Icon(isMute ? Icons.volume_off : Icons.volume_up),
                          onPressed: () {
                            _videoController.setVolume(isMute ? 1 : 0);
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
                              onPressed: () => _videoController.seekTo(Duration(
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
                              onPressed: () => _videoController.setVolume(
                                  double.parse(_volumeController.text) / 10)),
                        ),
                      ),
                    ),
                    OutlineButton(
                      child: Text(position),
                      onPressed: () => _videoController.position.then(
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
                            videoDuration = _videoController
                                    .value.duration.inSeconds
                                    .toString() +
                                " seconds";
                          },
                        );
                      },
                    ),
                    OutlineButton(
                        child: Text(status),
                        onPressed: () {
                          setState(() {
                            _videoController.value.isPlaying
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
      ),
    );
  }

  void _showThankYouDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Video Ended"),
          content: Text("Thank you for trying the plugin!"),
        );
      },
    );
  }
}
