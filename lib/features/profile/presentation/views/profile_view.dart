import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilPage extends StatefulWidget {
  final String nomUtilisateur;

  const ProfilPage({super.key, required this.nomUtilisateur});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  bool _dataSavingMode = false;

  @override
  void initState() {
    super.initState();
    _loadDataSavingMode();
  }

  Future<void> _loadDataSavingMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dataSavingMode = prefs.getBool('dataSavingMode') ?? false;
    });
  }

  Future<void> _saveDataSavingMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dataSavingMode', value);
    setState(() {
      _dataSavingMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Profil"),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 Bandeau supérieur
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 55,
                    backgroundImage: NetworkImage(
                      "https://cdn-icons-png.flaticon.com/512/1946/1946429.png",
                    ),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.nomUtilisateur,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Apprenant inscrit depuis 2025",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () {
                      // 👉 Ouvrir la page Modifier Profil
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ModifierProfilPage(
                              nomUtilisateur: widget.nomUtilisateur),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text("Modifier le profil"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 🔹 Infos utilisateur
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildInfoCard(Icons.person, "Nom", widget.nomUtilisateur),
                  _buildInfoCard(Icons.email, "Email", "exemple@email.com"),
                  _buildInfoCard(Icons.lock, "Mot de passe", "********"),
                  _buildInfoCard(Icons.calendar_today, "Date d'inscription",
                      "11 Septembre 2025"),
                ],
              ),
            ),

            // 🔹 Settings section
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Paramètres",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text("Mode économie de données"),
                      subtitle: const Text(
                          "Réduit la consommation de données en désactivant certaines fonctionnalités"),
                      value: _dataSavingMode,
                      onChanged: (value) => _saveDataSavingMode(value),
                      activeColor: Colors.green.shade700,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 🔹 Bouton flottant
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 👉 Ici, tu mets la fonction déconnexion
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Déconnexion réussie ✅")),
          );
        },
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text("Déconnexion"),
        backgroundColor: Colors.red.shade400,
      ),
    );
  }

  // 🔹 Widget réutilisable pour les cartes d'infos
  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(icon, color: Colors.green.shade700),
        ),
        title: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87)),
        subtitle: Text(value,
            style: const TextStyle(color: Colors.black54, fontSize: 14)),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 16, color: Colors.grey.shade400),
      ),
    );
  }
}

// 🔹 Nouvelle page : Modifier Profil
class ModifierProfilPage extends StatefulWidget {
  final String nomUtilisateur;

  const ModifierProfilPage({super.key, required this.nomUtilisateur});

  @override
  State<ModifierProfilPage> createState() => _ModifierProfilPageState();
}

class _ModifierProfilPageState extends State<ModifierProfilPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.nomUtilisateur);
    _emailController = TextEditingController(text: "exemple@email.com");
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier le profil"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔹 Photo de profil
              const Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        "https://cdn-icons-png.flaticon.com/512/1946/1946429.png",
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 🔹 Champ Nom
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(
                  labelText: "Nom",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              // 🔹 Champ Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              // 🔹 Champ Mot de passe
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Mot de passe",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              // 🔹 Bouton Sauvegarder
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Profil mis à jour avec succès ✅")),
                      );
                      Navigator.pop(context); // Retour vers ProfilPage
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Enregistrer",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
