import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yhmoble/config/http_conf.dart';
import 'dart:async';
import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:dio/dio.dart';
import 'package:device_info/device_info.dart';

class DataUtils {
  static const String SP_AC_TOKEN = "accessToken";
  static const String SP_RE_TOKEN = "refreshToken";
  static const String OPEN_ID = "openid";
  static const String SP_UID = "uid";
  static const String SP_IS_LOGIN = "isLogin";
  static const String SP_EXPIRES_IN = "expiresIn";
  static const String SP_TOKEN_TYPE = "tokenType";

  static const String SP_USER_NICK_NAME = "nickname";
  static const String SP_USER_UNIONID = "unionid";
  static const String SP_USER_AVATAR = "avatar";
  static const String SP_USER_PHONE = "phone";
  static const String SP_USER_POINTS = "points";
  static const String SP_USER_INVITE = "invite";
  static const String SP_USER_IS_SIGN = "false";
  static const String SP_USER_ID = "01";

  static const String APPID = "wx2c8beb0c8c6d5aec";
  static const String SERCRET = "76564b2acc0f7e49999df72d18d977dc";

  static const String SP_COLOR_THEME_INDEX = "colorThemeIndex";

  // 清除登录信息
  static clearLoginInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    await sp.setString(SP_USER_NICK_NAME, "");
    await sp.setString(SP_USER_UNIONID, "");
    await sp.setString(SP_USER_AVATAR, "");
    await sp.setString(SP_TOKEN_TYPE, "");
    await sp.setInt(SP_EXPIRES_IN, -1);
    await sp.setBool(SP_IS_LOGIN, false);
  }

  // 是否登录
  static Future<bool> isLogin() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    bool b = sp.getBool(SP_IS_LOGIN);
    return b != null && b;
  }

  static Future<String> signInPoint() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String id = sp.getString(SP_USER_UNIONID);
    final response =
        await new Dio().get(servicePath['signInPoint'] + "?unionId=" + id);
    print(servicePath['signInPoint'] + "?unionId=" + id);
    Map user = json.decode(response.toString());
    if (user['code'] == 404) {
      await sp.setString(SP_USER_IS_SIGN, "当天已签到");
    } else {
      String nickName = user['result']['nickName'];
      String unionId = user['result']['unionId'];
      String avatar = user['result']['avatar'];
      String points = user['result']['points'].toString();
      String invite = user['result']['invite'];
      String phone = user['result']['phone'];
      String id = user['result']['id'];
      await sp.setString(SP_USER_NICK_NAME, nickName);
      await sp.setString(SP_USER_UNIONID, unionId);
      await sp.setString(SP_USER_AVATAR, avatar);
      await sp.setString(SP_USER_PHONE, phone);
      await sp.setString(SP_USER_POINTS, points);
      await sp.setString(SP_USER_INVITE, invite);
      await sp.setBool(SP_IS_LOGIN, true);
      await sp.setString(SP_USER_ID, id);
      await sp.setString(SP_USER_IS_SIGN, "签到成功");
    }

    return "success";
  }
}
