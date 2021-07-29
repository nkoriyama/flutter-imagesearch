import 'dart:io';
import 'photoinfo.dart';
import 'dart:convert';

class Photo extends PhotoInfo {
  final String? id;
  final String? owner;
  final String? secret;
  final String? server;
  final int? farm;
  final String? title;
  final int? ispublic;
  final int? isfriend;
  final int? isfamily;

  Photo({
    this.id,
    this.owner,
    this.secret,
    this.server,
    this.farm,
    this.title,
    this.ispublic,
    this.isfriend,
    this.isfamily,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    //jprint('Photo:fromJson');
    //print('id');
    //print(json['id'].runtimeType);
    //print('owner');
    //print(json['owner'].runtimeType);
    //print('secret');
    //print(json['osecret'].runtimeType);
    //print('server');
    //print(json['server'].runtimeType);
    //print('farm');
    //print(json['farm'].runtimeType);
    //print('title');
    //print(json['title'].runtimeType);
    //print('ispublic');
    //print(json['ispublic'].runtimeType);
    //print('isfriend');
    //print(json['isfriend'].runtimeType);
    //print('iisfajmily');
    //print(json['isfajmily'].runtimeType);

    return Photo(
      id: json['id'] as String,
      owner: json['owner'] as String,
      secret: json['secret'] as String,
      server: json['server'] as String,
      farm: json['farm'] as int,
      title: json['title'] as String,
      ispublic: json['ispublic'] as int,
      isfriend: json['isfriend'] as int,
      isfamily: json['isfamily'] as int,
    );
  }

  @override
  String getImageUrl() {
    return "http://farm" +
        farm.toString() +
        ".staticflickr.com/" +
        server! +
        "/" +
        id!.toString() +
        "_" +
        secret! +
        "_b.jpg";
  }

  @override
  String getThumbnailUrl() {
    return "http://farm" +
        farm.toString() +
        ".staticflickr.com/" +
        server! +
        "/" +
        id!.toString() +
        "_" +
        secret! +
        "_m.jpg";
  }

  @override
  String getTitle() {
    return title!;
  }

  @override
  String getShareSubject() {
    String shareSubject;
    shareSubject = "[ImageSearchWithVolley] " +
        ((!title!.isNotEmpty && title!.length > 60)
            ? title!.substring(0, 60)
            : title!);
    return shareSubject;
  }

  @override
  String getShareText() {
    String shareText = "Flickr";
    shareText += Platform.pathSeparator + "Title:[" + title! + "]";
    shareText += Platform.pathSeparator + "Image URL:[" + getImageUrl() + "]";
    shareText +=
        Platform.pathSeparator + "Page URL:[" + getPhotoPageUrl() + "]";
    return shareText;
  }

  String getPhotoPageUrl() {
    return "http://www.flickr.com/photos/" + owner! + "/" + id!.toString();
  }
}

List<Photo> getPhotoList(String str) {
  final parsed = jsonDecode(str).cast<Map<String, dynamic>>();

  return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
}

List<Photo> toPhotoList(Map<String, dynamic> json) {
  //print('toPhotoList called');
  List<Photo> photoList = new List<Photo>.empty(growable: true);

  if (json['photo'] is List) {
    //print('json photo is List');
    for (var item in json['photo']) {
      var photo = Photo.fromJson(item);
      photoList.add(photo);
    }
  } else {
    //print('json photo is not List');
  }

  return photoList;
}

void parsePhotoList(Map<String, dynamic> json) {
}

void parsePhotoList2(Map<String, dynamic> json) {
}

class Photos {
  final int? page;
  final int? pages;
  final int? perpage;
  final List<Photo>? photo;
  final int? total;

  Photos({this.page, this.pages, this.perpage, this.photo, this.total});

  factory Photos.fromJson(Map<String, dynamic> json) {
    try {
      //print('Photos:fromJson');
      var ret = Photos(
        page: json['page'] as int,
        pages: json['pages'] as int,
        perpage: json['perpage'] as int,
        photo: toPhotoList(json),
        total: json['total'] as int,
      );
      //print('after Photos:fromJson');
      return ret;
    } catch (e, s) {
      //print('exception');
      print(e);
      print(s);
      //print('exception');

      throw Exception(e);
    }
  }
}

class FlickrPhotoResponse {
  final Photos? photos;
  final String? stat;

  FlickrPhotoResponse({this.photos, this.stat});
  factory FlickrPhotoResponse.fromJson(Map<String, dynamic> json) {
    //print('FlickrPhotoResponse:fromJson');
    //print(json['photos']['page']);
    //print(json['photos']['pages']);
    //print('ほげ');
    //print(json['photos']['photo']);
    //if (json['photos']['photo'] is List) print('photo is List');
    //parsePhotoList(json['photos']);
    //print('page:'+ json['photos']['page']);
    //print('pages:'+ json['photos']['pages']);
    //parsePhotoList(json['photos']);

    return FlickrPhotoResponse(
      photos: Photos.fromJson(json['photos']),
      stat: json['stat'],
    );
  }

  bool isOK() {
    return (stat == "ok");
  }

  List<Photo> getPhotoInfoList() {
    return photos!.photo!;
  }

  int getTotal() {
    return photos!.total!;
  }
}
