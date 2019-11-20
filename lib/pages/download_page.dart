import 'package:flutter/material.dart';
import 'package:yhmoble/config/string.dart';
import 'package:yhmoble/pages/download_page/MyDrawer.dart';
import 'package:yhmoble/pages/download_page/TabBarWidget.dart';
import 'package:yhmoble/pages/download_page/game_page.dart';
import 'package:yhmoble/pages/download_page/software_page.dart';

import 'package:flutter/cupertino.dart';

class DownloadPage extends StatefulWidget {
  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //初始化标签
    List<Widget> tabs = [
      _renderTab(new Text("软件")),
      _renderTab(new Text("游戏")),
    ];
    //一个控件，可以监听返回键
    return new WillPopScope(
      child: new TabBarWidget(
        drawer: new MyDrawer(),
        title: new Text(KString.downloadTitle),
        type: TabBarWidget.TOP_TAB,
        tabItems: tabs,
        tabViews: [new SoftwarePage(), new GamePage()],
        backgroundColor: Theme.of(context).primaryColor,
        indicatorColor: Theme.of(context).indicatorColor,
      ),
      onWillPop: () {},
    );
  }

  _renderTab(text) {
    //返回一个标签
    return new Tab(
        child: new Container(
      //设置paddingTop为6
      padding: new EdgeInsets.only(top: 6),
      //一个列控件
      child: new Column(
        //竖直方向居中
        mainAxisAlignment: MainAxisAlignment.center,
        //水平方向居中
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[text],
      ),
    ));
  }
}
