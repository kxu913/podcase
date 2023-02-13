import 'package:crawler/constants/constants.dart';
import 'package:crawler/domain/entry.dart';

import 'package:crawler/notifier/entry_notifier.dart';

import 'package:crawler/notifier/search_condition_notifier.dart';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:provider/provider.dart';

class Entries extends StatelessWidget {
  const Entries({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFEEEEEE),
        body: Column(children: const [_EntryBar(), EntriesBody()]));
  }
}

class _EntryBar extends StatelessWidget {
  const _EntryBar();
  @override
  Widget build(BuildContext context) {
    SearchConditionNotifier notifier = context.watch<SearchConditionNotifier>();
    return AppBar(
      // color: Colors.lightBlueAccent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pushReplacementNamed(context, '/'),
      ),
      title: Text(notifier.sc.keyword),
    );
  }
}

class EntriesBody extends StatefulWidget {
  const EntriesBody({super.key});

  @override
  State<EntriesBody> createState() => _EntriesState();
}

class _EntriesState extends State<EntriesBody> {
  Future<List<Entry>> getMoreEntries(SearchConditionNotifier notifier) async {
    return notifier.entries;
  }

  @override
  Widget build(BuildContext context) {
    SearchConditionNotifier notifier = context.watch<SearchConditionNotifier>();

    var entries = getMoreEntries(notifier);

    return FutureBuilder(
      future: entries,
      builder: (BuildContext context, AsyncSnapshot<List<Entry>> snapshot) {
        if (snapshot.hasData) {
          List<Entry> entries = snapshot.data!;

          return Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: entries.length,
                  itemBuilder: (context, index) => EntryItem(entries, index)));
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

class EntryItem extends StatelessWidget {
  const EntryItem(this.itemList, this.index, {Key? key}) : super(key: key);
  final int index;
  final List<Entry> itemList;

  @override
  Widget build(BuildContext context) {
    Entry entry = itemList[index];
    return Container(
        padding: cardPadding,
        child: Card(
          // elevation: 2.0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0))),
          child: Column(
            children: [
              ListTile(
                title: createFirstLine(context, entry),
              ),
              const Divider(),
              ListTile(
                title: createSecondLine(context, entry),
              ),
            ],
          ),
        ));
  }

  createFirstLine(BuildContext context, Entry entry) {
    return Container(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image(
                  height: 50,
                  width: 80,
                  image: NetworkImage(
                      "http://localhost/image?url=${entry.image}")),
            ),
            Expanded(
                child: Text(
              entry.title,
              style: Theme.of(context).textTheme.headline6,
              overflow: TextOverflow.visible,
            ))
          ],
        ));
  }

  createSecondLine(BuildContext context, Entry entry) {
    EntryNotifier notifier = context.watch<EntryNotifier>();
    return Container(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                style: Theme.of(context).textTheme.bodyText2,
                "发布于 ${entry.publishAt}",
              ),
            ),
            Expanded(
                child: Container(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(
                  Icons.play_circle_filled_outlined,
                ),
                onPressed: () {
                  notifier.entry = entry;
                  Navigator.pushReplacementNamed(context, '/play');
                },
              ),
            ))
          ],
        ));
  }
}
