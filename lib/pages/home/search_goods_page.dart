import 'package:flutter/material.dart';
import 'package:yhmoble/common/services/search.dart';
import 'package:yhmoble/common/style/yh_style.dart';
import 'package:yhmoble/common/utils/navigator_utils.dart';
import 'package:yhmoble/pages/home/search_suggest_page.dart';
import 'package:yhmoble/pages/widget/recomend.dart';
import 'package:yhmoble/pages/widget/yh_search_card.dart';
import 'package:yhmoble/pages/home/search_suggest_page.dart';

class SearchGoodsPage extends StatefulWidget {
  final String keywords;

  const SearchGoodsPage({Key key, this.keywords}) : super(key: key);

  @override
  _SearchGoodsPageState createState() => _SearchGoodsPageState();
}

class _SearchGoodsPageState extends State<SearchGoodsPage> {
  List _tabsTitle = ['全部', '天猫', '店铺'];
  List<String> recomendWords = [];
  TextEditingController _keywordsTextEditingController =
      TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _keywordsTextEditingController.text = widget.keywords;

    if (widget.keywords != null) {
      seachTxtChanged(widget.keywords);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YHColors.mainBackgroundColor,
      appBar: PreferredSize(
          child: AppBar(
//              bottomOpacity: 0,
//              toolbarOpacity: 0,
            brightness: Brightness.light,
            backgroundColor: YHColors.mainBackgroundColor,
            elevation: 0,
//              forceElevated: false, //是否显示阴影
          ),
          preferredSize: Size.fromHeight(0)),
      body: DefaultTabController(
          length: 3,
          initialIndex: 0,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    flex: 1,
                    child: YHSearchCardWidget(
                      elevation: 0,
//                      autofocus: widget.keywords!=null,
                      autofocus: true,
                      textEditingController: _keywordsTextEditingController,
                      isShowLeading: false,
                      onSubmitted: (value) {
                        NavigatorUtils.gotoSearchGoodsResultPage(
                            context, value);
                      },
                      onChanged: (value) {
                        seachTxtChanged(value);
                      },
//                  textEditingController: _keywordTextEditingController,
//                  focusNode: _focus,
                    ),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  GestureDetector(
                    child: Text(
                      '取消',
                      style: TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(
                    width: 8,
                  ),
                ],
              ),
              Expanded(
                  child: (recomendWords.length == 0
                      ? SearchSuggestPage()
                      : RecomendListWidget(recomendWords, onItemTap: (value) {
                          NavigatorUtils.gotoSearchGoodsResultPage(
                              context, value);
                        })))
            ],
          )),
    );
  }

  Widget _buildContentWidget() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 8,
        ),
        TabBar(
//          controller: widget.tabController,
            indicatorColor: Color(0xFFfe5100),
            indicatorSize: TabBarIndicatorSize.label,
            isScrollable: true,
//          labelColor: KColorConstant.themeColor,
            labelColor: Color(0xFFfe5100),
            unselectedLabelColor: Colors.black,
//          labelPadding: EdgeInsets.only(left: (ScreenUtil.screenWidth-30*3)/4),
            labelPadding: EdgeInsets.only(left: 40, right: 40),
            labelStyle: TextStyle(fontSize: 12),
            onTap: (i) {
//            _selectedIndex = i;
//
//            setState(() {});
            },
            tabs: _tabsTitle
                .map((i) => Text(
                      i,
                      style: TextStyle(fontSize: 15),
                    ))
                .toList()),
        SizedBox(
          height: 8,
        ),
        Expanded(
            child: TabBarView(
          children: <Widget>[
            SearchSuggestPage(),
            SearchSuggestPage(),
            SearchSuggestPage(),
          ],
        ))
      ],
    );
  }

//设置搜索框搜索结果
  void seachTxtChanged(String q) async {
    var result = await getSuggest(q) as List;
    recomendWords = result.map((dynamic i) {
      List item = i as List;
      return item[0] as String;
    }).toList();
    setState(() {});
  }
}
