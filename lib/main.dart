import 'package:flutter/material.dart';

void main() {
  runApp(const SeniorEaseApp());
}

class SeniorEaseApp extends StatelessWidget {
  const SeniorEaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Senior Ease',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const Scaffold(
        body: Center(child: Text('Senior Ease')),
      ),
    );
  }
}
