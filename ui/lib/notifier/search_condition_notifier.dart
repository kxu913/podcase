import 'dart:convert';

import 'package:crawler/domain/entry.dart';
import 'package:crawler/domain/search_condition.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SearchConditionNotifier with ChangeNotifier {
  final SearchCondition _sc = SearchCondition();
  SearchCondition get sc => _sc;
  set field(String field) => _sc.field = field;
  List<Entry> entries = [];

  void search(String filed, String keyword) {
    _sc.field = filed;
    _sc.keyword = keyword;

    Dio dio = Dio();
    dio.options.baseUrl = "http://localhost/api/";

    dio
        .post("search",
            data: jsonEncode(_sc),
            options: Options(headers: {
              "responseType": ResponseType.json,
            }))
        .then((v) {
      entries =
          (v.data as List<dynamic>).map((e) => Entry.fromJson(e)).toList();
      notifyListeners();
    });
  }
}
