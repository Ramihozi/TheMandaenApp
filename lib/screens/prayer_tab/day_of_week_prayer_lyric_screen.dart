import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DayOfWeekPrayerLyricScreen extends StatefulWidget {
  final String currentDay;

  const DayOfWeekPrayerLyricScreen({Key? key, required this.currentDay}) : super(key: key);

  @override
  _DayOfWeekPrayerLyricScreenState createState() =>
      _DayOfWeekPrayerLyricScreenState();
}

class _DayOfWeekPrayerLyricScreenState extends State<DayOfWeekPrayerLyricScreen> {
  late List<Map<String, dynamic>> _prayerLyrics = [];
  int currentIndex = 0;
  Set<int> highlightedIndices = {}; // Track highlighted lyrics
  Timer? _timer;
  late ScrollController _scrollController;
  final Map<int, GlobalKey> _itemKeys = {};
  bool isPlaying = false;
  int currentTime = 0;
  late int totalDuration = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadPrayerLyrics();
  }

  Future<void> _loadPrayerLyrics() async {
    // Determine the filename based on the current day
    final String dayFile = widget.currentDay.toLowerCase() + '.json';

    // Load the corresponding prayer file for the day
    try {
      final String data = await rootBundle.loadString('assets/prayers/$dayFile');
      List<dynamic> jsonResult = json.decode(data);

      setState(() {
        _prayerLyrics = jsonResult.cast<Map<String, dynamic>>();
        for (int i = 0; i < _prayerLyrics.length; i++) {
          _itemKeys[i] = GlobalKey();
        }
        totalDuration = _prayerLyrics.isNotEmpty ? _prayerLyrics.last["time"] : 0;
        if (_prayerLyrics.isNotEmpty) {
          highlightedIndices.add(0); // Ensure the first lyric starts highlighted
        }
      });
    } catch (error) {
      print("Error loading JSON: $error");
    }
  }

  void _startTimer() {
    if (_prayerLyrics.isEmpty || isPlaying || totalDuration <= 0) return;

    setState(() {
      isPlaying = true;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (currentTime >= totalDuration) {
          timer.cancel();
          isPlaying = false;
        } else {
          int newIndex = _findCurrentIndex(currentTime);
          if (newIndex != currentIndex) {
            currentIndex = newIndex;
            highlightedIndices.add(currentIndex);
            _scrollToCurrentIndex();
          }
          currentTime++;
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      isPlaying = false;
    });
  }

  void _scrollToCurrentIndex() {
    final key = _itemKeys[currentIndex];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: Duration(milliseconds: 300),
        alignment: 0.5,
        curve: Curves.easeInOut,
      );
    }
  }

  int _findCurrentIndex(int time) {
    for (int i = 0; i < _prayerLyrics.length; i++) {
      int startTime = _prayerLyrics[i]["time"];
      int endTime = (i + 1 < _prayerLyrics.length) ? _prayerLyrics[i + 1]["time"] : startTime + 3;
      if (time >= startTime && time < endTime) {
        return i;
      }
    }
    return _prayerLyrics.length - 1; // Default to the last lyric
  }

  void _onSliderChanged(double value) {
    _pauseTimer();

    setState(() {
      currentTime = value.toInt();
      int newIndex = _findCurrentIndex(currentTime);

      // Update the current index and highlighted indices
      currentIndex = newIndex;
      highlightedIndices = {for (int i = 0; i <= currentIndex; i++) i}; // Highlight all up to the current index
    });

    _scrollToCurrentIndex();
  }

  void _onPlayPausePressed() {
    if (isPlaying) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_prayerLyrics.isEmpty) {
      return Scaffold(
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Back Button
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            // Lyrics List with Persistent Highlighting
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 0),
                itemCount: _prayerLyrics.length,
                itemBuilder: (context, index) {
                  bool isHighlighted = highlightedIndices.contains(index);
                  return AnimatedOpacity(
                    key: _itemKeys[index],
                    opacity: isHighlighted ? 1.0 : 0.5,
                    duration: Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        _prayerLyrics[index]["text"] ?? 'No text available',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                          color: isHighlighted ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Playback Controls
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Slider(
                    value: currentTime.toDouble(),
                    min: 0,
                    max: totalDuration > 0 ? totalDuration.toDouble() : 1,
                    onChanged: totalDuration > 0 ? _onSliderChanged : null,
                    activeColor: Colors.black,
                    inactiveColor: Colors.grey,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(currentTime)),
                      IconButton(
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 32),
                        onPressed: _onPlayPausePressed,
                      ),
                      Text(_formatDuration(totalDuration)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
