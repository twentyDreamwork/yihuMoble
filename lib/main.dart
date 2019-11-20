import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yhmoble/provide/new_provide.dart';
import './config/index.dart';
import './provide/current_index_provide.dart';
import 'package:provide/provide.dart';
import './pages/index_page.dart';
import './provide/category_goods_list_provide.dart';
import './routers/routes.dart';
import 'package:fluro/fluro.dart';
import './routers/application.dart';
import './provide/details_info_provide.dart';
import 'package:fluwx/fluwx.dart' as fluwx;

void main() {
  _initFluwx(); //注册微信
  var currentIndexProvide = CurrentIndexProvide();

  var categoryGoodsListProvide = CategoryGoodsListProvide();
  var detailsInfoProvide = DetailsInfoProvide();
  var newProvide = NewProvide();
  var providers = Providers();

  providers
    ..provide(
        Provider<CategoryGoodsListProvide>.value(categoryGoodsListProvide))
    ..provide(Provider<DetailsInfoProvide>.value(detailsInfoProvide))
    ..provide(Provider<NewProvide>.value(newProvide))
    ..provide(Provider<CurrentIndexProvide>.value(currentIndexProvide));

  runApp(ProviderNode(child: MyApp(), providers: providers));
  if (Platform.isAndroid) {
    // 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final router = Router();
    Routes.configureRoutes(router);
    Application.router = router;

    return Container(
      child: MaterialApp(
        title: KString.mainTitle,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: Application.router.generator,
        //定制主题
        theme: ThemeData(
          primaryColor: KColor.primaryColor,
        ),
        home: IndexPage(),
      ),
    );
  }
}

_initFluwx() async {
  await fluwx.registerWxApi(
      appId: "wx2c8beb0c8c6d5aec",
      universalLink: "https://your.univeral.link.com/placeholder/");
}
