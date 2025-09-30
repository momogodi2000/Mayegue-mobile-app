# Documentation d'Architecture - Mayegue App

## Vue d'Ensemble

L'application Mayegue suit une architecture moderne basée sur les principes de **Clean Architecture** et le pattern **MVVM (Model-View-ViewModel)**. Cette approche garantit une séparation claire des responsabilités, une testabilité élevée et une maintenabilité à long terme.

## 🏗️ Principes Architecturaux

### Clean Architecture
L'application est structurée en couches concentriques, chaque couche ayant des responsabilités spécifiques :

```
┌─────────────────────────────────────┐
│          Presentation Layer         │  ← Vues, ViewModels
├─────────────────────────────────────┤
│          Domain Layer               │  ← Use Cases, Entities
├─────────────────────────────────────┤
│          Data Layer                 │  ← Repositories, Data Sources
├─────────────────────────────────────┤
│          Infrastructure Layer       │  ← Frameworks, Drivers
└─────────────────────────────────────┘
```

#### Avantages
- **Indépendance des frameworks** : Le code métier ne dépend pas des frameworks externes
- **Testabilité** : Chaque couche peut être testée isolément
- **Maintenabilité** : Modifications localisées dans leur couche
- **Évolutivité** : Ajout de nouvelles fonctionnalités sans impact sur l'existant

## 📱 Pattern MVVM (Model-View-ViewModel)

### Structure du Pattern

```
View (UI) ←→ ViewModel ←→ Model (Data)
    ↑              ↑
    └── Binding ───┘
```

#### View (Vue)
- **Responsabilités** : Affichage des données, gestion des interactions utilisateur
- **Technologies** : Widgets Flutter, Material Design
- **Exemples** : `LoginView`, `DashboardView`, `DictionaryView`

#### ViewModel
- **Responsabilités** : Logique de présentation, gestion d'état, coordination
- **Technologies** : Provider pour la gestion d'état
- **Exemples** : `AuthViewModel`, `LessonViewModel`, `PaymentViewModel`

#### Model
- **Responsabilités** : Données métier, logique de domaine
- **Technologies** : Entities, Use Cases, Repositories
- **Exemples** : `User`, `Lesson`, `DictionaryEntry`

### Communication
- **View → ViewModel** : Événements utilisateur, appels de méthodes
- **ViewModel → View** : Notifications de changement via `ChangeNotifier`
- **ViewModel → Model** : Appels aux Use Cases et Repositories

## 🗂️ Structure des Dossiers

### Core Layer (`lib/core/`)
```
core/
├── config/           # Configuration globale
│   ├── constants/    # Constantes de l'application
│   ├── environment_config.dart  # Gestion des variables d'environnement
│   └── routes.dart   # Définition des routes
├── errors/           # Gestion d'erreurs
│   ├── exceptions.dart
│   └── failures.dart
├── network/          # Services réseau
│   ├── api_client.dart
│   └── interceptors.dart
├── payment/          # Intégration paiements
│   ├── campay_service.dart
│   ├── noupai_service.dart
│   └── payment_models.dart
├── router.dart       # Configuration Go Router
├── services/         # Services métier
│   ├── ai_service.dart
│   ├── auth_service.dart
│   └── notification_service.dart
├── usecases/         # Cas d'usage
│   ├── auth_usecases.dart
│   └── payment_usecases.dart
└── utils/            # Utilitaires
    ├── security_utils.dart
    ├── validators.dart
    └── helpers.dart
```

### Features Layer (`lib/features/`)
Chaque feature est un module indépendant contenant :
```
feature_name/
├── data/
│   ├── datasources/    # Sources de données (API, local)
│   ├── models/         # Modèles de données
│   └── repositories/   # Implémentations des repositories
├── domain/
│   ├── entities/       # Entités métier
│   ├── repositories/   # Interfaces des repositories
│   └── usecases/       # Cas d'usage spécifiques
└── presentation/
    ├── viewmodels/     # ViewModels
    ├── views/          # Interfaces utilisateur
    ├── widgets/        # Composants réutilisables
    └── pages/          # Pages complètes
```

## 🔄 Gestion d'État

### Provider Pattern
L'application utilise **Provider** comme solution de gestion d'état :

#### Avantages
- **Simple et léger** : Pas de boilerplate excessif
- **Intégré à Flutter** : Utilise les mécanismes natifs
- **Testable** : Facile à mocker pour les tests
- **Performant** : Reconstruction sélective des widgets

#### Structure des Providers
```dart
class AppProviders {
  static List<SingleChildWidget> getProviders() {
    return [
      // Services globaux
      Provider(create: (_) => AuthService()),
      Provider(create: (_) => ApiClient()),

      // ViewModels
      ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),

      // Repositories
      Provider(create: (_) => UserRepositoryImpl()),
    ];
  }
}
```

#### Utilisation dans les Widgets
```dart
class LoginView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        return Column(
          children: [
            TextField(
              onChanged: viewModel.setEmail,
            ),
            ElevatedButton(
              onPressed: viewModel.isLoading ? null : viewModel.login,
              child: Text(viewModel.isLoading ? 'Connexion...' : 'Se connecter'),
            ),
          ],
        );
      },
    );
  }
}
```

## 🧭 Navigation

### Go Router
L'application utilise **Go Router** pour la navigation type-safe :

#### Configuration
```dart
class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: Routes.splash,
      routes: [
        GoRoute(
          path: Routes.login,
          builder: (context, state) => const LoginView(),
        ),
        // ... autres routes
      ],
      redirect: (context, state) {
        // Logique de redirection basée sur l'état d'authentification
        final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
        if (!authViewModel.isAuthenticated) {
          return Routes.login;
        }
        return null;
      },
    );
  }
}
```

#### Définition des Routes
```dart
class Routes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String languages = '/languages';
  static const String dictionary = '/dictionary';
  // ... autres routes
}
```

#### Navigation Programmatique
```dart
// Navigation simple
context.go(Routes.dashboard);

// Navigation avec paramètres
context.go('/lesson/${lessonId}');

// Navigation avec état
context.go(Routes.payment, extra: selectedPlan);
```

## 🔒 Sécurité

### Architecture de Sécurité
La sécurité est intégrée à tous les niveaux de l'architecture :

#### 1. Niveau Réseau
- **Chiffrement HTTPS** : Tous les appels API utilisent HTTPS
- **Certificats** : Validation des certificats serveur
- **Intercepteurs** : Injection automatique des tokens d'authentification

#### 2. Niveau Application
- **Validation des entrées** : Sanitisation et validation côté client
- **Gestion des sessions** : Tokens JWT avec expiration
- **Stockage sécurisé** : Chiffrement des données sensibles

#### 3. Niveau Données
- **Chiffrement** : Données sensibles chiffrées avec AES-256
- **Hachage** : Mots de passe hachés avec salt
- **Règles Firestore** : Contrôle d'accès basé sur les rôles

### Utilitaires de Sécurité
```dart
class SecurityUtils {
  // Hachage des mots de passe
  static String hashPassword(String password) {
    // Implémentation PBKDF2
  }

  // Chiffrement des données sensibles
  static String encryptData(String data) {
    // Implémentation AES-256
  }

  // Génération de tokens CSRF
  static String generateCsrfToken() {
    // Génération sécurisée
  }
}
```

## 📊 Persistence des Données

### Stratégie Multi-Couches
L'application utilise une approche multi-couches pour la persistence :

#### 1. Cache Local (Hive)
- **Données utilisateur** : Profil, préférences
- **Contenu offline** : Leçons téléchargées
- **État d'application** : Progression, paramètres

#### 2. Base de Données Cloud (Firestore)
- **Données synchronisées** : Progression utilisateur
- **Contenu dynamique** : Leçons, dictionnaire
- **Métadonnées** : Statistiques, analytics

#### 3. Stockage Fichiers (Firebase Storage)
- **Médias** : Audio, vidéos, images
- **Documents** : PDFs, ressources pédagogiques

### Repository Pattern
Chaque entité métier a son repository :
```dart
abstract class UserRepository {
  Future<User> getCurrentUser();
  Future<void> updateProfile(User user);
  Future<List<User>> getUsersByRole(String role);
}

class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource localDataSource;
  final UserRemoteDataSource remoteDataSource;

  @override
  Future<User> getCurrentUser() async {
    // Stratégie cache-first
    try {
      return await localDataSource.getCurrentUser();
    } catch (e) {
      return await remoteDataSource.getCurrentUser();
    }
  }
}
```

## 🔄 Flux de Données

### Pattern Reactive
L'application suit un pattern réactif pour le flux de données :

#### 1. Événements Utilisateur
```
User Action → View → ViewModel → Use Case → Repository → Data Source
```

#### 2. Mise à Jour des Données
```
Data Source → Repository → Use Case → ViewModel → View Update
```

#### 3. Gestion d'État Asynchrone
```dart
class AuthViewModel extends ChangeNotifier {
  AuthState _state = AuthState.initial();

  AuthState get state => _state;

  Future<void> login(String email, String password) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final user = await _loginUseCase.execute(email, password);
      _state = _state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }

    notifyListeners();
  }
}
```

## 🧪 Testabilité

### Architecture Test-Friendly
L'architecture facilite les tests à tous les niveaux :

#### 1. Tests Unitaires
- **Use Cases** : Logique métier isolée
- **ViewModels** : Logique de présentation
- **Utilitaires** : Fonctions pures

#### 2. Tests d'Intégration
- **Repositories** : Intégration avec les data sources
- **Services** : Intégration avec les APIs externes

#### 3. Tests E2E
- **Flux utilisateur complets** : Authentification → Apprentissage → Paiement

### Exemple de Test
```dart
void main() {
  group('AuthViewModel', () {
    late AuthViewModel viewModel;
    late MockAuthUseCase mockUseCase;

    setUp(() {
      mockUseCase = MockAuthUseCase();
      viewModel = AuthViewModel(authUseCase: mockUseCase);
    });

    test('should update state on successful login', () async {
      // Arrange
      when(mockUseCase.login(any, any))
          .thenAnswer((_) async => const User(id: '1', email: 'test@test.com'));

      // Act
      await viewModel.login('test@test.com', 'password');

      // Assert
      expect(viewModel.state.isAuthenticated, true);
      expect(viewModel.state.user?.email, 'test@test.com');
    });
  });
}
```

## 🚀 Performance et Optimisation

### Optimisations Architecturaux

#### 1. Lazy Loading
- **Modules** : Chargement à la demande des features
- **Images** : Cache intelligent avec préchargement
- **Données** : Pagination et chargement progressif

#### 2. Mise en Cache
- **HTTP** : Cache des réponses API
- **Images** : Cache local avec compression
- **Données** : Cache offline avec synchronisation

#### 3. Gestion Mémoire
- **Streams** : Fermeture automatique des abonnements
- **Images** : Libération automatique des ressources
- **Providers** : Scope limité aux widgets nécessitant les données

### Métriques de Performance
- **Temps de démarrage** : < 3 secondes
- **Utilisation mémoire** : < 150 MB
- **Taille bundle** : Optimisée avec tree shaking
- **FPS** : 60 FPS maintenus

## 🔧 Maintenance et Évolution

### Principes d'Évolution
- **Ouverture à l'extension** : Nouveaux modules sans modification existante
- **Fermeture à la modification** : Interfaces stables
- **Séparation des préoccupations** : Chaque classe une responsabilité unique

### Migration et Refactoring
- **Tests comme filet de sécurité** : Couverture > 80%
- **Migration progressive** : Changements incrémentiels
- **Documentation des changements** : Changements breaking clairement documentés

Cette architecture assure que l'application Mayegue reste maintenable, évolutive et performante tout au long de son cycle de vie.