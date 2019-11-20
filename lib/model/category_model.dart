class CategoryModel {
  List<CategoryData> data;
  int code;

  CategoryModel({this.data, this.code});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    if (json['result'] != null) {
      data = new List<CategoryData>();
      (json['result'] as List).forEach((v) {
        data.add(new CategoryData.fromJson(v));
      });
    }
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['result'] = this.data.map((v) => v.toJson()).toList();
    }
    data['code'] = this.code;
    return data;
  }
}

class CategoryData {
  String classifyName;
  int id;
  int parentId;
  String icons;
  List<CategoryDataChilds> childs;

  CategoryData(
      {this.classifyName, this.childs, this.id, this.parentId, this.icons});

  CategoryData.fromJson(Map<String, dynamic> json) {
    classifyName = json['classifyName'];
    if (json['childs'] != null) {
      childs = new List<CategoryDataChilds>();
      (json['childs'] as List).forEach((v) {
        childs.add(new CategoryDataChilds.fromJson(v));
      });
    }
    id = json['id'];
    parentId = json['parentId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['classifyName'] = this.classifyName;
    if (this.childs != null) {
      data['childs'] = this.childs.map((v) => v.toJson()).toList();
    }
    data['id'] = this.id;
    data['parentId'] = this.parentId;
    return data;
  }
}

class CategoryDataChilds {
  String classifyName;
  int id;
  int parentId;
  String icons;
  List<CategoryDataChilds> childs;

  CategoryDataChilds({this.classifyName, this.id, this.parentId, this.childs});

  CategoryDataChilds.fromJson(Map<String, dynamic> json) {
    classifyName = json['classifyName'];
    id = json['id'];
    parentId = json['parentId'];
    icons = json['icons'];

    if (json['childs'] != null) {
      childs = new List<CategoryDataChilds>();
      (json['childs'] as List).forEach((v) {
        childs.add(new CategoryDataChilds.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['classifyName'] = this.classifyName;
    data['id'] = this.id;
    data['parentId'] = this.parentId;
    data['icons'] = this.icons;
    if (this.childs != null) {
      childs = new List<CategoryDataChilds>();
      (data['childs'] as List).forEach((v) {
        childs.add(new CategoryDataChilds.fromJson(v));
      });
    }

    return data;
  }
}
