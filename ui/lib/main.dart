import 'package:crawler/notifier/entries_notifier.dart';
import 'package:crawler/notifier/entry_notifier.dart';

import 'package:crawler/notifier/search_condition_notifier.dart';
import 'package:crawler/widget/play.dart';

import 'package:crawler/widget/entries.dart';
import 'package:crawler/widget/feedlist.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

void main() {
  runApp(const FeedApp());
}

class FeedApp extends StatelessWidget {
  const FeedApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SearchConditionNotifier()),
        ChangeNotifierProvider(create: (context) => EntryNotifier()),
        ChangeNotifierProvider(create: (context) => EntriesNotifier()),
      ],
      child: MaterialApp(
        theme: ThemeData(
            backgroundColor: const Color(0xFFEEEEEE),
            appBarTheme: AppBarTheme(
              color: Colors.red[600],
              titleTextStyle: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w400,
                fontFamily: "SourceHanSansCN",
              ),
            ),
            fontFamily: "SourceHanSansCN",
            iconTheme: const IconThemeData(
              color: Colors.blueAccent,
              size: 30,
            ),
            textTheme: const TextTheme(
              headline1: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
              headline6: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
              bodyText1: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400),
              bodyText2: TextStyle(color: Colors.grey, fontSize: 12),
              subtitle1: TextStyle(color: Colors.lightBlueAccent, fontSize: 11),
            )),
        title: '播客',
        initialRoute: '/',
        routes: {
          '/': (context) => const FeedList(),
          '/entry': (context) => const Entries(),
          '/play': (context) => const AudioPlayPage(),
        },
      ),
    );
  }
}
