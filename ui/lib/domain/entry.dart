import 'package:timeago/timeago.dart' as timeago;

import 'feed.dart';

class Entry {
  String title;
  String url;
  String image;
  String publishAt;
  String desc;
  Feed feed;

  Entry({
    this.title = "",
    this.url = "",
    this.image = "",
    this.publishAt = "",
    this.desc = "",
    required this.feed,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
        title: json["_source"]["entry_title"],
        url: json["_source"]["entry_url"],
        image: json["_source"]["entry_image"] ?? "default.png",
        publishAt: convertDate(
            json["_source"]["entry_publish_at"]["entry_publish_at"]),
        desc: json["_source"]["entry_summary"] ?? "",
        feed: Feed.fromEntryJson(json));
  }

  static List<String> convertToList(List<dynamic> s) {
    List<String> tags = s.map((e) => e.toString()).toList();
    return tags;
  }

  static String convertDate(String dateStr) {
    DateTime tempDate = DateTime.parse(dateStr);
    return timeago.format(tempDate);
  }
}
