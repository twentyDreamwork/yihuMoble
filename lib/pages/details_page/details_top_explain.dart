import 'package:flutter/material.dart';
import '../../config/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

//商品详情页的说明
class DetailsExplain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.all(10.0),
      width: ScreenUtil().setWidth(750),
      child: Text(
        //'说明: > 急速送达 > 正品保证',
        KString.detailsPageExplain,
        style: TextStyle(
          color: Colors.red,
          fontSize: ScreenUtil().setSp(30),
        ),
      ),
    );
  }





}
