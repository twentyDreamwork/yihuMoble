import 'package:http/http.dart' as Http;
import 'package:yhmoble/pages/new/model/article.dart';
import 'dart:convert';

class Api {
  static final String host = "https://www.oschina.net";
  static String baseUrl = "http://v.juhe.cn/toutiao/index";
  static String key = "1576d51e19453892b96a792476eb37df";

  // 新闻列表  --聚合数据
  static final String newsList =
      "http://v.juhe.cn/toutiao/index?type=&key=1576d51e19453892b96a792476eb37df";

  //获取分类数据详情
  static void featchTypeDetailList(int page, String typeId, Function callback,
      {List<Article> artileList, Function errorback}) async {
    final String url = "$baseUrl?key=$key&type=$typeId";
    print(url);
    try {
      await Http.get(url).then((Http.Response response) {
        if (response.statusCode == 200) {
          print(response.statusCode);
          Map jsonMap = json.decode(response.body);
          // print(jsonMap);
          List jsonlist = jsonMap['result']['data'];
          List<Article> list =
              jsonlist.map((f) => Article.fromJson(f)).toList();
          callback(list);
        } else {
          errorback(response.body);
        }
      });
    } catch (e) {
      errorback(e);
    }
  }
}
