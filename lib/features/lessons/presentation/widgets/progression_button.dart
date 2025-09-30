import 'package:flutter/material.dart';
import '../views/courses_view.dart';
import '../views/catalogue_view.dart';

class ProgressionButton extends StatelessWidget {
  final bool allChecked;
  final String niveau;
  final String langueChoisie;
  final String nomUtilisateur;
  final String emailUtilisateur;
  final String motDePasse;
  final DateTime dateInscription;

  const ProgressionButton({
    super.key,
    required this.allChecked,
    required this.niveau,
    required this.langueChoisie,
    required this.nomUtilisateur,
    required this.emailUtilisateur,
    required this.motDePasse,
    required this.dateInscription,
  });

  String? niveauSuivant() {
    switch (niveau) {
      case "Débutant":
        return "Intermédiaire";
      case "Intermédiaire":
        return "Avancé";
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!allChecked) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade700,
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        onPressed: () {
          final prochain = niveauSuivant();
          if (prochain != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const CoursesView(),
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("🎉 Félicitations !"),
                  content: const Text(
                      "Vous avez terminé tous les niveaux pour cette langue."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CataloguePage(
                              nomUtilisateur: nomUtilisateur,
                              emailUtilisateur: emailUtilisateur,
                              motDePasse: motDePasse,
                              dateInscription: dateInscription,
                            ),
                          ),
                        );
                      },
                      child: const Text("Retour au catalogue"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Revoir les leçons"),
                    ),
                  ],
                );
              },
            );
          }
        },
        child: const Text(
          "Passer au niveau suivant",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
