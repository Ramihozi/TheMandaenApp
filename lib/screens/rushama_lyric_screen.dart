import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

class LyricsScreen extends StatefulWidget {
  @override
  _LyricsScreenState createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  List<Map<String, dynamic>> lyrics = [];
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
    _loadLyrics();
  }

  Future<void> _loadLyrics() async {
    try {
      String data = await DefaultAssetBundle.of(context).loadString('assets/prayers/rushama.json');
      List<dynamic> jsonResult = json.decode(data);
      setState(() {
        lyrics = jsonResult.cast<Map<String, dynamic>>();
        for (int i = 0; i < lyrics.length; i++) {
          _itemKeys[i] = GlobalKey();
        }
        totalDuration = lyrics.isNotEmpty ? lyrics.last["time"] : 0;
        if (lyrics.isNotEmpty) {
          highlightedIndices.add(0); // Ensure the first lyric starts highlighted
        }
      });
    } catch (error) {
      print("Error loading JSON: $error");
    }
  }

  void _startTimer() {
    if (lyrics.isEmpty || isPlaying || totalDuration <= 0) return;

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
    for (int i = 0; i < lyrics.length; i++) {
      int startTime = lyrics[i]["time"];
      int endTime = (i + 1 < lyrics.length) ? lyrics[i + 1]["time"] : startTime + 3;
      if (time >= startTime && time < endTime) {
        return i;
      }
    }
    return lyrics.length - 1; // Default to the last lyric
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.brown[100],
        body: SafeArea(
          child: Column(
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
                child: lyrics.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: lyrics.length,
                  itemBuilder: (context, index) {
                    bool isHighlighted = highlightedIndices.contains(index);
                    return AnimatedOpacity(
                      key: _itemKeys[index],
                      opacity: isHighlighted ? 1.0 : 0.5,
                      duration: Duration(milliseconds: 300),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          lyrics[index]["text"],
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
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
