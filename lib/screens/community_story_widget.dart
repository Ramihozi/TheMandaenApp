import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoryWidget extends StatefulWidget {
  const StoryWidget({
    super.key,
    required this.image,
    required this.name,
    required this.onTap, required double size,
  });

  final String name;
  final String image;
  final VoidCallback onTap;

  @override
  _StoryWidgetState createState() => _StoryWidgetState();
}

class _StoryWidgetState extends State<StoryWidget> {
  bool _isViewed = false;

  @override
  void initState() {
    super.initState();
    _loadViewedState();
  }

  Future<void> _loadViewedState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isViewed = prefs.getBool(widget.name) ?? false; // Use name as the key
    });
  }

  Future<void> _saveViewedState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(widget.name, true); // Save the viewed state
  }

  void _handleTap() {
    setState(() {
      _isViewed = true;
    });
    _saveViewedState(); // Save the state when viewed
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(0.1),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isViewed ? Colors.grey : Colors.amber,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: Image.network(
                  widget.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              widget.name,
              style: TextStyle(
                color: Colors.black.withOpacity(.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
