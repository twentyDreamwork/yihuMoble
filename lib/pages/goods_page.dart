import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yhmoble/config/color.dart';
import 'package:yhmoble/config/font.dart';
import 'package:yhmoble/config/string.dart';
import 'package:yhmoble/pages/new/detail.dart';
import 'package:yhmoble/service/http_service.dart';

//分类页面
class GoodsPage extends StatefulWidget {
  final int categoryId;

  GoodsPage(this.categoryId);
  @override
  _GoodsPageState createState() {
    return _GoodsPageState(this.categoryId);
  }
}

class _GoodsPageState extends State<GoodsPage>
    with AutomaticKeepAliveClientMixin {
  //仿止刷新处理 保持当前状态
  @override
  bool get wantKeepAlive => true;

  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();

  final int categoryId;
  _GoodsPageState(this.categoryId); //一级分类下标
  //商品数据
  List<Map> goodsList = [];
  int page = 1;
  @override
  void initState() {
    super.initState();
    _getGoods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(244, 245, 245, 1.0),
        appBar: AppBar(
          // title: TextFileWidget(),
          title: Text(KString.goodsTitle),
          centerTitle: true,
        ),
        body: EasyRefresh(
            refreshHeader: ClassicsHeader(
                key: _headerKey,
                refreshText: "下拉加载",
                refreshReadyText: "加载中",
                refreshedText: "加载完成",
                bgColor: Colors.white,
                textColor: KColor.refreshTextColor,
                moreInfoColor: KColor.refreshTextColor,
                showMore: true,
                moreInfo: KString.loading,
                refreshingText: "刷新中"
                //加载中...
                ),
            refreshFooter: ClassicsFooter(
              key: _footerKey,
              bgColor: Colors.white,
              textColor: KColor.refreshTextColor,
              moreInfoColor: KColor.refreshTextColor,
              showMore: true,
              noMoreText: '',
              moreInfo: KString.loading,
              loadText: "上啦加载",
              loadingText: "加载完成",
              loadedText: "loaded",
              loadReadyText: KString.loadReadyText,
            ),
            child: ListView(
              children: <Widget>[
                _hotGoods(),
              ],
            ),
            loadMore: () async {
              print('开始加载更多');
              _getGoods();
            },
            onRefresh: () async {
              print("上拉刷新了");
              page = 1;
              goodsList = [];
              _getGoods();
            }));
  }

  Widget _hotGoods() {
    return Container(
      child: Column(
        children: <Widget>[
          _wrapList(),
        ],
      ),
    );
  }

  //热门专区子项
  Widget _wrapList() {
    if (goodsList.length != 0) {
      List<Widget> listWidget = goodsList.map((val) {
        return InkWell(
          onTap: () {
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => new Detail(val['goodsUrl'])));
          },
          child: Container(
            width: ScreenUtil().setWidth(372),
            color: Colors.white,
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.only(bottom: 3.0),
            child: Column(
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: val['goodsImg'],
                  width: ScreenUtil().setWidth(375),
                  fit: BoxFit.cover,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      '￥${val['price']}',
                      style: KFont.presentPriceTextColor,
                    ),
                    Text('￥${val['originalPrice']}',
                        style: KFont.oriPriceStyle),
                  ],
                ),
                Text(
                  val['goodsName'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: ScreenUtil().setSp(26)),
                ),
              ],
            ),
          ),
        );
      }).toList();

      return Wrap(
        spacing: 2,
        children: listWidget,
      );
    } else {
      return Text('暂无产品');
    }
  }

  void _getGoods() {
    print(goodsList);
    var formPage = "?classifyId=${categoryId}&page=${page}&limit=10";
    getRequest('queryAllClassifyByParentId', formPage).then((val) {
      var data = json.decode(val.toString());
      List<Map> newGoodsList = (data['result']['list'] as List).cast();
      //设置火爆专区数据列表
      setState(() {
        goodsList.addAll(newGoodsList);
        page++;
      });
    });
  }
}

///搜索控件widget
class TextFileWidget extends StatelessWidget {
  Widget buildTextField() {
    //theme设置局部主题
    return TextField(
      cursorColor: Colors.white, //设置光标
      decoration: InputDecoration(
          contentPadding: new EdgeInsets.only(left: 0.0),
          border: InputBorder.none,
          icon: Icon(Icons.search),
          hintText: "请输入",
          hintStyle: new TextStyle(fontSize: 14, color: Colors.white)),
      style: new TextStyle(fontSize: 14, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget editView() {
      return Container(
        //修饰黑色背景与圆角
        decoration: new BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.0), //灰色的一层边框
          color: Colors.grey,
          borderRadius: new BorderRadius.all(new Radius.circular(15.0)),
        ),
        alignment: Alignment.center,
        height: 36,
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
        child: buildTextField(),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: editView(),
          flex: 1,
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 5.0,
          ),
          child: new Text("搜索"),
        )
      ],
    );
  }
}
