import 'package:flutter/material.dart';
import '../../../../shared/widgets/layouts/app_scaffold.dart';

class RessourcesPage extends StatelessWidget {
  const RessourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimpleScaffold(
      title: "Ressources",
      body: Center(
        child: Text(
          "📚 Liste des ressources pédagogiques",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
