import 'package:provide/provide.dart';
import 'package:flutter/material.dart';
import 'package:yhmoble/pages/download_page.dart';
import 'package:yhmoble/pages/new/newPage.dart';
import '../config/index.dart';
import 'home_page.dart';
import 'member_page.dart';
import '../provide/current_index_provide.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IndexPage extends StatelessWidget {
  final List<BottomNavigationBarItem> bottomTabs = [
    BottomNavigationBarItem(
      icon: Icon(Icons.message),
      title: Text(KString.newTitle), //新闻中心
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      title: Text(KString.homeTitle), //购物中心
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.category),
      title: Text(KString.downloadTitle), //下载中心
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      title: Text(KString.memberTitle), //会员中心
    ),
  ];

  final List<Widget> tabBodies = [
    NewPage(),
    HomePage(),
    DownloadPage(),
    MemberPage()
  ];

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);
    return Provide<CurrentIndexProvide>(
      builder: (context, child, val) {
        //取到当前索引状态值
        int currentIndex =
            Provide.value<CurrentIndexProvide>(context).currentIndex;
        return Scaffold(
          backgroundColor: Color.fromRGBO(244, 245, 245, 1.0),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: currentIndex,
            items: bottomTabs,
            onTap: (index) {
              Provide.value<CurrentIndexProvide>(context).changeIndex(index);
            },
          ),
          body: IndexedStack(
            index: currentIndex,
            children: tabBodies,
          ),
        );
      },
    );
  }
}
