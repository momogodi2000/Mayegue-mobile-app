import 'package:flutter/material.dart';
import 'language_form_view.dart';

class CataloguePage extends StatelessWidget {
  final String nomUtilisateur;
  final String emailUtilisateur;
  final String motDePasse;
  final DateTime dateInscription; // ✅ ajouté

  const CataloguePage({
    super.key,
    required this.nomUtilisateur,
    required this.emailUtilisateur,
    required this.motDePasse,
    required this.dateInscription, // ✅ requis
  });

  @override
  Widget build(BuildContext context) {
    final List<String> langues = [
      "Ewondo",
      "Bafang",
      "Bassa",
      "Douala",
      "Fulfulde"
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Catalogue des langues"),
        backgroundColor: Colors.green.shade700,
        elevation: 5,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFD0F8CE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: langues.length,
          itemBuilder: (context, index) {
            final langue = langues[index];
            final accessible = langue == "Ewondo" || langue == "Bafang";

            return GestureDetector(
              onTap: accessible
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FormulaireLanguePage(
                            langueChoisie: langue,
                            nomUtilisateur: nomUtilisateur,
                            emailUtilisateur: emailUtilisateur,
                            motDePasse: motDePasse,
                            dateInscription: dateInscription,
                          ),
                        ),
                      );
                    }
                  : null,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                elevation: 6,
                child: ListTile(
                  leading: Icon(
                    accessible ? Icons.language : Icons.lock,
                    color: accessible ? Colors.green : Colors.red,
                    size: 35,
                  ),
                  title: Text(
                    langue,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: accessible ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                  trailing: Icon(
                    accessible ? Icons.arrow_forward_ios : Icons.lock_outline,
                    color: accessible ? Colors.green : Colors.red,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
