import 'dart:convert';

import 'package:timeago/timeago.dart' as timeago;

class Feed {
  String title;
  String logo;
  String des;
  // String image;
  String lastUpdated;
  String url;
  List<String> tags;

  Feed(
      {this.title = "",
      this.logo = "",
      this.des = "",
      this.url = "",
      required this.tags,
      this.lastUpdated = ""});

  factory Feed.fromJson(Map<String, dynamic> json) {
    return Feed(
        title: json["title"],
        logo: json["image"],
        des: json["summary"],
        // image: json["image"],
        tags: convertToList(json["terms"]["Terms"]),
        lastUpdated: convertDate(json["last_updated_time"]["LastUpdated"]));
  }

  static String convertDate(String dateStr) {
    DateTime tempDate = DateTime.parse(dateStr);
    return timeago.format(tempDate);
  }

  static List<String> convertToList(List<dynamic> s) {
    List<String> tags = s.map((e) => e.toString()).toList();
    return tags;
  }

  static fromEntryJson(Map<String, dynamic> json) {
    return Feed(
      title: json["_source"]["feed_title"],
      url: json["_source"]["feed_url"],
      tags: convertToList(json["_source"]["terms"]["Terms"]),
    );
  }
}
