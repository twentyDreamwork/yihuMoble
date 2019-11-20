class Article {
  final String date;
  final String url;
  final String id;
  final String typeName;
  final String contentImg;
  final String contentImg2;
  final String contentImg3;

  final String title;

  Article.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        date = json['date'],
        url = json['url'],
        typeName = json['chtypeNameannelName'],
        contentImg = json['thumbnail_pic_s'],
        contentImg2 = json['thumbnail_pic_s02'],
        contentImg3 = json['thumbnail_pic_s03'],
        title = json['title'];
}
