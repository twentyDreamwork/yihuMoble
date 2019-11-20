import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yhmoble/config/color.dart';
import 'package:yhmoble/config/string.dart';
import 'package:yhmoble/service/http_service.dart';
import 'package:yhmoble/util/DataUtils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

//软件界面
class SoftwarePage extends StatefulWidget {
  @override
  _SoftwarePage createState() {
    return _SoftwarePage();
  }
}

class _SoftwarePage extends State<SoftwarePage>
    with AutomaticKeepAliveClientMixin {
  //仿止刷新处理 保持当前状态
  @override
  bool get wantKeepAlive => true;

  GlobalKey<RefreshFooterState> _footerKey =
      new GlobalKey<RefreshFooterState>();
  GlobalKey<RefreshHeaderState> _headerKey =
      new GlobalKey<RefreshHeaderState>();

  //下载列表数据
  List<Map> downloadList = [];
  int page = 1;
  @override
  void initState() {
    super.initState();
    _getDownloadList();
    // 初始化进度条
    ProgressDialog pr =
        new ProgressDialog(context, ProgressDialogType.Download);
    pr.setMessage('下载中…');
    // 设置下载回调
    FlutterDownloader.registerCallback((id, status, progress) {
      // 打印输出下载信息
      print(
          'Download task ($id) is in status ($status) and process ($progress)');
      if (!pr.isShowing()) {
        pr.show();
      }
      if (status == DownloadTaskStatus.running) {
        pr.update(progress: progress.toDouble(), message: "下载中，请稍后…");
      }
      if (status == DownloadTaskStatus.failed) {
        showToast("下载异常，请稍后重试");
        if (pr.isShowing()) {
          pr.hide();
        }
      }

      if (status == DownloadTaskStatus.complete) {
        print(pr.isShowing());
        if (pr.isShowing()) {
          pr.hide();
        }
        // 显示是否打开的对话框
        showDialog(
            // 设置点击 dialog 外部不取消 dialog，默认能够取消
            barrierDismissible: false,
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('提示'),
                  // 标题文字样式
                  content: Text('文件下载完成，是否打开？'),
                  // 内容文字样式
                  backgroundColor: CupertinoColors.white,
                  elevation: 8.0,
                  // 投影的阴影高度
                  semanticLabel: 'Label',
                  // 这个用于无障碍下弹出 dialog 的提示
                  shape: Border.all(),
                  // dialog 的操作按钮，actions 的个数尽量控制不要过多，否则会溢出 `Overflow`
                  actions: <Widget>[
                    // 点击取消按钮
                    FlatButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('取消')),
                    // 点击打开按钮
                    FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // 打开文件
                          _openDownloadedFile(id).then((success) {
                            print(success);
                            if (!success) {
                              Scaffold.of(context).showSnackBar(
                                  SnackBar(content: Text('不能打开此文件')));
                            }
                          });
                        },
                        child: Text('打开')),
                  ],
                ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(244, 245, 245, 1.0),
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
                _viewList(),
              ],
            ),
            loadMore: () async {
              print('开始加载更多');
              _getDownloadList();
            },
            onRefresh: () async {
              print("上拉刷新了");
              page = 1;
              downloadList = [];
              _getDownloadList();
            }));
  }

  Widget _viewList() {
    return Wrap(
        spacing: 5.0, //两个widget之间横向的间隔
        direction: Axis.horizontal, //方向
        alignment: WrapAlignment.start, //内容排序方式
        children: List<Widget>.generate(downloadList.length, (int index) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CachedNetworkImage(
                  imageUrl: downloadList[index]['img'],
                  width: ScreenUtil().setWidth(105),
                  fit: BoxFit.cover,
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
                                downloadList[index]['channelName'],
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
                                downloadList[index]['channelDescribe'],
                                style: new TextStyle(
                                  color: Colors.grey[500],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          )),
                      new Container(
                          margin: EdgeInsets.only(left: 5.0),
                          padding: const EdgeInsets.only(left: 5.0),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.red, width: 1), //边框
                            borderRadius: BorderRadius.all(
                              //圆角
                              Radius.circular(10.0),
                            ),
                          ),
                          child: new Column(
                            children: <Widget>[
                              new Text(
                                '${downloadList[index]['channelOnepoint']}积分',
                                style: new TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
                new MaterialButton(
                  color: Colors.red,
                  textColor: Colors.white,
                  child: new Text('点击下载'),
                  onPressed: () {
                    String url = downloadList[index]['url'];
                    if (url == null || url=="") {
                      showToast("下载链接不存在");
                    } else {
                      _doDownloadOperation(url);
                    }
                    // print(
                    //     "https://yihuobj.oss-cn-shenzhen.aliyuncs.com/upload/20191015/b489793010db4743a3e43a9b60ca7cee.apk");
                  },
                )
              ],
            ),
          );
        }));
  }

  Future _getDownloadList() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String unionId = sp.getString(DataUtils.SP_USER_UNIONID);
    var formPage =
        "?page=${page}&limit=10&channelType=2&channelPlatform=1&unionId=" +
            unionId;
    getRequest('downloadlist', formPage).then((val) {
      var data = json.decode(val.toString());
      List<Map> newGoodsList = (data['result']['list'] as List).cast();
      setState(() {
        downloadList.addAll(newGoodsList);
        page++;
      });
    });
  }

  // 执行下载文件的操作
  _doDownloadOperation(downloadUrl) async {
    /**
     * 下载文件的步骤：
     * 1. 获取权限：网络权限、存储权限
     * 2. 获取下载路径
     * 3. 设置下载回调
     */

    // 获取权限
    var isPermissionReady = await _checkPermission();
    if (isPermissionReady) {
      // 获取存储路径
      var _localPath = (await _findLocalPath()) + '/Download';

      final savedDir = Directory(_localPath);
      // 判断下载路径是否存在
      bool hasExisted = await savedDir.exists();
      // 不存在就新建路径
      if (!hasExisted) {
        savedDir.create();
      }
      // 下载
      _downloadFile(downloadUrl, _localPath);
    } else {
      showToast("您还没有获取权限");
    }
  }

// 申请权限
  Future<bool> _checkPermission() async {
    // 先对所在平台进行判断
    if (Theme.of(context).platform == TargetPlatform.android) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler()
                .requestPermissions([PermissionGroup.storage]);
        if (permissions[PermissionGroup.storage] == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

// 获取存储路径
  Future<String> _findLocalPath() async {
    // 因为Apple没有外置存储，所以第一步我们需要先对所在平台进行判断
    // 如果是android，使用getExternalStorageDirectory
    // 如果是iOS，使用getApplicationSupportDirectory
    final directory = Theme.of(context).platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationSupportDirectory();
    return directory.path;
  }

  // 根据 downloadUrl 和 savePath 下载文件
  _downloadFile(downloadUrl, savePath) async {
    await FlutterDownloader.enqueue(
      url: downloadUrl,
      savedDir: savePath,
      showNotification: true,
      // show download progress in status bar (for Android)
      openFileFromNotification:
          true, // click on notification to open downloaded file (for Android)
    );
  }

  // 根据taskId打开下载文件
  Future<bool> _openDownloadedFile(taskId) {
    return FlutterDownloader.open(taskId: taskId);
  }

  // 弹出toast
  void showToast(String msg, {int duration, int gravity}) {
    Toast.show(msg, context, duration: duration, gravity: gravity);
  }
}
