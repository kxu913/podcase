import 'package:crawler/domain/entry.dart';
import 'package:flutter/material.dart';

class EntriesNotifier with ChangeNotifier {
  List<Entry> entries = [];

  void reloadEntries(List<Entry> entries) {
    this.entries = entries;
    notifyListeners();
  }
}
