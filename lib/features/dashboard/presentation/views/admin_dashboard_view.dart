import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/supported_languages.dart';
import '../../../../shared/widgets/user_guide_widget.dart';
import '../viewmodels/admin_dashboard_viewmodel.dart';
import '../widgets/admin_stats_widget.dart';
import '../widgets/user_management_widget.dart';
import '../widgets/content_moderation_widget.dart';
import '../widgets/system_health_widget.dart';

/// Dashboard view specifically designed for system administrators
class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadDashboardData() {
    final viewModel = context.read<AdminDashboardViewModel>();
    viewModel.loadAdminDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration Mayegue'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // System alerts
          Consumer<AdminDashboardViewModel>(
            builder: (context, viewModel, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.warning),
                    onPressed: () => _showSystemAlerts(context),
                  ),
                  if (viewModel.alertsCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${viewModel.alertsCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => const <PopupMenuEntry<String>>[
              PopupMenuItem(value: 'backup', child: Text('Sauvegarde')),
              PopupMenuItem(
                value: 'maintenance',
                child: Text('Mode Maintenance'),
              ),
              PopupMenuItem(value: 'logs', child: Text('Journaux Système')),
              PopupMenuItem(value: 'settings', child: Text('Paramètres')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'logout', child: Text('Déconnexion')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Aperçu', icon: Icon(Icons.dashboard, size: 18)),
            Tab(text: 'Utilisateurs', icon: Icon(Icons.people, size: 18)),
            Tab(text: 'Contenu', icon: Icon(Icons.library_books, size: 18)),
            Tab(text: 'Finances', icon: Icon(Icons.account_balance, size: 18)),
            Tab(text: 'Système', icon: Icon(Icons.settings, size: 18)),
            Tab(text: 'Rapports', icon: Icon(Icons.analytics, size: 18)),
          ],
        ),
      ),
      body: Consumer<AdminDashboardViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.hasError) {
            return _buildErrorView(viewModel);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(viewModel),
              _buildUsersTab(viewModel),
              _buildContentTab(viewModel),
              _buildFinancesTab(viewModel),
              _buildSystemTab(viewModel),
              _buildReportsTab(viewModel),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAdminActions(context),
        backgroundColor: Colors.red.shade700,
        icon: const Icon(Icons.admin_panel_settings),
        label: const Text('Actions Admin'),
      ),
    );
  }

  Widget _buildOverviewTab(AdminDashboardViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // System status
          _buildSystemStatusCard(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Key metrics
          AdminStatsWidget(
            totalUsers: viewModel.totalUsers,
            activeUsers: viewModel.activeUsers,
            totalContent: viewModel.totalContent,
            revenue: viewModel.monthlyRevenue,
            systemHealth: viewModel.systemHealth,
          ),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Recent activities
          _buildRecentAdminActivities(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Quick admin actions
          _buildQuickAdminActions(),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Platform statistics
          _buildPlatformStatistics(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // User Guide
          UserGuideWidget(
            role: 'admin',
            title: 'Guide Administrateur',
            sections: UserGuideSections.getAdminGuide(),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(AdminDashboardViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User management tools
          UserManagementWidget(
            totalUsers: viewModel.totalUsers,
            newUsers: viewModel.newUsersToday,
            bannedUsers: viewModel.bannedUsersCount,
            onUserSearch: (query) => viewModel.searchUsers(query),
            onUserFilter: (filter) => viewModel.filterUsers(filter),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),

          // User analytics
          _buildUserAnalyticsCard(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // User roles distribution
          _buildUserRolesCard(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Recent registrations
          _buildRecentRegistrationsCard(viewModel),
        ],
      ),
    );
  }

  Widget _buildContentTab(AdminDashboardViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content moderation
          ContentModerationWidget(
            pendingContent: viewModel.pendingModerationCount,
            reportedContent: viewModel.reportedContentCount,
            onModerateContent: (contentId, action) =>
                viewModel.moderateContent(contentId, action),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Content statistics
          _buildContentStatsCard(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Language content distribution
          _buildLanguageContentCard(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Content quality metrics
          _buildContentQualityCard(viewModel),
        ],
      ),
    );
  }

  Widget _buildFinancesTab(AdminDashboardViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue overview
          _buildRevenueOverviewCard(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Payment methods stats
          _buildPaymentMethodsCard(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Subscription analytics
          _buildSubscriptionAnalyticsCard(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Financial alerts
          _buildFinancialAlertsCard(viewModel),
        ],
      ),
    );
  }

  Widget _buildSystemTab(AdminDashboardViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // System health
          SystemHealthWidget(
            serverStatus: viewModel.serverStatus,
            databaseStatus: viewModel.databaseStatus,
            cacheStatus: viewModel.cacheStatus,
            storageUsage: viewModel.storageUsage,
            onRefreshStatus: () => viewModel.refreshSystemStatus(),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Performance metrics
          _buildPerformanceMetricsCard(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // System configuration
          _buildSystemConfigCard(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Maintenance tools
          _buildMaintenanceToolsCard(viewModel),
        ],
      ),
    );
  }

  Widget _buildReportsTab(AdminDashboardViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report generation
          _buildReportGenerationCard(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Analytics overview
          _buildAnalyticsOverviewCard(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Export options
          _buildExportOptionsCard(viewModel),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Scheduled reports
          _buildScheduledReportsCard(viewModel),
        ],
      ),
    );
  }

  Widget _buildSystemStatusCard(AdminDashboardViewModel viewModel) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: viewModel.systemHealthScore > 0.8
                ? [Colors.green.shade600, Colors.green.shade400]
                : viewModel.systemHealthScore > 0.6
                ? [Colors.orange.shade600, Colors.orange.shade400]
                : [Colors.red.shade600, Colors.red.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'État du Système',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  viewModel.systemHealthScore > 0.8
                      ? Icons.check_circle
                      : viewModel.systemHealthScore > 0.6
                      ? Icons.warning
                      : Icons.error,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Text(
              'Santé Système: ${(viewModel.systemHealthScore * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSmall),
            LinearProgressIndicator(
              value: viewModel.systemHealthScore,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAdminActivities(AdminDashboardViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Activités Administratives',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => _viewAllActivities(context),
                  child: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            ...viewModel.recentAdminActivities
                .take(5)
                .map(
                  (activity) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppDimensions.spacingSmall,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getAdminActivityIcon(activity['type']),
                          color: Colors.red.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.spacingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${activity['admin']} - ${activity['description']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          activity['time'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAdminActions() {
    final actions = [
      {
        'title': 'Modération\nContenu',
        'icon': Icons.content_paste,
        'color': Colors.red,
        'action': () => _moderateContent(context),
      },
      {
        'title': 'Gestion\nUtilisateurs',
        'icon': Icons.people_alt,
        'color': Colors.blue,
        'action': () => _manageUsers(context),
      },
      {
        'title': 'Sauvegarde\nSystème',
        'icon': Icons.backup,
        'color': Colors.green,
        'action': () => _performBackup(context),
      },
      {
        'title': 'Maintenance\nSystème',
        'icon': Icons.build,
        'color': Colors.orange,
        'action': () => _systemMaintenance(context),
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions Administratives',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return InkWell(
                  onTap: action['action'] as VoidCallback,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.borderRadius,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                    decoration: BoxDecoration(
                      color: (action['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.borderRadius,
                      ),
                      border: Border.all(
                        color: (action['color'] as Color).withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          action['icon'] as IconData,
                          color: action['color'] as Color,
                          size: 28,
                        ),
                        const SizedBox(height: AppDimensions.spacingSmall),
                        Text(
                          action['title'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: action['color'] as Color,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformStatistics(AdminDashboardViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques Plateforme',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    'Leçons',
                    viewModel.totalLessons.toString(),
                    Icons.school,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatTile(
                    'Jeux',
                    viewModel.totalGames.toString(),
                    Icons.games,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    'Enseignants',
                    viewModel.totalTeachers.toString(),
                    Icons.person,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatTile(
                    'Langues',
                    SupportedLanguages.languageCodes.length.toString(),
                    Icons.language,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.spacingSmall / 2),
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppDimensions.spacingSmall / 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserAnalyticsCard(AdminDashboardViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytiques Utilisateurs',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacingLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildUserMetric(
                  'Nouveaux\nAujourd\'hui',
                  viewModel.newUsersToday.toString(),
                  Colors.green,
                  Icons.person_add,
                ),
                _buildUserMetric(
                  'Actifs\nCette semaine',
                  viewModel.weeklyActiveUsers.toString(),
                  Colors.blue,
                  Icons.trending_up,
                ),
                _buildUserMetric(
                  'Taux de\nRétention',
                  '${viewModel.retentionRate.toStringAsFixed(1)}%',
                  Colors.orange,
                  Icons.favorite,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserMetric(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingMedium),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: AppDimensions.spacingSmall),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Placeholder widgets for other sections
  Widget _buildUserRolesCard(AdminDashboardViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Répartition des Rôles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Text('Étudiants: ${viewModel.studentsCount}'),
            Text('Enseignants: ${viewModel.teachersCount}'),
            Text('Modérateurs: ${viewModel.moderatorsCount}'),
            Text('Administrateurs: ${viewModel.adminsCount}'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRegistrationsCard(AdminDashboardViewModel viewModel) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inscriptions Récentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppDimensions.spacingMedium),
            Text('Liste des derniers utilisateurs inscrits...'),
          ],
        ),
      ),
    );
  }

  Widget _buildContentStatsCard(AdminDashboardViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques de Contenu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Text('Contenu en attente: ${viewModel.pendingModerationCount}'),
            Text('Contenu signalé: ${viewModel.reportedContentCount}'),
            Text('Contenu total: ${viewModel.totalContent}'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageContentCard(AdminDashboardViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contenu par Langue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            ...SupportedLanguages.languages.entries.map((entry) {
              final info = entry.value;
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.spacingSmall,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${info.flag} ${info.name}'),
                    Text(
                      '${viewModel.getContentCountForLanguage(info.code)} éléments',
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildContentQualityCard(AdminDashboardViewModel viewModel) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Qualité du Contenu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Add quality metrics here
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueOverviewCard(AdminDashboardViewModel viewModel) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aperçu des Revenus',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Text(
              'Revenus mensuels: ${viewModel.monthlyRevenue.toStringAsFixed(0)} FCFA',
            ),
            Text(
              'Revenus annuels: ${viewModel.yearlyRevenue.toStringAsFixed(0)} FCFA',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsCard(AdminDashboardViewModel viewModel) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Méthodes de Paiement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Add payment methods stats here
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionAnalyticsCard(AdminDashboardViewModel viewModel) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analytiques Abonnements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Add subscription analytics here
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialAlertsCard(AdminDashboardViewModel viewModel) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alertes Financières',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Add financial alerts here
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetricsCard(AdminDashboardViewModel viewModel) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Métriques de Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Add performance metrics here
          ],
        ),
      ),
    );
  }

  Widget _buildSystemConfigCard(AdminDashboardViewModel viewModel) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration Système',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Add system configuration here
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceToolsCard(AdminDashboardViewModel viewModel) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Outils de Maintenance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Add maintenance tools here
          ],
        ),
      ),
    );
  }

  Widget _buildReportGenerationCard(AdminDashboardViewModel viewModel) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Génération de Rapports',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Add report generation tools here
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsOverviewCard(AdminDashboardViewModel viewModel) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aperçu Analytique',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Add analytics overview here
          ],
        ),
      ),
    );
  }

  Widget _buildExportOptionsCard(AdminDashboardViewModel viewModel) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Options d\'Export',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Add export options here
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledReportsCard(AdminDashboardViewModel viewModel) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rapports Programmés',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Add scheduled reports here
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(AdminDashboardViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 64),
          const SizedBox(height: AppDimensions.spacingMedium),
          const Text(
            'Erreur du système administratif',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            viewModel.errorMessage ?? 'Erreur inconnue',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: AppDimensions.spacingMedium),
          ElevatedButton(
            onPressed: _loadDashboardData,
            child: const Text('Recharger'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  IconData _getAdminActivityIcon(String type) {
    switch (type) {
      case 'user_banned':
        return Icons.block;
      case 'content_moderated':
        return Icons.content_paste;
      case 'system_backup':
        return Icons.backup;
      case 'config_changed':
        return Icons.settings;
      default:
        return Icons.admin_panel_settings;
    }
  }

  // Action methods (placeholders)
  void _showSystemAlerts(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alertes système - À implémenter')),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Action admin: $action - À implémenter')),
    );
  }

  void _showAdminActions(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Actions administratives - À implémenter')),
    );
  }

  void _viewAllActivities(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Toutes les activités - À implémenter')),
    );
  }

  void _moderateContent(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Modération contenu - À implémenter')),
    );
  }

  void _manageUsers(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gestion utilisateurs - À implémenter')),
    );
  }

  void _performBackup(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sauvegarde système - À implémenter')),
    );
  }

  void _systemMaintenance(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Maintenance système - À implémenter')),
    );
  }
}
