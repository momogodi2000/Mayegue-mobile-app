import 'package:flutter/material.dart';

class TraductionPage extends StatelessWidget {
  const TraductionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Traduction")),
      body: const Center(child: Text("Outil de traduction")),
    );
  }
}
