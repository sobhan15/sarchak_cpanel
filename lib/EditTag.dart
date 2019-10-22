import 'dart:typed_data';

import 'package:audiotagger/audiotagger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EditTag extends StatefulWidget {
  final String uri;

  const EditTag({Key key, this.uri}) : super(key: key);
  @override
  _EditTagState createState() => _EditTagState();
}

class _EditTagState extends State<EditTag> {
  TextEditingController titleController;
  TextEditingController artistController;
  TextEditingController genreController;
  TextEditingController trackNumController;
  TextEditingController trackCountController;
  TextEditingController discNumController;
  TextEditingController discTotalController;
  TextEditingController lyricController;
  TextEditingController commentController;
  TextEditingController albumNameController;
  TextEditingController albumArtistController;
  TextEditingController yearController;

  FocusNode titleFocus;
  FocusNode artistFocus;
  FocusNode genreFocus;
  FocusNode trackNumFocus;
  FocusNode trackCountFocus;
  FocusNode discNumFocus;
  FocusNode discTotalFocus;
  FocusNode lyricFocus;
  FocusNode commentFocus;
  FocusNode albumNameFocus;
  FocusNode albumArtistFocus;
  FocusNode yearFocus;

  Audiotagger audioTagger;
  Uint8List _image;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController();
    artistController = TextEditingController();
    genreController = TextEditingController();
    trackNumController = TextEditingController();
    trackCountController = TextEditingController();
    discNumController = TextEditingController();
    discTotalController = TextEditingController();
    lyricController = TextEditingController();
    commentController = TextEditingController();
    albumNameController = TextEditingController();
    albumArtistController = TextEditingController();
    yearController = TextEditingController();

    titleFocus = FocusNode();
    artistFocus = FocusNode();
    genreFocus = FocusNode();
    trackNumFocus = FocusNode();
    trackCountFocus = FocusNode();
    discNumFocus = FocusNode();
    discTotalFocus = FocusNode();
    lyricFocus = FocusNode();
    commentFocus = FocusNode();
    albumNameFocus = FocusNode();
    albumArtistFocus = FocusNode();
    yearFocus = FocusNode();

    getTagAsMap();
  }

  @override
  void dispose() {
    titleController.dispose();
    artistController.dispose();
    genreController.dispose();
    trackNumController.dispose();
    trackCountController.dispose();
    discNumController.dispose();
    discTotalController.dispose();
    lyricController.dispose();
    commentController.dispose();
    albumNameController.dispose();
    albumArtistController.dispose();
    yearController.dispose();

    titleFocus.dispose();
    artistFocus.dispose();
    genreFocus.dispose();
    trackNumFocus.dispose();
    trackCountFocus.dispose();
    discNumFocus.dispose();
    discTotalFocus.dispose();
    lyricFocus.dispose();
    commentFocus.dispose();
    albumNameFocus.dispose();
    albumArtistFocus.dispose();
    yearFocus.dispose();

    super.dispose();
  }

  void getTagAsMap() async {
    audioTagger = Audiotagger();
    Map map = await audioTagger.readTagsAsMap(
        path: widget.uri, checkPermission: true);

    _image =
        await audioTagger.readArtwork(path: widget.uri, checkPermission: true);

    setState(() {
      titleController.text = map["title"];
      artistController.text = map["artist"];
      genreController.text = map["genre"];
      trackNumController.text = map["trackNumber"];
      trackCountController.text = map["trackTotal"];
      discNumController.text = map["discNumber"];
      discTotalController.text = map["discTotal"];
      lyricController.text = map["lyrics"];
      commentController.text = map["comment"];
      albumNameController.text = map["album"];
      albumArtistController.text = map["albumArtist"];
      yearController.text = map["year"];
    });
    print("this is a Map : $map");
  }

  Widget customTextFile(String label, TextEditingController controller,
      FocusNode focusNode, FocusNode requestFocus, bool onPress) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      readOnly: onPress ? true : false,
      onTap: onPress
          ? () {
              print("onPress");
            }
          : null,
      onChanged: (v) {
        setState(() {});
      },
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(requestFocus);
      },
      decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon: controller.text == ""
              ? Text("")
              : GestureDetector(
                  onTap: () {
                    setState(() {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        controller.text = "";
                      });
                    });
                  },
                  child: Icon(Icons.close),
                )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Stack(children: <Widget>[
         NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool inn) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 300,
                floating: false,
                leading: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back)),
                actions: <Widget>[
                  Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Icon(
                        Icons.check,
                        size: 30,
                      )),
                ],
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text("Edit Tag"),
                  background: _image == null
                      ? Image.asset(
                          "images/music.jpg",
                          fit: BoxFit.cover,
                        )
                      : Image.memory(
                          _image,
                          fit: BoxFit.cover,
                        ),
                ),
              )
            ];
          },
          body: Container(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                customTextFile("Title", titleController, titleFocus,
                    artistFocus, false),
                Text(""),
                customTextFile("Artist", artistController, artistFocus,
                    genreFocus, false),
                Text(""),
                customTextFile("Genre", genreController, genreFocus,
                    trackNumFocus, false),
                Text(""),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: customTextFile(
                          "Track Number",
                          trackNumController,
                          trackNumFocus,
                          trackCountFocus,
                          false),
                    ),
                    Text("   "),
                    Flexible(
                      child: customTextFile(
                          "Track Count",
                          trackCountController,
                          trackCountFocus,
                          discNumFocus,
                          false),
                    )
                  ],
                ),
                Text(""),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: customTextFile(
                          "Disc Number",
                          discNumController,
                          discNumFocus,
                          discTotalFocus,
                          false),
                    ),
                    Text("   "),
                    Flexible(
                      child: customTextFile(
                          "Disc Total",
                          discTotalController,
                          discTotalFocus,
                          lyricFocus,
                          false),
                    ),
                  ],
                ),
                Text(""),
                customTextFile("Lyrics", lyricController, lyricFocus,
                    commentFocus, true),
                Text(""),
                customTextFile("Comments", commentController, commentFocus,
                    albumNameFocus, false),
                Text(""),
                customTextFile("Album Name", albumNameController,
                    albumNameFocus, albumArtistFocus, false),
                Text(""),
                customTextFile("Album Artist", albumArtistController,
                    albumArtistFocus, yearFocus, false),
                Text(""),
                customTextFile(
                    "Year", yearController, yearFocus, lyricFocus, false),
              ],
            ),
          )),

      ],)
    );
  }
}


