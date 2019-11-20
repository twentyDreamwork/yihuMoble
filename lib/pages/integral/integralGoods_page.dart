import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yhmoble/config/color.dart';
import 'package:yhmoble/config/font.dart';
import 'package:yhmoble/config/string.dart';
import 'package:yhmoble/pages/integral/integralDetails_page.dart';
import 'package:yhmoble/service/http_service.dart';

//分类页面
class IntegralGoodsPage extends StatefulWidget {
  @override
  _IntegralGoodsPageState createState() {
    return _IntegralGoodsPageState();
  }
}

class _IntegralGoodsPageState extends State<IntegralGoodsPage>
    with AutomaticKeepAliveClientMixin {
  //仿止刷新处理 保持当前状态
  @override
  bool get wantKeepAlive => true;

  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();

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
          title: Text(KString.integralGoodsTitle),
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

  Widget _wrapList() {
    if (goodsList.length != 0) {
      List<Widget> listWidget = goodsList.map((val) {
        return InkWell(
          onTap: () {
            print("点击了积分商品");
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => new IntegralDetailsPage(val['id'])));
          },
          child: Container(
            width: ScreenUtil().setWidth(372),
            color: Colors.white,
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.only(bottom: 3.0),
            child: Column(
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: val['itemImg'],
                  width: ScreenUtil().setWidth(375),
                  fit: BoxFit.cover,
                ),
                Row(
                  children: <Widget>[
                    Container(
                      width: ScreenUtil().setWidth(200),
                      margin: EdgeInsets.all(5.0),
                      child:
                          Text('${val['point']}积分', style: KFont.integralStyle),
                    ),
                    Container(
                      width: ScreenUtil().setWidth(100),
                      margin: EdgeInsets.all(5.0),
                      child: Text('库存${val['stockNum']}',
                          style: KFont.inventoryStyle,
                          textAlign: TextAlign.right),
                    ),
                  ],
                ),
                Text(
                  val['itemName'],
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
      return Text('');
    }
  }

  void _getGoods() {
    print(goodsList);
    var formPage = "?page=${page}&limit=10";
    getRequest('integralGoods', formPage).then((val) {
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
