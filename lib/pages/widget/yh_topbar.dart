import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yhmoble/common/utils/navigator_utils.dart';
import 'package:yhmoble/pages/widget/yh_search_card.dart';
import 'package:yhmoble/util/DataUtils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopBar extends StatefulWidget {
  final List<String> searchHintTexts;
  TopBar({Key key, this.searchHintTexts}) : super(key: key);
  // CategoryPage(this.categoryIndex);

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  String avatar = "";
  BuildContext _context;
  FocusNode _focus = new FocusNode();
  TextEditingController _keywordTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getSvatar();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    _focus.addListener(_onFocusChange);

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      color: Color.fromRGBO(255, 255, 255, 1),
      padding:
          EdgeInsets.only(top: statusBarHeight, left: 0, right: 0, bottom: 0),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 6.0, left: 4),
//            color: Colors.red,
            height: 30,
            width: 30,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(55),
                  child: avatar != null?
                  CachedNetworkImage(
                    imageUrl: avatar,
                    width: ScreenUtil().setWidth(105),
                    fit: BoxFit.cover,
                  ):Image.asset(
                    'assets/images/my_header.png',
                    width: ScreenUtil().setWidth(105),
                    fit: BoxFit.cover,
                  ),
                ),
                // Icon(
                //   Icons.star,
                //   color: Colors.white,
                //   size: 18,
                // ),
                // SizedBox(
                //   height: 3,
                // ),
                // Expanded(
                //   child: Text(
                //     '扫一扫',
                //     style: TextStyle(
                //       fontSize: 8,
                //       color: Colors.white,
                //     ),
                //   ),
                // )
              ],
            ),
          ),
//           Container(
//             margin: EdgeInsets.only(right: 6.0, left: 4),
// //            color: Colors.red,
//             width: 30,
//             height: 30,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 _circleButton(Color(0xFF32b3fb), Icons.school, '', 2),
//               ],
//             ),
//           ),

          Expanded(
            flex: 1,
            child: YHSearchCardWidget(
              elevation: 0,
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                NavigatorUtils.gotoSearchGoodsPage(_context);
              },
              textEditingController: _keywordTextEditingController,
              focusNode: _focus,
            ),
          ),

//           Container(
//             margin: EdgeInsets.only(left: 6.0, right: 4),
// //            color: Colors.red,
//             width: 30,
//             height: 30,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Icon(
//                   Icons.star,
//                   color: Colors.white,
//                   size: 18,
//                 ),
//                 SizedBox(
//                   height: 3,
//                 ),
//                 Expanded(
//                   child: Text(
//                     '会员码',
//                     style: TextStyle(
//                       fontSize: 8,
//                       color: Colors.white,
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//          Container(
//            margin: EdgeInsets.only(left: 6.0),
//            child: Icon(
//              Icons.add_alert,
//              size: 25.0,
//              color: Color.fromRGBO(132, 95, 63, 1.0),
//            ),
//          )
        ],
      ),
    );
  }

  void _onFocusChange() {
    print('HomeTopBar._onFocusChange${_focus.hasFocus}');
    if (!_focus.hasFocus) {
      return;
    }
    NavigatorUtils.gotoSearchGoodsPage(_context);
  }

  Future _getSvatar() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      avatar = sp.getString(DataUtils.SP_USER_AVATAR);
      print(avatar);
    });
  }

  Widget _circleButton(
      Color imageBackgroundColor, IconData iconData, text, int unreadMessages) {
    return Container(
//      color: Colors.red,
      width: 30,
      child: GestureDetector(
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
//        mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: imageBackgroundColor,
                  radius: 22,
                  child: Icon(
                    iconData,
                    color: Colors.white,
                  ),
                ),
                // SizedBox(
                //   height: 4,
                // ),
                // Text(
                //   text,
                //   style: TextStyle(
                //     fontSize: 10,
                //     color: Color(0xFF6a6a6a),
                //   ),
                // )
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
//                width: 18.0,
//                height: 18.0,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1),
                    borderRadius: BorderRadius.circular(20 / 2.0),
                    color: Color(0xffff3e3e)),
                child: Text(
                  '${unreadMessages}',
                  style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffffffff)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
