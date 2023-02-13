import 'package:dio/dio.dart';

class Api {
  static Future<void> getFeeds(Function fn) async {
    Dio dio = Dio();
    dio.options.baseUrl = "http://localhost:8080/api/";
    await dio
        .get(
          "feeds",
        )
        .then((value) => fn(value));
  }
}
