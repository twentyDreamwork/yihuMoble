class CategoryGoodsListModel {
  String message;
  List<CategoryListData> data;

  CategoryGoodsListModel({this.message, this.data});

  CategoryGoodsListModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json['result'] != null) {
      data = new List<CategoryListData>();
      json['result'].forEach((v) {
        data.add(new CategoryListData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    if (this.data != null) {
      data['result'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CategoryListData {
  String image;
  double oriPrice;
  double presentPrice;
  String name;
  String goodsId;
  String taobaoUrl;

  CategoryListData(
      {this.image,
      this.oriPrice,
      this.presentPrice,
      this.name,
      this.goodsId,
      this.taobaoUrl});

  CategoryListData.fromJson(Map<String, dynamic> json) {
    image = json['goodsImg'];
    oriPrice = json['oldPrice'];
    presentPrice = json['price'];
    name = json['mainTitle'];
    goodsId = json['shopId'];
    taobaoUrl = json['taobaoUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    data['oriPrice'] = this.oriPrice;
    data['presentPrice'] = this.presentPrice;
    data['name'] = this.name;
    data['goodsId'] = this.goodsId;
    data['taobaoUrl'] = this.taobaoUrl;

    return data;
  }
}
