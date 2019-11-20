import 'package:flutter/material.dart';
import 'package:yhmoble/pages/new/model/article.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'detail.dart';
import 'package:yhmoble/service/newApi.dart';
import 'dart:async';

class Content extends StatefulWidget {
  final String channelId;

  Content({String channelId}) : this.channelId = channelId;

  @override
  ContentState createState() => new ContentState(this.channelId);
}

class ContentState extends State<Content> {
  final String typeId;

  ContentState(this.typeId);

  bool _isloading = true;
  List<Article> _list = [];
  ScrollController _contraller = new ScrollController();
  int currentPage = 1;
  @override
  void initState() {
    super.initState();
    _contraller.addListener(() {
      var maxScroll = _contraller.position.maxScrollExtent;
      var pixels = _contraller.position.pixels;
      if (maxScroll == pixels) {
        currentPage++;
        _featchData();
      }
    });

    _featchData();
  }

  _featchData() {
    Api.featchTypeDetailList(currentPage, typeId, (List<Article> callback) {
      setState(() {
        _isloading = false;
        _list.addAll(callback);
      });
    }, errorback: (e) {
      print("error:$e");
    });
  }

  @override
  void dispose() {
    super.dispose();
    _contraller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isloading
        ? new Center(
            child: new CircularProgressIndicator(),
          )
        : new RefreshIndicator(
            onRefresh: _refresh,
            child: new ListView.builder(
              itemCount: _list.length,
              itemBuilder: (context, index) {
                return new OneColum(articleData: _list[index]);
              },
              controller: _contraller,
            ));
  }

  Future<Null> _refresh() async {
    currentPage = 1;
    _list = [];
    _featchData();
    return null;
  }
}

class OneColum extends StatelessWidget {
  final Article article;
  OneColum({Article articleData}) : article = articleData;

  @override
  Widget build(BuildContext context) {
    var stack = new Stack(
      children: <Widget>[
        new Wrap(children: <Widget>[
          new Text(
            article.title,
            textAlign: TextAlign.left,
            style: new TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          new GestureDetector(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Container(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: new CachedNetworkImage(
                      imageUrl: article.contentImg,
                      width: MediaQuery.of(context).size.width / 3 - 2,
                      fit: BoxFit.cover,
                    ),
                  ),
                  new Container(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: new CachedNetworkImage(
                      imageUrl: article.contentImg2 == null
                          ? article.contentImg
                          : article.contentImg2,
                      width: MediaQuery.of(context).size.width / 3 - 2,
                      fit: BoxFit.cover,
                    ),
                  ),
                  new Container(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: new CachedNetworkImage(
                      imageUrl: article.contentImg3 == null
                          ? article.contentImg
                          : article.contentImg3,
                      width: MediaQuery.of(context).size.width / 3 - 2,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new Detail(article.url)));
                print("ed");
              }),
        ]),
      ],
    );

    return new Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 10.0),
      child: stack,
    );
  }
}
