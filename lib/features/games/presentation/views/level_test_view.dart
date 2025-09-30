import 'package:flutter/material.dart';
import '../../../lessons/presentation/views/courses_view.dart';

class TestNiveauPage extends StatefulWidget {
  final String langueChoisie;
  final String nomUtilisateur;
  final String emailUtilisateur;

  const TestNiveauPage({
    super.key,
    required this.langueChoisie,
    required this.nomUtilisateur,
    required this.emailUtilisateur,
  });

  @override
  State<TestNiveauPage> createState() => _TestNiveauPageState();
}

class _TestNiveauPageState extends State<TestNiveauPage> {
  int _currentQuestionIndex = 0;
  late List<Map<String, dynamic>> _questions;
  late List<int> _scores;

  // 🔹 (questions Ewondo et Bafang )

  final List<Map<String, dynamic>> _questionsEwondo = [
    {
      'question': "Comment dit-on 'Bonjour' en Ewondo ?",
      'options': ["Mbembe", "Mbolo", "Seka", "Wambo"],
      'correctIndex': 1,
    },
    {
      'question': "Quel est le mot Ewondo pour 'Merci' ?",
      'options': ["Akeva", "Mbom", "Bita", "Sanga"],
      'correctIndex': 0,
    },
    {
      'question': "En Ewondo, 'Ngul' veut dire :",
      'options': ["Chien", "Arbre", "Feu", "Lune"],
      'correctIndex': 0,
    },
    {
      'question': "En Ewondo, comment dit-on 'Femme' ?",
      'options': ["Ngone", "Mfié", "Mong", "Efa"],
      'correctIndex': 1,
    },
    {
      'question': "En Ewondo, 'Abom' veut dire :",
      'options': ["Arbre", "Chanson", "Pagne", "Livre"],
      'correctIndex': 2,
    },
    {
      'question': "Le mot Ewondo 'Ong' signifie :",
      'options': ["Lune", "Homme", "Rivière", "Soleil"],
      'correctIndex': 1,
    },
    {
      'question': "Que veut dire 'Nsôh' en Ewondo ?",
      'options': ["Chanson", "Ciel", "Pagne", "Main"],
      'correctIndex': 0,
    },
    {
      'question': "Le mot 'Zok' en Ewondo désigne :",
      'options': ["Forêt", "Vent", "Soleil", "Arbre"],
      'correctIndex': 0,
    },
    {
      'question': "Comment dit-on 'Pain' en Ewondo ?",
      'options': ["Mbom", "Pang", "Kum", "Ntsô"],
      'correctIndex': 2,
    },
    {
      'question': "En Ewondo, 'Nseng' veut dire :",
      'options': ["Amour", "Travail", "Joie", "Force"],
      'correctIndex': 3,
    },
  ];

  // 🔹 10 questions Bafang
  final List<Map<String, dynamic>> _questionsBafang = [
    {
      'question': "Dans la langue Bafang, quel mot signifie 'Eau' ?",
      'options': ["Meya", "Ndè", "Nka", "Saa"],
      'correctIndex': 0,
    },
    {
      'question': "Comment traduit-on 'Maison' en Bafang ?",
      'options': ["Ndem", "Nta’a", "Mbam", "Sika"],
      'correctIndex': 1,
    },
    {
      'question': "Quel mot Bafang signifie 'Manger' ?",
      'options': ["Sô", "Kwi", "Tchouo", "Lem"],
      'correctIndex': 2,
    },
    {
      'question': "Le mot Bafang 'Nkou' veut dire :",
      'options': ["Forêt", "Colline", "Soleil", "Chemin"],
      'correctIndex': 2,
    },
    {
      'question': "En Bafang, 'Nda' signifie :",
      'options': ["Maison", "Rivière", "Vent", "Chien"],
      'correctIndex': 0,
    },
    {
      'question': "Le mot 'Fô' en Bafang désigne :",
      'options': ["Chef", "Chien", "Roi", "Femme"],
      'correctIndex': 0,
    },
    {
      'question': "Comment dit-on 'Ami' en Bafang ?",
      'options': ["Nkwem", "Mbo’o", "Tcheu", "Ndop"],
      'correctIndex': 1,
    },
    {
      'question': "Le mot 'Sôh' en Bafang veut dire :",
      'options': ["Chanson", "Amour", "Travail", "Repos"],
      'correctIndex': 2,
    },
    {
      'question': "En Bafang, 'Ngwe' veut dire :",
      'options': ["Feu", "Etoile", "Lait", "Arbre"],
      'correctIndex': 0,
    },
    {
      'question': "Comment traduit-on 'Joie' en Bafang ?",
      'options': ["Samba", "Nyuoh", "Tchié", "Bime"],
      'correctIndex': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.langueChoisie.toLowerCase() == "ewondo") {
      _questions = _questionsEwondo;
    } else {
      _questions = _questionsBafang;
    }
    _scores = List.filled(_questions.length, 0);
  }

  void _answerQuestion(int selectedIndex) {
    if (_currentQuestionIndex < _questions.length) {
      _scores[_currentQuestionIndex] =
          selectedIndex == _questions[_currentQuestionIndex]['correctIndex']
              ? 1
              : 0;

      setState(() {
        _currentQuestionIndex++;
      });

      if (_currentQuestionIndex >= _questions.length) {
        _showResult();
      }
    }
  }

  void _showResult() {
    final totalScore = _scores.reduce((a, b) => a + b);
    String niveau = "Débutant";
    if (totalScore >= 8) {
      niveau = "Avancé";
    } else if (totalScore >= 5) {
      niveau = "Intermédiaire";
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CoursesView(
          langueChoisie: widget.langueChoisie,
          nomUtilisateur: widget.nomUtilisateur,
          emailUtilisateur: widget.emailUtilisateur,
          niveau: niveau,
        ),
      ),
    );
  }

  // ✅ C’est cette méthode qui manquait
  @override
  Widget build(BuildContext context) {
    if (_currentQuestionIndex >= _questions.length) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQ = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.langueChoisie} - Test"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              currentQ['question'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...List.generate(currentQ['options'].length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => _answerQuestion(index),
                  child: Text(
                    currentQ['options'][index],
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            Text(
              "Question ${_currentQuestionIndex + 1} / ${_questions.length}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
