import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yhmoble/common/services/search.dart';
import 'package:yhmoble/common/style/yh_style.dart';
import 'package:yhmoble/config/color.dart';
import 'package:yhmoble/config/font.dart';
import 'package:yhmoble/config/string.dart';
import 'package:yhmoble/model/search.dart';
import 'package:yhmoble/pages/new/detail.dart';
import 'package:yhmoble/pages/widget/yh_searchresult_gridview_widget.dart';
import 'package:yhmoble/pages/widget/yh_searchresult_list_widget.dart';
import 'package:yhmoble/service/http_service.dart';

class GoodsSortCondition {
  String name;
  bool isSelected;

  GoodsSortCondition({this.name, this.isSelected}) {}
}

class SearchResultListPage<T extends ScrollNotification>
    extends StatefulWidget {
  final String keyword;
  final bool isList;
  final bool isShowFilterWidget;
  final VoidCallback onTapfilter;
  final NotificationListenerCallback<T> onNotification;
  final bool isRecommended;

  SearchResultListPage(this.keyword,
      {this.isList = false,
      this.onTapfilter,
      this.isShowFilterWidget = false,
      this.onNotification,
      this.isRecommended = false});

  @override
  State<StatefulWidget> createState() => SearchResultListState();
}

class SearchResultListState extends State<SearchResultListPage>
    with
        AutomaticKeepAliveClientMixin<SearchResultListPage>,
        SingleTickerProviderStateMixin {
  SearchResultListModal listData = SearchResultListModal([]);
  int page = 0;
  bool _isList;
  bool _isShowMask = false;
  String keyword = "";
  bool _isShowDropDownItemWidget = false;
  GlobalKey _keyFilter = GlobalKey();
  GlobalKey _keyDropDownItem = GlobalKey();
  //仿止刷新处理 保持当前状态
  @override
  bool get wantKeepAlive => true;

  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();

  //商品数据
  List<Map> goodsList = [];

  double _dropDownHeight = 0;
  Animation<double> _animation;
  AnimationController _controller;
  List _filterConditions = ['综合', '信用', '价格降序', '价格升序'];
  var _dropDownItem;
  List<GoodsSortCondition> _goodsSortConditions = [];
  GoodsSortCondition _selectGoodsSortCondition;

  SearchResultListState();

  @override
  void initState() {
//    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);

    super.initState();
    setState(() {
      keyword = widget.keyword;
    });
    _getGoods();

    _isList = widget.isList;

    _controller = new AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    _goodsSortConditions.add(GoodsSortCondition(name: '综合', isSelected: true));
    _goodsSortConditions.add(GoodsSortCondition(name: '信用', isSelected: false));
    _goodsSortConditions
        .add(GoodsSortCondition(name: '价格降序', isSelected: false));
    _goodsSortConditions
        .add(GoodsSortCondition(name: '价格升序', isSelected: false));

    _selectGoodsSortCondition = _goodsSortConditions[0];
  }

  _afterLayout(_) {
    _getPositions('_keyFilter', _keyFilter);
    _getSizes('_keyFilter', _keyFilter);

    _getPositions('_keyDropDownItem', _keyDropDownItem);
    _getSizes('_keyDropDownItem', _keyDropDownItem);
  }

  _getPositions(log, GlobalKey globalKey) {
    RenderBox renderBoxRed = globalKey.currentContext.findRenderObject();
    var positionRed = renderBoxRed.localToGlobal(Offset.zero);
    print("POSITION of $log: $positionRed ");
  }

  _getSizes(log, GlobalKey globalKey) {
    RenderBox renderBoxRed = globalKey.currentContext.findRenderObject();
    var sizeRed = renderBoxRed.size;
    print("SIZE of $log: $sizeRed");
  }

  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    _dropDownItem = ListView.separated(
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: _goodsSortConditions.length,
      // item 的个数
      separatorBuilder: (BuildContext context, int index) =>
          Divider(height: 1.0),
      // 添加分割线
      itemBuilder: (BuildContext context, int index) {
        GoodsSortCondition goodsSortCondition = _goodsSortConditions[index];
        return GestureDetector(
          onTap: () {
            for (var value in _goodsSortConditions) {
              value.isSelected = false;
            }
            goodsSortCondition.isSelected = true;
            _selectGoodsSortCondition = goodsSortCondition;

            _hideDropDownItemWidget();
          },
          child: Container(
//            color: Colors.blue,
            height: 40,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Text(
                    goodsSortCondition.name,
                    style: TextStyle(
                      color: goodsSortCondition.isSelected
                          ? Colors.red
                          : Colors.black,
                    ),
                  ),
                ),
                goodsSortCondition.isSelected
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).primaryColor,
                        size: 16,
                      )
                    : SizedBox(),
                SizedBox(
                  width: 16,
                ),
              ],
            ),
          ),
        );
      },
    );

    var hideWidget = Container(
      color: Colors.red,
      key: _keyDropDownItem,
      child: _dropDownItem,
    );

    var resultWidget = _isList
        ? YHSearchResultListWidget(listData,
            getNextPage: () => getSearchList(widget.keyword))
        : YHSearchResultGridViewWidget(listData,
            getNextPage: () => getSearchList(widget.keyword));

    if (widget.isRecommended) {
      return resultWidget;
    }

    return Scaffold(
        backgroundColor: YHColors.mainBackgroundColor,
        body: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              color: Colors.white),
//      color: Colors.red,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  widget.isShowFilterWidget ? _buildFilterWidget() : SizedBox(),
                  Offstage(
                    child: hideWidget,
                    offstage: true,
                  ),
                  Expanded(
                    child: EasyRefresh(
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
                        })

                    // Container(
                    //     color: _isList
                    //         ? Colors.white
                    //         : YHColors.mainBackgroundColor,
                    //     child: NotificationListener<ScrollNotification>(
                    //       onNotification: _onScroll,
                    //       child: resultWidget,
                    //     ))
                    ,
                  ),
                ],
              ),
              _buildDrapDownWidget()
            ],
          ),
        ));
//    );
  }

  Widget _hotGoods() {
    return Container(
      alignment: Alignment.topLeft,
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
    // var formPage = "?classifyId=${categoryId}&page=${page}&limit=10";
    var formPage = "?classifyId=384&page=1&limit=10&goodsName=${keyword}";
    getRequest('queryAllClassifyByParentId', formPage).then((val) {
      var data = json.decode(val.toString());
      List<Map> newGoodsList = (data['result']['list'] as List).cast();
      setState(() {
        goodsList.addAll(newGoodsList);
        page++;
      });
    });
  }

  bool _onScroll(ScrollNotification scroll) {
    if (widget.onNotification != null) {
      widget.onNotification(scroll);
    }
    // 当前滑动距离
    double currentExtent = scroll.metrics.pixels;
    double maxExtent = scroll.metrics.maxScrollExtent;
//    print('SearchResultListState._onScroll $currentExtent $maxExtent');
    return false;
  }

  Widget _buildDrapDownWidget1() {
    RenderBox renderBoxRed;
    double top = 0;
    if (_dropDownHeight != 0) {
      renderBoxRed = _keyFilter.currentContext.findRenderObject();
      top = renderBoxRed.size.height;
    }

//    print('SearchResultListState._buildDrapDownWidget ${renderBoxRed.size}' );
    return AnimatedPositioned(
        curve: Curves.fastLinearToSlowEaseIn,
        duration: const Duration(milliseconds: 300),
        width: MediaQuery.of(context).size.width,
        top: top,
//    top: 50,
        left: 0,
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: _dropDownHeight,
              child: _dropDownItem,
            ),
            _mask()
          ],
        ));
  }

  Widget _buildDrapDownWidget() {
    RenderBox renderBoxRed;
    double top = 0;
    if (_dropDownHeight != 0) {
      renderBoxRed = _keyFilter.currentContext.findRenderObject();
      top = renderBoxRed.size.height;
    }
//    print('SearchResultListState._buildDrapDownWidget ${renderBoxRed.size}' );
    return Positioned(
        width: MediaQuery.of(context).size.width,
        top: top,
//    top: 50,
        left: 0,
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
//                color: Colors.white,
//                height: animation.value,
              height: _animation == null ? 0 : _animation.value,

              child: _dropDownItem,
            ),
            _mask()
          ],
        ));
  }

  Widget _mask() {
    if (_isShowMask) {
      return GestureDetector(
        onTap: () {
          _hideDropDownItemWidget();
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Color.fromRGBO(0, 0, 0, 0.1),
        ),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  void getSearchList(String keyword) async {
    var data = await getSearchResult(keyword, page++);
    SearchResultListModal list = SearchResultListModal.fromJson(data);
    if (mounted) {
      setState(() {
        listData.data.addAll(list.data);
      });
    }
  }

  _showDropDownItemWidget() {
    final RenderBox dropDownItemRenderBox =
        _keyDropDownItem.currentContext.findRenderObject();

//    _dropDownHeight = dropDownItemRenderBox.size.height;
    _dropDownHeight = 160;
    _isShowDropDownItemWidget = !_isShowDropDownItemWidget;
    _isShowMask = !_isShowMask;

    _animation =
        new Tween(begin: 0.0, end: _dropDownHeight).animate(_controller)
          ..addListener(() {
            //这行如果不写，没有动画效果
            setState(() {});
          });

    if (_animation.status == AnimationStatus.completed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  _hideDropDownItemWidget() {
    _isShowDropDownItemWidget = !_isShowDropDownItemWidget;
    _isShowMask = !_isShowMask;
    _controller.reverse();
  }

  Widget _buildFilterWidget() {
    return Column(
      key: _keyFilter,
      children: <Widget>[
        SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(left: 20),
                child: GestureDetector(
                  onTap: () {
                    _showDropDownItemWidget();
                  },
                  child: Row(
                    children: <Widget>[
                      Text(
                        _selectGoodsSortCondition.name,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                      Icon(
                        !_isShowDropDownItemWidget
                            ? Icons.arrow_drop_down
                            : Icons.arrow_drop_up,
                        color: Colors.red,
                      )
                    ],
                  ),
                )),
            GestureDetector(
              child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: Row(
                  children: <Widget>[
                    Text('销量', style: TextStyle(fontSize: 14)),
                    Icon(Icons.import_export, size: 16)
                  ],
                ),
              ),
              onTap: widget.onTapfilter,
            ),
            GestureDetector(
              child: Padding(
                padding: EdgeInsets.only(right: 20),
                child: Row(
                  children: <Widget>[
                    Text('券后价', style: TextStyle(fontSize: 14)),
                    Icon(Icons.import_export, size: 16)
                  ],
                ),
              ),
              onTap: widget.onTapfilter,
            ),
            // GestureDetector(
            //   child: Padding(
            //     padding: EdgeInsets.only(right: 20),
            //     child: Row(
            //       children: <Widget>[
            //         Text('筛选', style: TextStyle(fontSize: 14)),
            //         Icon(Icons.format_color_fill, size: 16)
            //       ],
            //     ),
            //   ),
            //   onTap: widget.onTapfilter,
            // ),
          ],
        ),
        SizedBox(
          height: 8,
        ),
      ],
    );
  }
}
