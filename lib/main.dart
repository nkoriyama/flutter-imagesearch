import 'dart:async';
import 'dart:convert';


import 'flickr.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  var ret =  "https://api.flickr.com/services/rest/" +
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
final int _perpage = 100;

Future<List<Photo>> fetchPhotos(http.Client client) async {
  final response = await client.post(
      Uri.parse(getPhotoListUrl(getQuery(), _perpage, 1)),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      });
  return compute(parsePhotos, response.body);
}

List<Photo> parsePhotos(String responseBody) {
  final FlickrPhotoResponse flickrresp =
      FlickrPhotoResponse.fromJson(jsonDecode(responseBody));
  return flickrresp.getPhotoInfoList();
}


Future<List<Photo>> fetchPhotoList(String query) async {
  final response = await http.post(
      Uri.parse(getPhotoListUrl(getQuery(), _perpage, 1)),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      });
  if (response.statusCode == 200) {
    final FlickrPhotoResponse flickrresp =
        FlickrPhotoResponse.fromJson(jsonDecode(response.body));
    //print('stat:'+flickrresp.stat!);
    if(flickrresp.stat == 'ok')
      return flickrresp.getPhotoInfoList();
  }

  throw Exception('Failed to create FlickrPhotoResponse');
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'ImageSearch';

    return const MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<List<Photo>>(
        future: fetchPhotos(http.Client()),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('エラー発生！'),
            );
          } else if (snapshot.hasData) {
            return PhotosList(photos: snapshot.data!);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

class PhotosList extends StatelessWidget {
  const PhotosList({Key? key, required this.photos}) : super(key: key);

  final List<Photo> photos;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return Image.network(photos[index].getThumbnailUrl());
      },
    );
  }
}
