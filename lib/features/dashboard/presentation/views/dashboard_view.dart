import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../../../authentication/presentation/viewmodels/auth_viewmodel.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthViewModel, DashboardViewModel>(
      builder: (context, authViewModel, dashboardViewModel, child) {
        final dashboardData = dashboardViewModel.getDashboardData();
        final isGuest = dashboardData['isGuest'] ?? false;

        return Scaffold(
          appBar: AppBar(
            title: Text(dashboardData['title']),
            backgroundColor: Colors.green,
            actions: [
              if (!isGuest) ...[
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () => context.go('/notifications'),
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => context.go('/settings'),
                ),
              ] else ...[
                IconButton(
                  icon: const Icon(Icons.login),
                  onPressed: () => context.go('/login'),
                ),
                IconButton(
                  icon: const Icon(Icons.person_add),
                  onPressed: () => context.go('/register'),
                ),
              ],
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.green, Colors.teal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dashboardData['welcomeMessage'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dashboardData['subtitle'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stats cards
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: dashboardData['stats'].length,
                    itemBuilder: (context, index) {
                      final stat = dashboardData['stats'][index];
                      return Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(stat['icon'], color: stat['color'], size: 24),
                            const SizedBox(height: 8),
                            Text(
                              stat['value'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              stat['label'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Quick actions
                const Text(
                  'Actions rapides',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: dashboardData['quickActions'].length,
                    itemBuilder: (context, index) {
                      final action = dashboardData['quickActions'][index];
                      return Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () => context.go(action['route']),
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: Icon(action['icon'],
                                    color: Colors.green, size: 28),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                action['label'],
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Guest upgrade prompt or recent activity
                if (isGuest) ...[
                  // Guest upgrade section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Débloquez tout le potentiel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Créez un compte pour accéder à toutes les fonctionnalités',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context)
                                    .pushNamed('/register'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.orange,
                                ),
                                child: const Text('S\'inscrire'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    Navigator.of(context).pushNamed('/login'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white),
                                ),
                                child: const Text('Se connecter'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Guest limitations info
                  const Text(
                    'Fonctionnalités en mode invité',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildFeatureLimitCard(
                          icon: Icons.translate,
                          title: 'Dictionnaire limité',
                          description: '25 mots par session',
                          isAvailable: true,
                        ),
                        _buildFeatureLimitCard(
                          icon: Icons.menu_book,
                          title: 'Leçons de démonstration',
                          description: '3 leçons gratuites',
                          isAvailable: true,
                        ),
                        _buildFeatureLimitCard(
                          icon: Icons.videogame_asset,
                          title: 'Mini-jeux',
                          description: 'Jeux de base seulement',
                          isAvailable: true,
                        ),
                        _buildFeatureLimitCard(
                          icon: Icons.bookmark,
                          title: 'Sauvegarde progression',
                          description: 'Compte requis',
                          isAvailable: false,
                        ),
                        _buildFeatureLimitCard(
                          icon: Icons.forum,
                          title: 'Communauté complète',
                          description: 'Compte requis',
                          isAvailable: false,
                        ),
                        _buildFeatureLimitCard(
                          icon: Icons.smart_toy,
                          title: 'IA personnalisée',
                          description: 'Compte requis',
                          isAvailable: false,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Regular user recent activity
                  const Text(
                    'Activité récente',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: dashboardData['recentActivity'].length,
                      itemBuilder: (context, index) {
                        final activity = dashboardData['recentActivity'][index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                activity['color'].withValues(alpha: 25),
                            child: Icon(activity['icon'],
                                color: activity['color']),
                          ),
                          title: Text(activity['title']),
                          subtitle: Text(activity['subtitle']),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          drawer: _DashboardDrawer(isGuest: isGuest),
        );
      },
    );
  }

  Widget _buildFeatureLimitCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isAvailable,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isAvailable ? Colors.green.shade100 : Colors.grey.shade100,
          child: Icon(
            icon,
            color: isAvailable ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isAvailable ? Colors.black : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: isAvailable ? Colors.grey : Colors.grey.shade500,
          ),
        ),
        trailing: Icon(
          isAvailable ? Icons.check_circle : Icons.lock,
          color: isAvailable ? Colors.green : Colors.grey,
        ),
      ),
    );
  }
}

class _DashboardDrawer extends StatelessWidget {
  final bool isGuest;

  const _DashboardDrawer({required this.isGuest});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final user = authViewModel.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (isGuest)
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.green, size: 32),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mode Invité',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Fonctionnalités limitées',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/register'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                          ),
                          child: const Text('S\'inscrire'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.green),
              accountName: Text(user?.displayName ?? 'Utilisateur'),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user?.photoUrl != null
                    ? NetworkImage(user!.photoUrl!)
                    : const AssetImage('assets/images/default_avatar.png')
                        as ImageProvider,
              ),
            ),
          // Dashboard access for all
          const ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Tableau de bord'),
            onTap: null, // TODO: Implement navigation
          ),

          if (isGuest) ...[
            // Guest menu items
            const ListTile(
              leading: Icon(Icons.explore),
              title: Text('Explorer'),
              subtitle: Text('Découvrir les langues'),
              onTap: null, // TODO: Implement navigation
            ),
            const ListTile(
              leading: Icon(Icons.translate),
              title: Text('Dictionnaire'),
              subtitle: Text('Limité à 25 mots'),
              onTap: null, // TODO: Implement navigation
            ),
            const ListTile(
              leading: Icon(Icons.menu_book),
              title: Text('Leçons démo'),
              subtitle: Text('3 leçons gratuites'),
              onTap: null, // TODO: Implement navigation
            ),
            ListTile(
              leading: const Icon(Icons.videogame_asset),
              title: const Text('Mini-jeux'),
              subtitle: const Text('Jeux de base'),
              onTap: () => Navigator.of(context).pushNamed('/guest-games'),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('À propos'),
              onTap: () => Navigator.of(context).pushNamed('/about'),
            ),

            // Upgrade prompts
            ListTile(
              leading: const Icon(Icons.star, color: Colors.orange),
              title: const Text('Débloquer tout'),
              subtitle: const Text('Créer un compte'),
              onTap: () => Navigator.of(context).pushNamed('/register'),
            ),
            ListTile(
              leading: const Icon(Icons.login, color: Colors.green),
              title: const Text('Se connecter'),
              onTap: () => Navigator.of(context).pushNamed('/login'),
            ),

            // Restricted features (grayed out)
            const ListTile(
              leading: Icon(Icons.bookmark, color: Colors.grey),
              title: Text('Favoris', style: TextStyle(color: Colors.grey)),
              subtitle:
                  Text('Compte requis', style: TextStyle(color: Colors.grey)),
              enabled: false,
            ),
            const ListTile(
              leading: Icon(Icons.forum, color: Colors.grey),
              title: Text('Communauté', style: TextStyle(color: Colors.grey)),
              subtitle:
                  Text('Compte requis', style: TextStyle(color: Colors.grey)),
              enabled: false,
            ),
            const ListTile(
              leading: Icon(Icons.smart_toy, color: Colors.grey),
              title: Text('IA Assistant', style: TextStyle(color: Colors.grey)),
              subtitle:
                  Text('Compte requis', style: TextStyle(color: Colors.grey)),
              enabled: false,
            ),
          ] else ...[
            // Authenticated user menu items
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Leçons'),
              onTap: () => Navigator.of(context).pushNamed('/courses'),
            ),
            ListTile(
              leading: const Icon(Icons.translate),
              title: const Text('Dictionnaire'),
              onTap: () => Navigator.of(context).pushNamed('/dictionary'),
            ),
            ListTile(
              leading: const Icon(Icons.videogame_asset),
              title: const Text('Jeux'),
              onTap: () => Navigator.of(context).pushNamed('/games'),
            ),
            ListTile(
              leading: const Icon(Icons.forum),
              title: const Text('Communauté'),
              onTap: () => context.go('/community'),
            ),
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Évaluations'),
              onTap: () => Navigator.of(context).pushNamed('/assessments'),
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy),
              title: const Text('IA Assistant'),
              onTap: () => Navigator.of(context).pushNamed('/ai-assistant'),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () => Navigator.of(context).pushNamed('/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () => Navigator.of(context).pushNamed('/settings'),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () {
                authViewModel.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ],
      ),
    );
  }
}
