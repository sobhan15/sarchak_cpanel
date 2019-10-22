import 'package:flute_music_player/flute_music_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sarchak_cpanel/EditTag.dart';
import 'package:sarchak_cpanel/ViewLyrics.dart';

class PlayingPage extends StatefulWidget {
  final String albumArt;
  final String title;
  final String artist;
  final String musicPath;

  const PlayingPage(
      {Key key, this.albumArt, this.title, this.artist, this.musicPath})
      : super(key: key);
  @override
  _PlayingPageState createState() => _PlayingPageState();
}

enum PlayerState { playing, paused, stopped }

class _PlayingPageState extends State<PlayingPage> {
  PlayerState playerState = PlayerState.paused;
  MusicFinder audioPlayer;

  Duration duration;
  Duration position;

  get durationText =>
      duration != null ? duration.toString().split(".").first : '00:00';

  get positionText =>
      position != null ? position.toString().split('.').first : '00:00';
  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;
  get isStopped => playerState == PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  void initAudioPlayer() {
    audioPlayer = MusicFinder();

    audioPlayer.setDurationHandler((Duration d) {
      setState(() {
        duration = d;
      });
    });

    audioPlayer.setPositionHandler((Duration p) {
      setState(() {
        position = p;
      });
    });

    audioPlayer.setCompletionHandler(() {
      onComplete();
      stop();
      setState(() {
        position = duration;
      });
    });

    play();
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  play() async {
    var result = await audioPlayer.play(widget.musicPath);

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

  stop() async {
    var result = await audioPlayer.stop();
    if (result == 1) {
      setState(() {
        playerState = PlayerState.stopped;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Playing Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.3,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: Image.asset(
                  widget.albumArt == null
                      ? "images/music.jpg"
                      : widget.albumArt,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  child: Text(
                    widget.title,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Container(
                  child: Text(
                    widget.artist,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
            Container(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(positionText),
                Slider(
                  onChanged: (v) {
                    audioPlayer.seek((v / 1000).roundToDouble());
                  },
                  value: position?.inMilliseconds?.toDouble() ?? 0,
                  min: 0,
                  max: duration?.inMilliseconds?.toDouble() ?? 0,
                ),
                Text(durationText)
              ],
            )),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Icon(Icons.cloud_upload),
                  GestureDetector(
                    onTap: () {
                      if (playerState == PlayerState.playing) {
                        pause();
                      } else if (playerState == PlayerState.paused) {
                        play();
                      }
                    },
                    child: Icon(
                      playerState == PlayerState.playing
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 50,
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                        play();

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ViewLyrics(uri: widget.musicPath)));
                      },
                      child: Icon(Icons.edit)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
