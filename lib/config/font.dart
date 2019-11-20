import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yhmoble/config/color.dart';

class KFont {
  //原价文本样式
  static TextStyle oriPriceStyle = TextStyle(
      color: Colors.black26,
      decoration: TextDecoration.lineThrough,
      fontSize: ScreenUtil().setSp(20));
  //现价
  static TextStyle presentPriceTextColor = TextStyle(
      color: KColor.presentPriceTextColor,
      fontWeight: FontWeight.bold,
      fontSize: ScreenUtil().setSp(28));
  static TextStyle integralStyle = TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.bold,
      fontSize: ScreenUtil().setSp(28));
  //库存文本样式
  static TextStyle inventoryStyle = TextStyle(
      color: Colors.black26,
      fontWeight: FontWeight.bold,
      fontSize: ScreenUtil().setSp(20));
}
