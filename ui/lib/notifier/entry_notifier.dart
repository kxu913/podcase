import 'package:crawler/domain/entry.dart';

import 'package:flutter/material.dart';

class EntryNotifier with ChangeNotifier {
  late Entry _entry;

  Entry get entry => _entry;

  set entry(Entry entry) {
    _entry = entry;
    notifyListeners();
  }
}
