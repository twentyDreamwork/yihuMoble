import 'package:flutter/material.dart';
import 'content.dart';

class NewPage extends StatefulWidget {
  const NewPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new NewState();
  }
}

class NewState extends State<NewPage> {
  bool _isloading = true;
  var tabImages;
  var nameList = ["头条", "社会", "国内", "国际", "娱乐", "体育", "军事", "科技", "财经", "时尚"];
  var idList = [
    "top",
    "shehui",
    "guonei",
    "guoji",
    "yule",
    "tiyu",
    "junshi",
    "keji",
    "caijing",
    "shishang"
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: nameList.length,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text("新闻"),
          centerTitle: true,
          brightness: Brightness.light,
          iconTheme: IconThemeData(color: Colors.white),
          bottom: new TabBar(
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white,
              tabs: nameList.map((f) => new Tab(text: f)).toList()),
        ),
        body: new TabBarView(
          children: idList.map((f) => new Content(channelId: f)).toList(),
        ),
      ),
    );
  }

  bool get wantKeepAlive => true;
}
