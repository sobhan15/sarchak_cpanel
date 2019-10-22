import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flute_music_player/flute_music_player.dart';
import 'package:sarchak_cpanel/PlayingPage.dart';
import 'package:sarchak_cpanel/ViewLyrics.dart';

class MusicList extends StatefulWidget {
  @override
  _MusicListState createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  MusicFinder audioPlayer;
  var _songs;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  void initAudioPlayer() async {
    audioPlayer = MusicFinder();
    var songs = await MusicFinder.allSongs();
    songs = List.from(songs);
    setState(() {
      _songs = songs;
      loading = false;
    });
  }

  stop() async {
    var result = await audioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Music List"),
      ),
      body: Center(
        child: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: _songs.length,
                itemBuilder: (context, position) {
                  return GestureDetector(
                    onTap: () {
                      stop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewLyrics(
                                 
                                    uri: _songs[position].uri,
                                  )));
                    },
                    child: ListTile(
                      title: Text(_songs[position].title),
                      subtitle: Text(_songs[position].artist),
                      leading: _songs[position].albumArt == null
                          ? Container(
                            width: 60,
                            height: 60,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                            color: Colors.blue,

                              borderRadius: BorderRadius.all(Radius.circular(20))
                            ),
                            child: Text(_songs[position].title[0],style: TextStyle(fontSize: 20,color: Colors.white),),
                          )
                          : Container(
                            width: 60,
                            height: 60,
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              child: Image.asset(
                                _songs[position].albumArt,
                                fit:BoxFit.cover,
                              ),
                            ),
                          )
                    ),
                  );
                },
              ),
      ),
    );
  }
}
