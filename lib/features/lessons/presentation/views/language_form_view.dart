import 'package:flutter/material.dart';
import '../../../games/presentation/views/level_test_view.dart';

class FormulaireLanguePage extends StatelessWidget {
  final String langueChoisie;
  final String nomUtilisateur;
  final String emailUtilisateur;
  final String motDePasse;
  final DateTime dateInscription; // date de début de l'apprentissage

  const FormulaireLanguePage({
    super.key,
    required this.langueChoisie,
    required this.nomUtilisateur,
    required this.emailUtilisateur,
    required this.motDePasse,
    required this.dateInscription,
  });

  bool get estGratuit =>
      DateTime.now().difference(dateInscription).inDays <= 14;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Langue: $langueChoisie"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFD0F8CE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            _buildInfoCard(
              icon: Icons.person,
              title: "Nom",
              value: nomUtilisateur,
              startColor: Colors.greenAccent,
              endColor: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.email,
              title: "Email",
              value: emailUtilisateur,
              startColor: Colors.lightBlueAccent,
              endColor: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              icon: Icons.lock,
              title: "Mot de passe",
              value: "••••••••",
              startColor: Colors.pinkAccent,
              endColor: Colors.redAccent,
            ),
            const SizedBox(height: 20),

            if (!estGratuit) ...[
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Rediriger vers paiement PayPal
                },
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Text("Payer pour continuer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Bouton commencer test
            GestureDetector(
              onTap: estGratuit
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TestNiveauPage(
                            langueChoisie: langueChoisie,
                            nomUtilisateur: nomUtilisateur,
                            emailUtilisateur: emailUtilisateur,
                          ),
                        ),
                      );
                    }
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: estGratuit
                      ? LinearGradient(colors: [
                          Colors.green.shade600,
                          Colors.green.shade800
                        ])
                      : LinearGradient(
                          colors: [Colors.grey.shade400, Colors.grey.shade500]),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "Commencer le test",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: estGratuit ? Colors.white : Colors.black26,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color startColor,
    required Color endColor,
  }) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [startColor, endColor]),
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(2, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "$title: $value",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
