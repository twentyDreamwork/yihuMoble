import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import '../config/index.dart';

Future request(url, {formData}) async {
  try {
    Response response;
    Dio dio = new Dio();
    if (formData == null) {
      response = await dio.post(servicePath[url]);
    } else {
      response = await dio.post(servicePath[url], data: formData);
    }
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('后端接口异常,请检查测试代码和服务器运行情况...');
    }
  } catch (e) {
    return print('error:::${e}');
  }
}

Future getRequest(url, data) async {
  try {
    Response response;
    Dio dio = new Dio();
    print(servicePath[url] + data);
    if (data == null) {
      print(servicePath[url]);
      response = await dio.get(servicePath[url]);
    } else {
      print(servicePath[url] + data);
      response = await dio.get(servicePath[url] + data);
    }
    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('后端接口异常,请检查测试代码和服务器运行情况...');
    }
  } catch (e) {
    return print('error:::${e}');
  }
}
