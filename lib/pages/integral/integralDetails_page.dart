import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:yhmoble/config/color.dart';
import 'package:yhmoble/config/string.dart';
import 'package:yhmoble/service/http_service.dart';
import 'package:yhmoble/util/DataUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

//积分商品详情
class IntegralDetailsPage extends StatefulWidget {
  final int goodsId;
  IntegralDetailsPage(this.goodsId);
  @override
  _IntegralDetailsPageState createState() {
    return _IntegralDetailsPageState(this.goodsId);
  }
}

class _IntegralDetailsPageState extends State<IntegralDetailsPage> {
  final int goodsId;
  _IntegralDetailsPageState(this.goodsId);
  //轮播图
  List<String> swiperDataList = [];
  //商品详情
  List<String> goodsDetails = [];
  //商品名称
  String itemName = "";
  //商品兑换积分
  String point = "";
  //商品库存
  String stockNum = "";
  //商品属性
  List<Map> spList = [];
  //商品
  List<Map> skuList = [];
  //选中按钮状态
  List<String> groupValue = ['sp1', 'sp2', 'sp3', 'sp4'];
  //详情图片
  List<String> detailsImgList = [];
  //选中商品的ID
  String shopId = "";
  String itemId = "";
  String skuCode = "";

  bool get wantKeepAlive => true;

  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 245, 245, 1.0),
      appBar: AppBar(
        title: Text(KString.integralGoodsDetails),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: Column(
          children: <Widget>[Icon(Icons.shopping_cart), Text("兑换")],
        ),
        onPressed: () async {
          if (shopId == "") {
            showToast("请选择产品规格");
          } else {
            SharedPreferences sp = await SharedPreferences.getInstance();
            String unionId = sp.getString(DataUtils.SP_USER_UNIONID);
            var formPage = "?unionId=" +
                unionId +
                "&itemId=" +
                itemId +
                "&skuCode=" +
                skuCode;
            getRequest('exchangePoint', formPage).then((val) {
              var data = json.decode(val.toString());
              showToast(data['result']);
            });
          }
        },
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder(
        future: getRequest('queryByItemPointId', goodsId.toString()),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = json.decode(snapshot.data.toString());
            if (data != null && spList.length == 0) {
              // goodsDetails = (data['result'] as List).cast();
              itemName = data['result']['itemName'];
              point = data['result']['point'].toString();
              stockNum = data['result']['stockNum'].toString();
              swiperDataList =
                  (data['result']['carouselImg'] as List).cast(); //轮播图
              spList = (data['result']['sp'] as List).cast();
              skuList = (data['result']['sku'] as List).cast();
              detailsImgList = (data['result']['carouselImg'] as List).cast();
            }
            return EasyRefresh(
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
                    SwiperDiy(
                      swiperDataList: swiperDataList,
                    ),
                    _goodsDetails(itemName, point, stockNum),
                    _goodsSku(spList, groupValue),
                    _detailsImg(detailsImgList)
                  ],
                ),
                loadMore: () async {
                  print('开始加载更多');
                },
                onRefresh: () async {
                  print("上拉刷新了");
                });
          } else {
            return Center(
              child: Text('加载中...'),
            );
          }
        },
      ),
    );
  }

//商品名称
  Widget _goodsDetails(goodsName, points, stockNum) {
    return new Container(
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Colors.white),
      child: new Row(
        children: [
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new Container(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: new Text(
                    goodsName,
                    style: new TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                new Text(
                  points + " 积分",
                  style: new TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          new Text('库存 '),
          new Text(stockNum),
        ],
      ),
    );
  }

//商品名称
  Widget _goodsSku(spList, groupValue) {
    return new Container(
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(color: Colors.white),
        child: Wrap(
            spacing: 5.0, //两个widget之间横向的间隔
            direction: Axis.horizontal, //方向
            alignment: WrapAlignment.start, //内容排序方式
            children: List<Widget>.generate(
              spList.length,
              (int index) {
                return Container(
                    margin: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              spList[index]['name'],
                              style: new TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            )
                          ],
                        ),
                        Wrap(
                          spacing: 5.0, //两个widget之间横向的间隔
                          direction: Axis.horizontal, //方向
                          alignment: WrapAlignment.start, //内容排序方式
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: List<Widget>.generate(
                              spList[index]['values'].length,
                              (int childsIndex) {
                            return GestureDetector(
                                onTap: () {
                                  print("2222");
                                },
                                child: Column(children: <Widget>[
                                  Container(
                                    width: ScreenUtil().setWidth(190),
                                    margin: EdgeInsets.all(5.0),
                                    alignment: Alignment.centerLeft,
                                    child: groupValue[index] ==
                                            spList[index]['options']
                                                [childsIndex]
                                        ? OutlineButton(
                                            onPressed: () {
                                              updateGroupValue(
                                                  spList[index]['options']
                                                      [childsIndex],
                                                  index);
                                            },
                                            borderSide: BorderSide(
                                                color: Colors.orange,
                                                width: 2.0,
                                                style: BorderStyle.solid),
                                            child: Text(
                                                spList[index]['options']
                                                    [childsIndex],
                                                style: TextStyle(
                                                    color: Colors.orange)),
                                          )
                                        : OutlineButton(
                                            onPressed: () {
                                              updateGroupValue(
                                                  spList[index]['options']
                                                      [childsIndex],
                                                  index);
                                            },
                                            borderSide: BorderSide(
                                                color: Colors.grey,
                                                width: 2.0,
                                                style: BorderStyle.solid),
                                            child: Text(
                                                spList[index]['options']
                                                    [childsIndex],
                                                style: TextStyle(
                                                    color: Colors.grey)),
                                          ),
                                  )
                                ]));
                          }).toList(),
                        ),
                      ],
                    ));
              },
            ).toList()));
  }

  Widget _detailsImg(detailsImgList) {
    return new Container(
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          children: <Widget>[
            _titleWidget(),
            Wrap(
                direction: Axis.horizontal, //方向
                alignment: WrapAlignment.start, //内容排序方式
                children: List<Widget>.generate(
                  detailsImgList.length,
                  (int index) {
                    return Container(
                        margin: EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                            Image.network(
                              detailsImgList[index],
                              width: ScreenUtil().setWidth(750),
                              fit: BoxFit.cover,
                            ),
                          ],
                        ));
                  },
                ).toList())
          ],
        ));
  }

  //商品详情
  Widget _titleWidget() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.fromLTRB(10.0, 2.0, 0, 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            bottom: BorderSide(width: 0.5, color: KColor.defaultBorderColor)),
      ),
      child: Text(
        KString.integralGoodsDetails,
        style: TextStyle(color: KColor.homeSubTitleTextColor),
      ),
    );
  }

  void updateGroupValue(value, index) {
    setState(() {
      groupValue[index] = value;
      skuList.forEach((parent) {
        if (parent["sp"].length == 1) {
          if (parent["sp"]["sp1"] == groupValue[0]) {
            point = parent["point"];
            shopId = parent["id"].toString();
            itemId = parent["itemId"].toString();
          }
        } else if (parent["sp"].length == 2) {
          if (parent["sp"]["sp1"] == groupValue[0] &&
              parent["sp"]["sp2"] == groupValue[1]) {
            point = parent["point"].toString();
            shopId = parent["id"].toString();
            itemId = parent["itemId"].toString();
            skuCode = parent["skuCode"].toString();
          }
        } else if (parent["sp"].length == 3) {
          if (parent["sp"]["sp1"] == groupValue[0] &&
              parent["sp"]["sp2"] == groupValue[1] &&
              parent["sp"]["sp3"] == groupValue[2]) {
            point = parent["point"].toString();
            shopId = parent["id"].toString();
            itemId = parent["itemId"].toString();
            skuCode = parent["skuCode"].toString();
          }
        } else {
          if (parent["sp"]["sp1"] == groupValue[0] &&
              parent["sp"]["sp2"] == groupValue[1] &&
              parent["sp"]["sp3"] == groupValue[2] &&
              parent["sp"]["sp4"] == groupValue[3]) {
            point = parent["point"].toString();
            shopId = parent["id"].toString();
            itemId = parent["itemId"].toString();
            skuCode = parent["skuCode"].toString();
          }
        }
      });
    });
  }

  // 弹出toast
  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}

//轮播图
class SwiperDiy extends StatelessWidget {
  final List swiperDataList;

  SwiperDiy({Key key, this.swiperDataList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: ScreenUtil().setHeight(750),
      width: ScreenUtil().setWidth(750),
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          return CachedNetworkImage(
            imageUrl: "${swiperDataList[index]}",
            fit: BoxFit.cover,
          );
        },
        //图片数量
        itemCount: swiperDataList.length,
        pagination: SwiperPagination(),
        autoplay: true,
      ),
    );
  }
}
