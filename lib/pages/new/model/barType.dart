class BarType {
  String id = "";
  String name = "";

  BarType(this.id, this.name);

  BarType.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'];
}
