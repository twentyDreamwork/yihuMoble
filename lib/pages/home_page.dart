import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yhmoble/common/data/home.dart';
import 'package:yhmoble/pages/category_page.dart';
import 'package:yhmoble/pages/new/detail.dart';
import 'package:yhmoble/pages/widget/yh_topbar.dart';
import '../config/index.dart';
import '../service/http_service.dart';
import 'dart:convert';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../routers/application.dart';
// import 'package:nautilus/nautilus.dart' as nautilus;

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  //火爆专区分页
  int page = 1;
  //火爆专区数据
  List<Map> hotGoodsList = [];
  //轮播图
  List<Map> swiperDataList = [];
  //分类
  List<Map> navigatorList = [];
  //推荐产品
  List<Map> recommendList = [];
  //仿止刷新处理 保持当前状态
  @override
  bool get wantKeepAlive => true;

  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();

  @override
  void initState() {
    super.initState();
    print('首页刷新了...');
    _getRecommendGoods();
    _getCategory();
    _getHotGoods();
    // DataUtils.setCode();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(244, 245, 245, 1.0),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        // title: Text(KString.homeTitle),
        title: new Container(
          color: Colors.white,
          child: TopBar(
            searchHintTexts: searchHintTexts,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getRequest('queryAllCarousel', "?page=1&limit=5"),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = json.decode(snapshot.data.toString());
            if (data != null) {
              swiperDataList = (data['result']['list'] as List).cast(); //轮播图
            }

            // List<Map> navigatorList =
            //     (data['data']['category'] as List).cast(); //分类
            // List<Map> recommendList =
            //     (data['data']['recommend'] as List).cast(); //商品推荐
            // List<Map> floor1 = (data['data']['floor1'] as List).cast(); //底部商品推荐
            // Map fp1 = data['data']['floor1Pic']; //广告

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
                    // _buildHotSearchWidget(),

                    SwiperDiy(
                      swiperDataList: swiperDataList,
                    ),
                    TopNavigator(
                      navigatorList: navigatorList,
                    ),
                    RecommendUI(
                      recommandList: recommendList,
                    ),
                    // // FloorPic(
                    //   floorPic: fp1,
                    // ),
                    // Floor(floor: floor1),
                    _hotGoods(),
                  ],
                ),
                loadMore: () async {
                  print('开始加载更多');
                  _getHotGoods();
                },
                onRefresh: () async {
                  print("上拉刷新了");
                  hotGoodsList = [];
                  navigatorList = [];
                  recommendList = [];
                  page = 1;
                  _getRecommendGoods();
                  _getCategory();
                  _getHotGoods();
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

  void _getHotGoods() {
    var formPage = "?page=${page}&limit=10";
    getRequest('getHotGoods', formPage).then((val) {
      var data = json.decode(val.toString());
      List<Map> newGoodsList = (data['result']['list'] as List).cast();
      //设置火爆专区数据列表
      setState(() {
        hotGoodsList.addAll(newGoodsList);
        page++;
      });
    });
  }

  void _getRecommendGoods() {
    var formPage = "?page=1&limit=10";
    getRequest('queryrecommendGoods', formPage).then((val) {
      var data = json.decode(val.toString());
      //设置推荐数据列表
      setState(() {
        recommendList = (data['result']['list'] as List).cast();
      });
    });
  }

  void _getCategory() {
    var formPage = "?page=1&limit=20&sidx=priority&order=desc";
    getRequest('queryAllClassify', formPage).then((val) {
      var data = json.decode(val.toString());
      print((data['result'] as List).cast());
      //设置推荐数据列表
      setState(() {
        navigatorList = (data['result'] as List).cast();
      });
    });
  }

  //热门专区标题
  Widget hotTitle = Container(
    margin: EdgeInsets.only(top: 10.0),
    padding: EdgeInsets.all(5.0),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border(
        bottom: BorderSide(width: 0.5, color: KColor.defaultBorderColor),
      ),
    ),
    //热门专区
    child: Text(
      KString.hotGoodsTitle,
      style: TextStyle(color: KColor.homeSubTitleTextColor),
    ),
  );

  //热门专区子项
  Widget _wrapList() {
    if (hotGoodsList.length != 0) {
      List<Widget> listWidget = hotGoodsList.map((val) {
        return InkWell(
          onTap: () {
            // MethodChannel('samples.flutter.io/taobao')
            //     .invokeMethod('openTaobao', {"url": val['goodsUrl']});
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => new Detail(val['goodsUrl'])));

            // Application.router
            //     .navigateTo(context, "/detail?id=${val['goodsId']}");
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
      return Text('');
    }
  }

  //热门专区组合
  Widget _hotGoods() {
    return Container(
      child: Column(
        children: <Widget>[
          hotTitle,
          _wrapList(),
        ],
      ),
    );
  }
}

//首页轮播组件编写
class SwiperDiy extends StatelessWidget {
  final List swiperDataList;

  SwiperDiy({Key key, this.swiperDataList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: ScreenUtil().setHeight(333),
      width: ScreenUtil().setWidth(750),
      child: Swiper(
        viewportFraction: 0.8,
        scale: 0.8,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              // Application.router.navigateTo(
              //     context, "/detail?id=${swiperDataList[index]['goodsId']}");
              // MethodChannel('samples.flutter.io/taobao').invokeMethod(
              //     'openTaobao', {"url": swiperDataList[index]['url']});
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) =>
                          new Detail(swiperDataList[index]['url'])));
            },
            child: CachedNetworkImage(
              imageUrl: "${swiperDataList[index]['goodsImg']}",
              fit: BoxFit.cover,
            ),
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

//首页分类导航组件
class TopNavigator extends StatelessWidget {
  final List navigatorList;

  TopNavigator({Key key, this.navigatorList}) : super(key: key);

  Widget _gridViewItemUI(BuildContext context, item, index) {
    return InkWell(
      onTap: () {
        //跳转到分类页面
        _goCategory(context, index, item['id']);
      },
      child: Column(
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: item['icons'],
            width: ScreenUtil().setWidth(95),
            // fit: BoxFit.cover,
          ),
          Text(item['classifyName'])
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (navigatorList.length > 10) {
      navigatorList.removeRange(10, navigatorList.length);
    }

    var tempIndex = -1;
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 5.0),
      height: ScreenUtil().setHeight(320),
      padding: EdgeInsets.all(3.0),
      child: GridView.count(
        //禁止滚动
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 5,
        padding: EdgeInsets.all(4.0),
        children: navigatorList.map((item) {
          tempIndex++;
          return _gridViewItemUI(context, item, tempIndex);
        }).toList(),
      ),
    );
  }

  //跳转到分类页面
  void _goCategory(context, int index, int categoryId) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CategoryPage(index)),
    );
  }
}

//商品推荐
class RecommendUI extends StatelessWidget {
  final List recommandList;

  RecommendUI({Key key, this.recommandList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          _titleWidget(),
          _recommedList(context),
        ],
      ),
    );
  }

  //推荐商品标题
  Widget _titleWidget() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(10.0, 2.0, 0, 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            bottom: BorderSide(width: 0.5, color: KColor.defaultBorderColor)),
      ),
      child: Text(
        KString.recommendText, //'商品推荐',
        style: TextStyle(color: KColor.homeSubTitleTextColor),
      ),
    );
  }

  //商品推荐列表
  Widget _recommedList(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(280),
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: recommandList.length,
          itemBuilder: (context, index) {
            return _item(index, context);
          }),
    );
  }

  Widget _item(index, context) {
    return InkWell(
      onTap: () {
        // Application.router.navigateTo(
        //     context, "/detail?id=${recommandList[index]['shopId']}");
        // MethodChannel('samples.flutter.io/taobao').invokeMethod(
        //     'openTaobao', {"url": recommandList[index]['taobaoUrl']});

        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) =>
                    new Detail(recommandList[index]['goodsUrl'])));
      },
      child: Container(
        width: ScreenUtil().setWidth(280),
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            left: BorderSide(width: 0.5, color: KColor.defaultBorderColor),
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: CachedNetworkImage(
                imageUrl: recommandList[index]['goodsImg'],
                // width: ScreenUtil().setWidth(95),
                fit: BoxFit.contain,
              ),
            ),
            Row(
              children: <Widget>[
                Text(
                  '￥${recommandList[index]['price']}',
                  style: KFont.presentPriceTextColor,
                ),
                Text('￥${recommandList[index]['originalPrice']}',
                    style: KFont.oriPriceStyle),
              ],
            ),
            Text(
              recommandList[index]['goodsName'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: ScreenUtil().setSp(26)),
            ),
          ],
        ),
      ),
    );
  }
}

//商品推荐中间广告
class FloorPic extends StatelessWidget {
  final Map floorPic;

  FloorPic({Key key, this.floorPic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: InkWell(
        child: Image.network(
          floorPic['PICTURE_ADDRESS'],
          fit: BoxFit.cover,
        ),
        onTap: () {},
      ),
    );
  }
}

//商品推荐下层
class Floor extends StatelessWidget {
  List<Map> floor;

  Floor({Key key, this.floor}) : super(key: key);

  void jumpDetail(context, String goodId) {
    //跳转到商品详情
    Application.router.navigateTo(context, "/detail?id=${goodId}");
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenUtil.getInstance().width;
    return Container(
      child: Row(
        children: <Widget>[
          //左侧商品
          Expanded(
            child: Column(
              children: <Widget>[
                //��上角大图
                Container(
                  padding: EdgeInsets.only(top: 4),
                  height: ScreenUtil().setHeight(400),
                  child: InkWell(
                    child: Image.network(
                      floor[0]['image'],
                      fit: BoxFit.cover,
                    ),
                    onTap: () {
                      jumpDetail(context, floor[0]['goodsId']);
                    },
                  ),
                ),
                //左下角图
                Container(
                  padding: EdgeInsets.only(top: 1, right: 1),
                  height: ScreenUtil().setHeight(200),
                  child: InkWell(
                    child: Image.network(
                      floor[1]['image'],
                      fit: BoxFit.cover,
                    ),
                    onTap: () {
                      jumpDetail(context, floor[1]['goodsId']);
                    },
                  ),
                ),
              ],
            ),
          ),
          //右侧商品
          Expanded(
            child: Column(
              children: <Widget>[
                //右上图
                Container(
                  padding: EdgeInsets.only(top: 4, left: 1, bottom: 1),
                  height: ScreenUtil().setHeight(200),
                  child: InkWell(
                    child: Image.network(
                      floor[2]['image'],
                      fit: BoxFit.cover,
                    ),
                    onTap: () {
                      jumpDetail(context, floor[2]['goodsId']);
                    },
                  ),
                ),
                //右中图
                Container(
                  padding: EdgeInsets.only(top: 1, left: 1),
                  height: ScreenUtil().setHeight(200),
                  child: InkWell(
                    child: Image.network(
                      floor[3]['image'],
                      fit: BoxFit.cover,
                    ),
                    onTap: () {
                      jumpDetail(context, floor[3]['goodsId']);
                    },
                  ),
                ),
                //右下图
                Container(
                  padding: EdgeInsets.only(top: 1, left: 1),
                  height: ScreenUtil().setHeight(200),
                  child: InkWell(
                    child: Image.network(
                      floor[4]['image'],
                      fit: BoxFit.cover,
                    ),
                    onTap: () {
                      jumpDetail(context, floor[4]['goodsId']);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }
}
