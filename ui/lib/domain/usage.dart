import 'package:timeago/timeago.dart' as timeago;

class UsageTracking {
  String uid;

  int playTime;
  String feedUrl;
  String tags;

  UsageTracking(
      {this.uid = "kevin",
      this.playTime = 0,
      this.feedUrl = "",
      this.tags = ""});
}
