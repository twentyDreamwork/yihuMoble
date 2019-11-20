import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yhmoble/pages/integral/integralGoods_page.dart';
import 'package:yhmoble/service/http_service.dart';
import 'package:yhmoble/util/DataUtils.dart';
import 'package:toast/toast.dart';
import '../config/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

class MemberPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MemberPageState();
  }
}

class MemberPageState extends State<MemberPage> {
  var unionId;
  var nickName;
  var avatar;
  var points;
  var invite;
  var phone;
  var sign;
  var id;
  @override
  void initState() {
    _getUserInfo();
    super.initState();
  }

  Future _getUserInfo() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (sp.getString(DataUtils.SP_USER_UNIONID) == null) {
      _login();
    }
    setState(() {
      unionId = sp.getString(DataUtils.SP_USER_UNIONID);
      nickName = sp.getString(DataUtils.SP_USER_NICK_NAME);
      avatar = sp.getString(DataUtils.SP_USER_AVATAR);
      points = sp.getString(DataUtils.SP_USER_POINTS);
      invite = sp.getString(DataUtils.SP_USER_INVITE);
      phone = sp.getString(DataUtils.SP_USER_PHONE);
      sign = sp.getString(DataUtils.SP_USER_IS_SIGN);
    });
  }

  // 获取用户信息
  Future _login() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    fluwx.sendAuth(scope: "snsapi_userinfo", state: "wechar_sdk_demo_test");
    fluwx.responseFromAuth.listen((data) {
      var formPage = "?appid=" +
          DataUtils.APPID +
          "&secret=" +
          DataUtils.SERCRET +
          "&code=${data.code}&platforms=1";
      getRequest('getWeixinInfo', formPage).then((val) {
        Map user = json.decode(val.toString());
        setState(() {
          nickName = user['result']['nickName'];
          unionId = user['result']['unionId'];
          avatar = user['result']['avatar'];
          points = user['result']['points'].toString();
          invite = user['result']['invite'];
          phone = user['result']['phone'];
          id = user['result']['id'].toString();

          sp.setString(DataUtils.SP_USER_NICK_NAME, nickName);
          sp.setString(DataUtils.SP_USER_UNIONID, unionId);
          sp.setString(DataUtils.SP_USER_AVATAR, avatar);
          sp.setString(DataUtils.SP_USER_PHONE, phone);
          sp.setString(DataUtils.SP_USER_POINTS, points);
          sp.setString(DataUtils.SP_USER_INVITE, invite);
          sp.setString(DataUtils.SP_USER_ID, id);
          sp.setBool(DataUtils.SP_IS_LOGIN, true);
        });
      });
    });
  }

  Future _signInPoint() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String id = sp.getString(DataUtils.SP_USER_UNIONID);
    var formPage = "?unionId=" + id;
    getRequest('signInPoint', formPage).then((val) {
      Map data = json.decode(val.toString());
      if (data['code'] == 404) {
        showToast("当天已签到");
      } else {
        setState(() {
          nickName = data['result']['nickName'];
          unionId = data['result']['unionId'];
          avatar = data['result']['avatar'];
          points = data['result']['points'].toString();
          invite = data['result']['invite'];
          phone = data['result']['phone'];
          sp.setString(DataUtils.SP_USER_NICK_NAME, nickName);
          sp.setString(DataUtils.SP_USER_UNIONID, unionId);
          sp.setString(DataUtils.SP_USER_AVATAR, avatar);
          sp.setString(DataUtils.SP_USER_PHONE, phone);
          sp.setString(DataUtils.SP_USER_POINTS, points);
          sp.setString(DataUtils.SP_USER_INVITE, invite);
        });

        showToast("签到成功");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(KString.memberTitle), //会员中心
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          _topHeader(),
          _orderTitle(),
          _orderType(),
          _actionList(),
        ],
      ),
    );
  }

  //头像区域
  Widget _topHeader() {
    return avatar != null
        ? Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(55),
                  child: CachedNetworkImage(
                    imageUrl: avatar,
                    width: ScreenUtil().setWidth(105),
                    fit: BoxFit.cover,
                  ),
                ),
                new Expanded(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Container(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: new Column(
                            children: <Widget>[
                              new Text(
                                nickName,
                                style: new TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )),
                      new Container(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: new Column(
                            children: <Widget>[
                              new Text(
                                '积分:${points}',
                                style: new TextStyle(
                                  color: Colors.grey[500],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
                RaisedButton.icon(
                  color: Colors.white,
                  label: Text("签到"),
                  icon: Icon(Icons.date_range),
                  onPressed: () {
                    _signInPoint();
                  },
                ),
              ],
            ),
          )
        : InkWell(
            onTap: () {
              _login();
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(55),
                      child: Image.asset(
                        'assets/images/my_header.png',
                        width: ScreenUtil().setWidth(105),
                        fit: BoxFit.cover,
                      )),
                  new Expanded(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Container(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: new Column(
                              children: <Widget>[
                                new Text(
                                  "点击登录",
                                  style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ));
  }

  //我的订单标题
  Widget _orderTitle() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(width: 1, color: KColor.defaultBorderColor),
        ),
      ),
      child: ListTile(
        leading: Icon(Icons.list),
        title: Text('我的订单'),
        trailing: Icon(Icons.arrow_right),
      ),
    );
  }

  //我的订单类型
  Widget _orderType() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      width: ScreenUtil().setWidth(750),
      height: ScreenUtil().setHeight(150),
      padding: EdgeInsets.only(top: 20),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Container(
            width: ScreenUtil().setWidth(187),
            child: Column(
              children: <Widget>[
                Icon(
                  Icons.payment,
                  size: 30,
                ),
                Text(KString.pendingPayText), //'待付款'
              ],
            ),
          ),
          Container(
            width: ScreenUtil().setWidth(187),
            child: Column(
              children: <Widget>[
                Icon(
                  Icons.directions_car,
                  size: 30,
                ),
                Text(KString.toBeSendText), //'待发货'
              ],
            ),
          ),
          Container(
            width: ScreenUtil().setWidth(187),
            child: Column(
              children: <Widget>[
                Icon(
                  Icons.directions_car,
                  size: 30,
                ),
                Text(KString.toBeReceivedText), //'待收货'
              ],
            ),
          ),
          Container(
            width: ScreenUtil().setWidth(187),
            child: Column(
              children: <Widget>[
                Icon(
                  Icons.message,
                  size: 30,
                ),
                Text(KString.evaluateText), //'待评价'
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _myListTile(String title) {
    return InkWell(
        onTap: () {
          if (title == '积分记录') {
            print("11");
          } else if (title == '积分商城') {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => IntegralGoodsPage()));
          } else if (title == '分享下载') {
            _share();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(width: 1, color: KColor.defaultBorderColor),
            ),
          ),
          child: ListTile(
            leading: Icon(Icons.blur_circular),
            title: Text(title),
            trailing: Icon(Icons.arrow_right),
          ),
        ));
  }

  //其它操作列表
  Widget _actionList() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Column(
        children: <Widget>[
          _myListTile('积分详情'),
          _myListTile('积分商城'),
          _myListTile('地址管理'),
          _myListTile('分享下载'),
          _myListTile('客服电话'),
          _myListTile('关于我们'),
        ],
      ),
    );
  }

  void _share() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String userId = sp.getString(DataUtils.SP_USER_ID);
    String _url =
        "https://open.weixin.qq.com/connect/oauth2/authorize?appid=wx2db9deb8d8497166&redirect_uri=http%3a%2f%2fwww.yihumh.com%2fweixinNotifyUrl%2f${userId}&response_type=code&scope=snsapi_userinfo&state=STATE#wechat_redirect";
    print(_url);
    String _title = "分享越多得到越多，还在等什么快一起玩吧！";
    String _thumnail =
        "https://yihuobj.oss-cn-shenzhen.aliyuncs.com/upload/20191014/45305c6a57994c9ab0fdadc4f4c89e42.png";
    fluwx.WeChatScene scene = fluwx.WeChatScene.SESSION;
    var model = fluwx.WeChatShareWebPageModel(
        webPage: _url,
        title: _title,
        thumbnail: _thumnail,
        scene: scene,
        transaction: "yihu");
    fluwx.share(model);
  }

  // 弹出toast
  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
