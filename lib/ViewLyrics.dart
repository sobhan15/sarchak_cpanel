import 'dart:convert';
import 'dart:io';

import 'package:audiotagger/audiotagger.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sarchak_cpanel/PlayingPage.dart';
import 'BasicData.dart' as BasicData;
import "package:audioplayers_with_rate/audioplayers.dart";

class ViewLyrics extends StatefulWidget {
  final String uri;

  const ViewLyrics({Key key, this.uri}) : super(key: key);
  @override
  _ViewLyricsState createState() => _ViewLyricsState();
}

enum PlayerState { playing, stopped, paused }

class _ViewLyricsState extends State<ViewLyrics> {
  Audiotagger audiotagger;
  String _lyrics;
  List line, word;
  int currentPosition = 0;
  int current = 0;
  double offset = 0;
  ScrollController scrollController;
  AudioPlayer audioPlayer;
  Duration position;
  String currentLine = "";
  Map lyricsMap = <String, String>{};
  Map audioTag;
  PlayerState playerState = PlayerState.playing;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List postionLine = [];
  FlutterUploader uploaderMan;
  int progressUpload;
  bool uploadingWindow = false;
  var taskId;
  AudioPlayer newAuioPlayer;
  double speedPlayBack = 1;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    getTagAsMap();
    initAudioPlayer();
    stop();
    play();
  }

  @override
  void dispose() async {
    print("dispose");
    super.dispose();
    var result = await audioPlayer.stop();
  }

  stop() async {
    var result = await audioPlayer.stop();
    if (result == 1) {
      setState(() {
        playerState = PlayerState.stopped;
      });
    }
  }

  void getTagAsMap() async {
    audiotagger = Audiotagger();
    audioTag = await audiotagger.readTagsAsMap(
        path: widget.uri, checkPermission: true);
    setState(() {
      _lyrics = audioTag["lyrics"];
    });
    line = await _lyrics.split(" ");
    word = _lyrics.split(" ");
    offset = 0;
  }

  play() async {
    var result = await audioPlayer.play(widget.uri);
    if (result == 1) {
      setState(() {
        playerState = PlayerState.playing;
      });
    }
  }

  pause() async {
    var result = await audioPlayer.pause();
    if (result == 1) {
      setState(() {
        playerState = PlayerState.paused;
      });
    }
  }

  resume() async {
    var result = await audioPlayer.resume();
    if (result == 1) {
      setState(() {
        playerState = PlayerState.playing;
      });
    }
  }

  Widget modelLineLyrics(int position, bool currentLine) {
    return ListTile(
      trailing: Text(postionLine[position]),
      title: Text(
        line[position],
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: currentLine ? 16 : 16,
            color: currentLine ? Colors.black : Colors.black),
      ),
    );
  }

  void initAudioPlayer() async {
    audioPlayer = AudioPlayer();
    Map map = <String, String>{};
    audioPlayer.positionHandler = ((Duration p) {
      lyricsMap["${p.toString().split(".").first}"] = "$currentLine";
      setState(() {
        position = p;
      });
    });
  }

  void createFile() async {
    Directory dir = await getExternalStorageDirectory();
    // Directory appDir = Directory("${dir.path}/Android/data/Cpanel_Sarchak");
    //     appDir.create();
    File ff = File(
        "${dir.path}/Android/data/Cpanel_Sarchak/lyrics-${audioTag["title"]}.json");
    // ff.create();
    // ff.writeAsString(json.encode(lyricsMap));

    ff.exists().then((b) {
      if (b) {
        ff.create();
        ff.writeAsString(json.encode(lyricsMap));
      } else {
        Directory appDir = Directory("${dir.path}/Android/data/Cpanel_Sarchak");
        appDir.create();
        ff.create();
        ff.writeAsString(json.encode(lyricsMap));
      }
    });

    print("${dir.path}/ss.txt");
  }

  void readFile() async {
    Directory dir = await getExternalStorageDirectory();
    File ff = File("${dir.path}/lyrics-${audioTag["title"]}.json");
    ff.readAsString().then((v) {
      Map l = json.decode(v);
      print(l["0:00:06"]);
    });
  }

  void fileUploader() async {
    Directory dir = await getExternalStorageDirectory();
    String lyricsdir = "${dir.path}/Android/data/Cpanel_Sarchak";
    String lyricsName = "lyrics-${audioTag["title"]}.json";

    String musicName = widget.uri.split("/").last;
    String musicdir = widget.uri.replaceAll(musicName, "");
    uploaderMan = FlutterUploader();
    String url = "${BasicData.basicUrl}/uploadMusic";
    taskId = uploaderMan.enqueue(
      url: Uri.encodeFull(url),
      method: UploadMethod.POST,
      files: [
        FileItem(filename: lyricsName, savedDir: lyricsdir, fieldname: "lyric"),
        FileItem(filename: musicName, savedDir: musicdir, fieldname: "music")
      ],
      data: {
        "lyricsName": "lyrics-${audioTag["title"]}.json",
        "musicName": musicName
      },
      showNotification: false,
    );

    setState(() {
      uploadingWindow = true;
    });

    uploaderMan.progress.listen((p) {
      setState(() {
        progressUpload = p.progress;
      });

      if (p.progress == 100) {
        setState(() {
          uploadingWindow = false;
          // _scaffoldKey.currentState.showSnackBar(SnackBar(
          //   content: Text("Upload Finish,Good Job",),
          //   duration: Duration(seconds: 1),
          //   backgroundColor: Colors.green,
          // ));
        });
      }
    });
  }

  void initNewAudioPlayer() {
    newAuioPlayer = AudioPlayer();
    newAuioPlayer.stop();
    newAuioPlayer.play(widget.uri);
    newAuioPlayer.setRate(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("View Lyrics"),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              createFile();
              fileUploader();
              //readFile();
            },
            child: Container(
                margin: EdgeInsets.only(right: 20),
                child: Icon(Icons.cloud_upload)),
          )
        ],
      ),
      body: Container(
          padding: EdgeInsets.all(5),
          child: Stack(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.1),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: postionLine == null ? 0 : postionLine.length,
                  itemBuilder: (context, position) {
                    currentPosition = position;
                    return GestureDetector(
                        onTap: () {},
                        child: position % 100 == current
                            ? modelLineLyrics(position, true)
                            : modelLineLyrics(position, false));
                  },
                ),
              ),
              Center(
                child: uploadingWindow
                    ? Container(
                        padding: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.3,
                        color: Colors.purple,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Uploading",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 22),
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Please Wait...",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  )
                                ],
                              ),
                            ),
                            Text(
                              "$progressUpload%",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 22),
                            )
                          ],
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      border: Border(
                          top: BorderSide(width: 1, color: Colors.purple))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Container(
                        child: FlatButton(
                          color: Colors.purple,
                          child: Text(
                            "Next Line",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          onPressed: () {
                            if (current > -1) {
                              if (postionLine.length < line.length) {
                                postionLine
                                    .add(position.toString().split(".").first);
                              }
                              currentLine = line[current];
                            }
                            setState(() {
                              scrollController.animateTo(offset,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.linearToEaseOut);
                              print("this is current : $current");
                              if (current > 1) {
                                offset +=
                                    MediaQuery.of(context).size.height * 0.1;
                              } else {}
                              if (current < line.length - 1) {
                                current++;
                              }
                            });
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          initNewAudioPlayer();
                          //   print(current);
                          // setState(() {
                          //    postionLine[current-1] = "00:00:00";
                          // });
                        },
                        child: Container(
                          child: Text(
                            position == null
                                ? "00:00:00"
                                : position.toString().split(".").first,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              if (speedPlayBack < 10) {
                                setState(() {
                                  speedPlayBack += 1;
                                   audioPlayer.setRate(speedPlayBack / 10);
                                });
                              }
                            },
                            child: Container(
                                width: 20,
                                height: 20,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 20,
                                  color: Colors.blue,
                                )),
                          ),
                          Text("   "),
                          Container(
                            child: Text(
                              "${speedPlayBack / 10}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Text("   "),
                          GestureDetector(
                            onTap: () {
                              if (speedPlayBack > 1) {
                                setState(() {
                                  speedPlayBack -= 1;
                                  audioPlayer.setRate(speedPlayBack / 10);
                                });
                              }
                            },
                            child: Container(
                                width: 20,
                                height: 20,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 20,
                                  color: Colors.blue,
                                )),
                          ),
                        ],
                      ),
                      Container(
                          child: playerState == PlayerState.playing
                              ? GestureDetector(
                                  onTap: () {
                                    pause();
                                  },
                                  child: Icon(
                                    Icons.pause,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    resume();
                                  },
                                  child: Icon(
                                    Icons.play_arrow,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                )),
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
