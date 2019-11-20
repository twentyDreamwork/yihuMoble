import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yhmoble/config/string.dart';
import 'package:yhmoble/pages/goods_page.dart';
import 'package:yhmoble/service/http_service.dart';
import '../model/category_model.dart';

//分类页面
class CategoryPage extends StatefulWidget {
  final int categoryIndex;
  CategoryPage(this.categoryIndex);
  @override
  _CategoryPageState createState() {
    return _CategoryPageState(this.categoryIndex);
  }
}

class _CategoryPageState extends State<CategoryPage> {
  final int categoryIndex;
  _CategoryPageState(this.categoryIndex); //一级分类下标
  List<CategoryData> _datas = List(); //一级分类集合
  List<CategoryDataChilds> articles = List(); //二级分类集合
  int index;
  @override
  void initState() {
    super.initState();
    getHttp();
  }

  void getHttp() async {
    try {
      await getRequest(
              'queryAllClassify', '?page=1&limit=20&sidx=priority&order=desc')
          .then((val) {
        Map userMap = json.decode(val.toString());
        var naviEntity = CategoryModel.fromJson(userMap);

        /// 初始化
        setState(() {
          _datas = naviEntity.data;
          index = categoryIndex;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //商品分类
        title: Text(KString.categoryTitle),
        centerTitle: true,
      ),
      body: Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              color: Color(0xffffffff),
              child: ListView.builder(
                itemCount: _datas.length,
                itemBuilder: (BuildContext context, int position) {
                  return getRow(position);
                },
              ),
            ),
          ),
          Expanded(
              flex: 5,
              child: ListView(
                children: <Widget>[
                  Container(
                    //height: double.infinity,
                    alignment: Alignment.topLeft,
                    padding: const EdgeInsets.all(10),
                    color: Color(0xffF9F9F9),
                    child: getChip(index), //传入一级分类下标
                  ),
                ],
              )),
        ],
      )),
    );
  }

  Widget getRow(int i) {
    Color textColor = Theme.of(context).primaryColor; //字体颜色
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: index == i ? Color(0xffF9F9F9) : Colors.white,
        ),
        child: Text(
          _datas[i].classifyName,
          style: TextStyle(
            color: index == i ? textColor : Color(0xff666666),
            fontWeight: index == i ? FontWeight.w600 : FontWeight.w400,
            fontSize: 16,
          ),
        ),
      ),
      onTap: () {
        setState(() {
          index = i; //记录选中的下标
          textColor = Color(0xff4caf50);
        });
      },
    );
  }

  Widget getChip(int i) {
    //更新对应下标数据
    _updateArticles(i);
    return Wrap(
      spacing: 5.0, //两个widget之间横向的间隔
      direction: Axis.horizontal, //方向
      alignment: WrapAlignment.start, //内容排序方式
      children: List<Widget>.generate(
        articles.length,
        (int index) {
          return Container(
              margin: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      GoodsPage(articles[index].id)));
                        },
                        child: Text(
                          articles[index].classifyName,
                          style:
                              TextStyle(fontSize: 18, color: Color(0xff666666)),
                        ),
                      )
                    ],
                  ),
                  Wrap(
                    spacing: 5.0, //两个widget之间横向的间隔
                    direction: Axis.horizontal, //方向
                    alignment: WrapAlignment.start, //内容排序方式
                    children: List<Widget>.generate(
                        articles[index].childs.length, (int childsIndex) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GoodsPage(
                                      articles[index].childs[childsIndex].id)));
                        },
                        child: Column(
                          children: <Widget>[
                            Container(
                              width: ScreenUtil().setWidth(150),
                              margin: EdgeInsets.all(5.0),
                              child: Column(
                                children: <Widget>[
                                  CachedNetworkImage(
                                    imageUrl: articles[index]
                                        .childs[childsIndex]
                                        .icons,
                                    width: ScreenUtil().setWidth(125),
                                  ),
                                  Text(
                                      articles[index]
                                          .childs[childsIndex]
                                          .classifyName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(26)))
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ));
        },
      ).toList(),
    );
  }

  // 根据一级分类下标更新二级分类集合
  List<CategoryDataChilds> _updateArticles(int i) {
    if (i == null) i = 0;
    setState(() {
      if (_datas.length != 0) articles = _datas[i].childs;
    });
    return articles;
  }
}
