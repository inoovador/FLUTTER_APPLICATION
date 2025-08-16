import 'package:flutter/material.dart';
import 'inscriptions/inscriptions_list_screen.dart';

class SimpleHomeScreen extends StatelessWidget {
  const SimpleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Torneo App - Inscripciones'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const InscriptionsListScreen(),
    );
  }
}