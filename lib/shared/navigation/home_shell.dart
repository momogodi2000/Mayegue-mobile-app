import 'package:flutter/material.dart';
import '../../features/home/presentation/views/home_view.dart';
import '../../features/lessons/presentation/views/catalogue_view.dart';
import '../../features/dashboard/presentation/views/dashboard_view.dart';
import '../../features/community/presentation/views/comments_view.dart';
import '../../features/profile/presentation/views/profile_view.dart';

class HomeShell extends StatefulWidget {
  final String nomUtilisateur;
  final String emailUtilisateur;
  final String motDePasse;
  final DateTime dateInscription;

  const HomeShell({
    super.key,
    required this.nomUtilisateur,
    required this.emailUtilisateur,
    required this.motDePasse,
    required this.dateInscription,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      HomePage(nomUtilisateur: widget.nomUtilisateur),
      CataloguePage(
        nomUtilisateur: widget.nomUtilisateur,
        emailUtilisateur: widget.emailUtilisateur,
        motDePasse: widget.motDePasse,
        dateInscription: widget.dateInscription,
      ),
      const DashboardView(),
      const CommentairesPage(),
      ProfilPage(nomUtilisateur: widget.nomUtilisateur),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Catalogue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.comment),
            label: 'Commentaires',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}