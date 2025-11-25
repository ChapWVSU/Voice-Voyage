import 'package:flutter/material.dart';

class BasicGreetingsPage extends StatelessWidget {
  const BasicGreetingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Greetings')),
      body: const Center(child: Text('Basic Greetings Page')),
    );
  }
}
