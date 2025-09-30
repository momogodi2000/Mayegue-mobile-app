import 'package:flutter/material.dart';

class TachePage extends StatelessWidget {
  const TachePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mes Tâches"), backgroundColor: Colors.blue),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.book),
            title: Text("Accéder aux leçons"),
          ),
          ListTile(
            leading: Icon(Icons.quiz),
            title: Text("Participer à un quiz"),
          ),
          ListTile(
            leading: Icon(Icons.check_circle),
            title: Text("Faire des exercices"),
          ),
          ListTile(
            leading: Icon(Icons.library_books),
            title: Text("Consulter les ressources"),
          ),
          ListTile(
            leading: Icon(Icons.search),
            title: Text("Rechercher un cours"),
          ),
          ListTile(
            leading: Icon(Icons.trending_up),
            title: Text("Voir ma progression"),
          ),
        ],
      ),
    );
  }
}
