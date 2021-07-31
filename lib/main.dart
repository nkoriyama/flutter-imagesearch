import 'dart:async';
import 'dart:convert';

import 'flickr.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:riverpod/riverpod.dart';

String getFlickrApiKey() {
  var ret = "";
  ret = "0d1e42fb4fc4b6bb79acec5b3db4b730";
  return ret;
}

String getEncodedQuery(String query) {
  var ret = "";
  ret = Uri.encodeQueryComponent(query);
  return ret;
}

String getPhotoListUrl(String query, int perPage, int page) {
  var ret = "https://api.flickr.com/services/rest/" +
      "?method=flickr.photos.search" +
      "&api_key=" +
      getFlickrApiKey() +
      "&text=" +
      getEncodedQuery(query) +
      "&tags=" +
      getEncodedQuery(query) +
      "&per_page=" +
      perPage.toString() +
      "&page=" +
      page.toString() +
      "&format=json" +
      "&nojsoncallback=1";
  //print(ret);
  return ret;
}

String getQuery() {
  return "ラーメン";
}

const int _perpage = 100;
int _page = 0;

Future<List<Photo>> preparePhotolist(http.Client client) async {
    var list = await fetchPhotolist(client);
    return list;
}
Future<List<Photo>> fetchPhotolist(http.Client client) async {
  final response = await client.post(
      Uri.parse(getPhotoListUrl(getQuery(), _perpage, _page++)),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      });
  return compute(parsePhotolist, response.body);
}

List<Photo> parsePhotolist(String responseBody) {
  final FlickrPhotoResponse flickrresp =
      FlickrPhotoResponse.fromJson(jsonDecode(responseBody));
  return flickrresp.getPhotoInfoList();
}

void main() => runApp(const ImageSearch());

class ImageSearch extends StatelessWidget {
  const ImageSearch({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    const appTitle = 'ImageSearch';

    return const MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Photo> photolist = List<Photo>.empty(growable: true);

  Future<void> _onRefresh() async {
    setState(() {
    });
  }
  /*
  Future<void> _fetchList() async {
    var list = await fetchPhotolist(http.Client());

    setState(() {
      photolist.addAll(list);
    });
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Photo>>(
        future: fetchPhotolist(http.Client()),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text('エラー発生！'),
                );
              } else if (snapshot.hasData) {
                photolist.addAll(snapshot.data!);
                //return PhotoListView(photolist: photolist);
                return RefreshIndicator(
                    onRefresh: () async {
                      await _onRefresh();
                    },
                    /*
                  onRefresh: () async {
                    debugPrint("Load start:" + photolist.length.toString());
                    await _fetchList();
                    debugPrint("Load finish:" + photolist.length.toString());
                  },
                  */
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                    ),
                    itemCount: photolist.length,
                    itemBuilder: (context, index) {
                      return SmallCard(photo: photolist[index], index: index);
                    },
                  ),
                );
              } else {
                return const Center(
                  child: Text('No data！'),
                );
              }
          }
        },
      ),
    );
  }
}

class _SecondPage extends StatelessWidget {
  final Photo photo;

  const _SecondPage(this.photo);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Material(
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: Stack(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(photo.getImageUrl(), fit: BoxFit.cover),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  //alignment: Alignment.topLeft,
                  child: Text(
                    photo.getTitle(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      backgroundColor: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Tween<RelativeRect> _createTween(BuildContext context) {
  var windowSize = MediaQuery.of(context).size;
  var box = context.findRenderObject() as RenderBox;
  var rect = box.localToGlobal(Offset.zero) & box.size;
  var relativeRect = RelativeRect.fromSize(rect, windowSize);

  return RelativeRectTween(
    begin: relativeRect,
    end: RelativeRect.fill,
  );
}

Route _createRoute(BuildContext parentContext, Photo photo) {
  return PageRouteBuilder<void>(
    pageBuilder: (context, animation, secondaryAnimation) {
      return _SecondPage(photo);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var rectAnimation = _createTween(parentContext)
          .chain(CurveTween(curve: Curves.ease))
          .animate(animation);

      return Stack(
        children: [
          PositionedTransition(rect: rectAnimation, child: child),
        ],
      );
    },
  );
}

class SmallCard extends StatelessWidget {
  const SmallCard({required this.photo, required this.index, Key? key})
      : super(key: key);
  final Photo photo;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Material(
        child: InkWell(
          onTap: () {
            var nav = Navigator.of(context);
            nav.push<void>(_createRoute(context, photo));
          },
          //child: Image.network(photo.getThumbnailUrl(), fit: BoxFit.cover)),
          child: Stack(children: <Widget>[
            Image.network(photo.getThumbnailUrl(), fit: BoxFit.cover),
            Text(index.toString()),
          ]),
        ),
      ),
    );
  }
}

class PhotoListView extends StatelessWidget {
  // const PhotoListView({Key? key}) : super(key: key);
  const PhotoListView({Key? key, required this.photolist}) : super(key: key);
  final List<Photo> photolist;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
      ),
      itemCount: photolist.length,
      itemBuilder: (context, index) {
        //return Image.network(photos[index].getThumbnailUrl());
        return SmallCard(photo: photolist[index], index: index);
      },
    );
  }
}
