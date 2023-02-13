import 'dart:convert';

import 'package:crawler/constants/constants.dart';
import 'package:crawler/domain/entry.dart';
import 'package:crawler/domain/feed.dart';
import 'package:crawler/domain/usage.dart';
import 'package:crawler/notifier/search_condition_notifier.dart';
import 'package:crawler/util/textutil.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:crawler/notifier/entry_notifier.dart';
import 'package:provider/provider.dart';

class AudioPlayPage extends StatelessWidget {
  const AudioPlayPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFEEEEEE),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pushReplacementNamed(context, '/entry'),
          ),
          title: const Text("正在播放"),
        ),
        body: Column(
          children: const [_MainPage(), _AudioPlayPage()],
        ));
  }
}

class _MainPage extends StatelessWidget {
  const _MainPage();
  @override
  Widget build(BuildContext context) {
    EntryNotifier notifier = context.watch<EntryNotifier>();
    Entry entry = notifier.entry;

    return Expanded(
        child: Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(top: 20, left: 10),
          child: Text(
            plainText(entry.title),
            style: Theme.of(context).textTheme.headline6,
            softWrap: true,
          ),
        ),
        Container(
          padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
          alignment: Alignment.centerLeft,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.60,
          ),
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(300)),
              image: DecorationImage(
                  // scale: 1,
                  opacity: 0.2,
                  // fit: BoxFit.cover,
                  image: NetworkImage(
                      "http://localhost/image?url=${entry.image}"))),
          child: SingleChildScrollView(
            child: Text(
              plainText(entry.desc),
              style: Theme.of(context).textTheme.bodyText1,
              softWrap: true,
              // overflow: TextOverflow.ellipsis,
            ),
          ),
        )
      ],
    ));
  }
}

class _AudioPlayPage extends StatefulWidget {
  const _AudioPlayPage();
  @override
  _AudioPlayState createState() => _AudioPlayState();
}

class _AudioPlayState extends State<_AudioPlayPage>
    with SingleTickerProviderStateMixin {
  late PlayerMode mode;

  late AudioPlayer _audioPlayer;

  late Duration _duration = Duration.zero;
  late Duration _position = const Duration();
  late StreamSubscription _durationSubscription;
  late StreamSubscription _positionSubscription;
  late StreamSubscription _playerCompleteSubscription;

  // late StreamSubscription _playerErrorSubscription;
  // late StreamSubscription _playerStateSubscription;

  bool isPlaying = false;
  String feedUrl = "";
  List<String> tags = [];

  get _durationText => _duration.toString().split('.').first;
  get _positionText => _position.toString().split('.').first;

  @override
  void initState() {
    super.initState();

    _initAudioPlayer();
  }

  @override
  void dispose() {
    print(feedUrl);
    if (feedUrl != "") {
      _usageTracking(_position.inMilliseconds, feedUrl, tags);
    }

    _audioPlayer.dispose();
    _durationSubscription.cancel();
    _positionSubscription.cancel();
    _playerCompleteSubscription.cancel();
    // _playerErrorSubscription.cancel();
    // _playerStateSubscription.cancel();

    super.dispose();
  }

  @override
  void deactivate() async {
    await _audioPlayer.release();
    super.deactivate();
  }

  _initAudioPlayer() {
    mode = PlayerMode.mediaPlayer;
    _audioPlayer = AudioPlayer()..setPlayerMode(mode);
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription =
        _audioPlayer.onPositionChanged.listen((p) => setState(() {
              _position = p;
            }));

    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _position = const Duration();
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _play(url, _feedUrl, _tags) async {
    tags = _tags;
    feedUrl = _feedUrl;
    final playPosition = (_position > Duration.zero &&
            _duration > Duration.zero &&
            _position.inMilliseconds > 0 &&
            _position.inMilliseconds < _duration.inMilliseconds)
        ? _position
        : null;

    await _audioPlayer.play(UrlSource(url), position: playPosition);

    _audioPlayer.setPlaybackRate(1.0);
  }

  void _pause() async {
    await _audioPlayer.pause();
  }

  _stop() async {
    await _audioPlayer.stop();
    setState(() {
      _position = const Duration();
    });
  }

  @override
  Widget build(BuildContext context) {
    EntryNotifier notifier = context.watch<EntryNotifier>();
    Entry entry = notifier.entry;
    SearchConditionNotifier searchConditionNotifier = context.read();
    List<Entry> entries = searchConditionNotifier.entries;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Stack(
            children: [
              Slider(
                onChanged: (v) {
                  final position = v * _duration.inMilliseconds;
                  _audioPlayer.seek(Duration(milliseconds: position.round()));
                },
                value: (_position > Duration.zero &&
                        _duration > Duration.zero &&
                        _position.inMilliseconds > 0 &&
                        _position.inMilliseconds < _duration.inMilliseconds)
                    ? _position.inMilliseconds / _duration.inMilliseconds
                    : 0.0,
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.only(left: 8),
                child: Text(_positionText),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 8),
                child: Text(_durationText),
              ),
            ),
          ],
        ),
        Container(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                    flex: 8,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(width: 60),
                          IconButton(
                              icon: const Icon(
                                Icons.skip_previous,
                              ),
                              onPressed: () {
                                int index = findEntryIndex(entries, entry);
                                if (index > 1) {
                                  Feed feed = notifier.entry.feed;
                                  _usageTracking(_position.inMilliseconds,
                                      feed.url, feed.tags);

                                  notifier.entry = entries[index - 1];

                                  _play(
                                      notifier.entry.url,
                                      notifier.entry.feed.url,
                                      notifier.entry.feed.tags);

                                  setState(() {
                                    _position = Duration.zero;
                                    isPlaying = true;
                                  });
                                }
                              }),
                          IconButton(
                              iconSize: 60,
                              padding: pagePadding,
                              icon: isPlaying
                                  ? const Icon(
                                      Icons.pause_circle_outline,
                                    )
                                  : const Icon(
                                      Icons.play_circle_outline,
                                    ),
                              onPressed: () {
                                if (isPlaying) {
                                  _pause();
                                } else {
                                  _play(entry.url, entry.feed.url,
                                      entry.feed.tags);
                                }
                                setState(() {
                                  isPlaying = !isPlaying;
                                });
                              }),
                          IconButton(
                              icon: const Icon(
                                Icons.skip_next,
                              ),
                              onPressed: () {
                                int index = findEntryIndex(entries, entry);
                                if (index < entries.length - 1) {
                                  Feed feed = notifier.entry.feed;
                                  _usageTracking(_position.inMilliseconds,
                                      feed.url, feed.tags);
                                  notifier.entry = entries[index + 1];
                                  _play(
                                      notifier.entry.url,
                                      notifier.entry.feed.url,
                                      notifier.entry.feed.tags);

                                  setState(() {
                                    _position = Duration.zero;
                                    isPlaying = true;
                                  });
                                }
                              }),
                        ])),
                Expanded(
                  flex: 2,
                  child: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.menu,
                    ),
                    itemBuilder: (context) {
                      return createMenus(notifier, entries);
                    },
                  ),
                ),
              ],
            )),
      ],
    );
  }

  findEntryIndex(List<Entry> entries, Entry entry) {
    int index = 0;
    for (int i = 0; i < entries.length; i++) {
      Entry e = entries[i];
      if (e.url == entry.url) {
        index = i;
        break;
      }
    }
    return index;
  }

  createMenus(entryNotifier, List<Entry> entries) {
    List<PopupMenuItem<String>> l = [];
    for (int i = 0; i < entries.length; i++) {
      Entry e = entries[i];
      // print(e.title);
      l.add(PopupMenuItem<String>(
        value: e.url,
        child: Text(
          e.title,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: () {
          _stop();
          setState(() {
            isPlaying = false;
          });

          Feed feed = entryNotifier.entry.feed;
          _usageTracking(_position.inMilliseconds, feed.url, feed.tags);
          entryNotifier.entry = e;
          _play(e.url, e.feed.url, e.feed.tags);

          setState(() {
            isPlaying = true;
            _position = Duration.zero;
          });
        },
      ));
    }
    return l;
  }

  _usageTracking(int playTime, String _feedUrl, List<String> _tags) {
    Dio dio = Dio();
    dio.options.baseUrl = "http://localhost:8887/msg/";

    feedUrl = _feedUrl;
    tags = _tags;

    dio.post("usage",
        data: {
          "uid": "kevin",
          "playTime": playTime,
          "tags": tags,
          "feedUrl": feedUrl
        },
        options: Options(headers: {
          "responseType": ResponseType.json,
        }));
  }
}
