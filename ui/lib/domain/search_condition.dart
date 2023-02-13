class SearchCondition {
  String field;
  String keyword;
  int size;
  int from;
  List<String> includes = [
    "entry_url",
    "entry_title",
    "entry_image",
    "entry_publish_at",
    "entry_summary",
    "feed_title",
    "feed_url",
    "terms",
  ];

  SearchCondition({
    this.field = "",
    this.keyword = "",
    this.size = 100,
    this.from = 0,
  });
  Map<String, dynamic> toJson() => {
        "field": field,
        "keyword": keyword,
        "size": size,
        "from": from,
        "includes": includes
      };
}
