import 'package:flutter/material.dart';

class GinzaScreen extends StatefulWidget {
  const GinzaScreen({super.key});

  @override
  State<GinzaScreen> createState() => _GinzaScreenState();
}

class _GinzaScreenState extends State<GinzaScreen> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
        child: Scaffold(
          body: Center(child: Text('Ginza'),),
        ));
  }
}
