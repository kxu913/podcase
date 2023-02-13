import 'dart:convert';

import 'package:crawler/constants/constants.dart';
import 'package:crawler/domain/entry.dart';
import 'package:crawler/domain/feed.dart';
import 'package:crawler/domain/search_condition.dart';
import 'package:crawler/notifier/entry_notifier.dart';

import 'package:crawler/notifier/search_condition_notifier.dart';
import 'package:crawler/util/textutil.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeedList extends StatelessWidget {
  const FeedList({super.key});

  Container createSubtitle(BuildContext context, String name) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: titlePadding,
      child: Text(
        name,
        style: Theme.of(context).textTheme.headline1,
      ),
    );
  }

  Container createLatestTitle(BuildContext context) {
    SearchConditionNotifier notifier = context.watch<SearchConditionNotifier>();
    return Container(
        alignment: Alignment.centerLeft,
        padding: titlePadding,
        child: Row(
          children: [
            Expanded(
                flex: 8,
                child: Text(
                  "最近更新",
                  style: Theme.of(context).textTheme.headline1,
                )),
            Expanded(
                flex: 2,
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: rightPadding,
                  child: TextButton(
                    onPressed: (() {
                      notifier.search("feed_title", "最近更新");
                      Navigator.pushReplacementNamed(context, '/entry');
                    }),
                    child: Text(
                      "查看更多",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                )),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: Column(
        children: [
          const _FeedListBar(),
          createLatestTitle(context),
          const Divider(),
          const _LatestUpdated(),
          createSubtitle(context, "电台列表"),
          const Divider(),
          const _FeedList()
        ],
      ),
    );
  }
}

class _FeedListBar extends StatelessWidget {
  const _FeedListBar();
  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: const Text("播客电台"),
    );
  }
}

class _LatestUpdated extends StatelessWidget {
  const _LatestUpdated();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: pagePadding,
      child: const _LastestEntries(),
    );
  }
}

class _LastestEntries extends StatefulWidget {
  const _LastestEntries();
  @override
  _LastestEntriesState createState() => _LastestEntriesState();
}

class _LastestEntriesState<_LastestEntries> extends State {
  Future<List<Entry>> getLastestEntries() async {
    SearchCondition sc = SearchCondition();
    sc.keyword = "*";
    sc.from = 0;
    sc.size = 3;
    Dio dio = Dio();
    dio.options.baseUrl = "http://localhost/api/";

    Response v = await dio.post("search",
        data: jsonEncode(sc),
        options: Options(headers: {
          "responseType": ResponseType.json,
        }));

    return (v.data as List<dynamic>).map((e) => Entry.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    var entries = getLastestEntries();
    return Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14.0))),
        child: FutureBuilder(
          future: entries,
          builder: (BuildContext context, AsyncSnapshot<List<Entry>> snapshot) {
            if (snapshot.hasData) {
              List<Entry> entries = snapshot.data!;
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: entries.length,
                  itemBuilder: (context, index) =>
                      _LastestEntryItem(entries, index));
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}

class _LastestEntryItem extends StatelessWidget {
  const _LastestEntryItem(this.itemList, this.index, {Key? key})
      : super(key: key);
  final int index;
  final List<Entry> itemList;

  @override
  Widget build(BuildContext context) {
    Entry entry = itemList[index];
    return Padding(
      padding: inlinePadding,
      child: createBriefLine(context, entry),
    );
  }

  createBriefLine(BuildContext context, Entry entry) {
    EntryNotifier notifier = context.watch<EntryNotifier>();
    SearchConditionNotifier scNotifier =
        context.watch<SearchConditionNotifier>();
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Row(children: [
        Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image(
                  height: 20,
                  width: 30,
                  image: NetworkImage(
                      "http://localhost/image?url=${entry.image}")),
            )),
        Expanded(
          flex: 7,
          child: Text(
            entry.title,
            style: Theme.of(context).textTheme.bodyText1,
            // overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 2,
          child: IconButton(
            // hoverColor: Colors.transparent,
            color: Colors.grey,
            icon: const Icon(
              Icons.play_circle,
            ),
            onPressed: () {
              notifier.entry = entry;
              scNotifier.search("feed_title", "最近更新");
              Navigator.pushReplacementNamed(context, '/play');
            },
          ),
        ),
      ]),
      if (index < itemList.length - 1) const Divider()
    ]);
  }
}

class _FeedList extends StatefulWidget {
  const _FeedList();
  @override
  _FeedListState createState() => _FeedListState();
}

class _FeedListState<_FeedList> extends State {
  Future<List<Feed>> getFeeds() async {
    Dio dio = Dio();
    dio.options.baseUrl = "http://localhost/api/";

    Response v = await dio.get("feeds");
    List<Feed> list = [];
    list.addAll(
        (v.data as List<dynamic>).map((e) => Feed.fromJson(e)).toList());

    return list;
  }

  @override
  Widget build(BuildContext context) {
    SearchConditionNotifier notifier = context.watch<SearchConditionNotifier>();
    var feeds = getFeeds();
    return FutureBuilder(
      future: feeds,
      builder: (BuildContext context, AsyncSnapshot<List<Feed>> snapshot) {
        if (snapshot.hasData) {
          List<Feed> feeds = snapshot.data!;
          return Container(
              child: Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: feeds.length,
                itemBuilder: (context, index) =>
                    _FeedItem(feeds, index, notifier)),
          ));
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class _FeedItem extends StatelessWidget {
  const _FeedItem(this.itemList, this.index, this.notifier, {Key? key})
      : super(key: key);
  final int index;
  final List<Feed> itemList;
  final SearchConditionNotifier notifier;

  Widget createCard(context, feed) {
    return Container(
        padding: cardPadding,
        // color: const Color(0xFFEEEEEE),
        child: Card(
          // elevation: 8.0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14.0))),
          child: Column(
            children: [
              ListTile(
                title: createFirstLine(context, feed),
              ),
              ListTile(
                title: createSummaryLine(context, feed),
              ),
              const Divider(),
              ListTile(
                title: createSecondLine(context, feed),
              ),
            ],
          ),
        ));
  }

  Container createFirstLine(context, feed) {
    return Container(
        alignment: Alignment.centerLeft,
        padding: tagPadding,
        child: Row(
          children: [
            Expanded(
                flex: 3,
                child: Container(
                    alignment: Alignment.centerLeft,
                    child: ClipRRect(
                      // borderRadius: BorderRadius.circular(200),
                      child: Image(
                          height: 50,
                          width: 80,
                          image: NetworkImage(
                              "http://localhost/image?url=${feed.logo}")),
                    ))),
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      feed.title,
                      style: Theme.of(context).textTheme.headline6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  createTagsLine(context, feed)
                ],
              ),
            )
          ],
        ));
  }

  Container createSummaryLine(context, Feed feed) {
    return Container(
        alignment: Alignment.centerLeft,
        child: Text(
          style: Theme.of(context).textTheme.bodyText1,
          plainText(feed.des),
        ));
  }

  List<Widget> createTags(context, List<String> tags) {
    List<Widget> widgets = [];
    for (int i = 0; i < tags.length; i++) {
      if (i < 2) {
        widgets.add(TextButton(
            onPressed: () {
              notifier.search("term", tags[i]);
              Navigator.pushReplacementNamed(context, '/entry');
            },
            child: Text(
              tags[i].trim(),
              style: Theme.of(context).textTheme.bodySmall,
            )));
      }
    }
    return widgets;
  }

  Container createTagsLine(context, Feed feed) {
    return Container(
        // color: Colors.amber,
        padding: tagPadding,
        alignment: Alignment.bottomLeft,
        child: Row(
          children: createTags(context, feed.tags),
        ));
  }

  Container createSecondLine(context, feed) {
    return Container(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                style: Theme.of(context).textTheme.bodyText2,
                "最近更新于 ${feed.lastUpdated}",
              ),
            ),
            Expanded(
                child: Container(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.east),
                onPressed: () {
                  notifier.search("feed_title", feed.title);
                  Navigator.pushReplacementNamed(context, '/entry');
                },
              ),
            ))
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    Feed feed = itemList[index];

    return Padding(
        padding: pagePadding,
        child: Column(
          children: [LimitedBox(child: createCard(context, feed))],
        ));
  }
}
