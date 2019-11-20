import 'package:flutter/material.dart';
import '../model/category_goods_list_model.dart';

//分类商品列表数据
class CategoryGoodsListProvide with ChangeNotifier{

  List<CategoryListData> goodsList = [];

  getGoodsList(List<CategoryListData> list){

    goodsList = list;
    notifyListeners();
  }

  //上拉加载列表 追回列表数据
  addGoodsList(List<CategoryListData> list){
    goodsList.addAll(list);
    notifyListeners();
  }

}