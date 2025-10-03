# Ma'a yegue - Guide Complet en Français

## Table des Matières

1. [Introduction](#introduction)
2. [Guide Utilisateur](#guide-utilisateur)
3. [Guide Développeur](#guide-développeur)
4. [Architecture](#architecture)
5. [Configuration](#configuration)
6. [Déploiement](#déploiement)

---

## Introduction

**Ma'a yegue** est une application mobile d'apprentissage des langues traditionnelles camerounaises. Elle permet aux utilisateurs d'apprendre six langues principales : Ewondo, Duala, Fe'efe'e (Bafang), Fulfulde, Bassa, et Bamum.

### Objectifs
- Préserver les langues traditionnelles camerounaises
- Faciliter l'apprentissage interactif avec IA
- Créer une communauté d'apprenants et d'enseignants
- Offrir un accès hors ligne aux contenus

### Technologies
- **Framework**: Flutter 3.8+
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Base de données locale**: SQLite
- **État**: Provider
- **Navigation**: GoRouter

---

## Guide Utilisateur

### Types d'Utilisateurs

#### 1. Visiteur (Guest)
**Accès:**
- Page d'accueil avec démonstrations
- Leçons démo limitées
- Dictionnaire en lecture seule (limité)
- Exploration des 6 langues

**Actions disponibles:**
- Voir les fonctionnalités
- Essayer les démos
- S'inscrire pour un compte

**Limitations:**
- Pas d'accès aux leçons complètes
- Pas de sauvegarde de progression
- Pas d'IA conversationnelle
- Pas de communauté

#### 2. Apprenant (Learner/Student) - PAR DÉFAUT
**Accès:**
- Toutes les leçons (selon abonnement)
- Dictionnaire complet
- Évaluations et quiz
- IA assistant personnel
- Jeux éducatifs
- Communauté
- Mode hors ligne

**Actions disponibles:**
- Suivre des cours
- Consulter le dictionnaire
- Passer des évaluations
- Participer à la communauté
- Utiliser l'IA pour pratiquer
- Suivre sa progression

**Abonnements:**
- **Gratuit**: 3 langues, leçons de base
- **Premium (2500 FCFA/mois)**: Tout inclus

#### 3. Enseignant (Teacher/Instructor)
**Accès:**
- Tout l'accès apprenant
- Création de leçons
- Ajout d'entrées au dictionnaire
- Création d'évaluations
- Tableau de bord enseignant
- Statistiques des élèves
- Modération de contenu

**Actions disponibles:**
- Créer et gérer des leçons
- Ajouter/modifier le dictionnaire
- Créer des quiz
- Voir les progrès des élèves
- Modérer la communauté

#### 4. Administrateur (Admin)
**Accès:**
- Tous les privilèges
- Gestion des utilisateurs
- Configuration système
- Gestion des paiements
- Modération globale
- Analytiques complètes

**Actions disponibles:**
- Gérer tous les utilisateurs
- Promouvoir/rétrograder des rôles
- Modérer tout le contenu
- Voir les statistiques globales
- Configurer l'application
- Gérer les paiements

### Inscription et Connexion

#### Méthodes d'inscription:
1. **Email et mot de passe**
   - Entrez votre email
   - Créez un mot de passe (min. 8 caractères)
   - Vérifiez votre email

2. **Google OAuth**
   - Cliquez sur "Continuer avec Google"
   - Sélectionnez votre compte Google
   - Autorisez l'application

3. **Facebook** (si activé)
   - Cliquez sur "Continuer avec Facebook"
   - Connectez-vous à Facebook
   - Autorisez l'application

4. **Numéro de téléphone**
   - Entrez votre numéro
   - Recevez et entrez le code OTP
   - Complétez votre profil

#### Authentification à deux facteurs (2FA)

**Activation:**
1. Allez dans Paramètres > Sécurité
2. Activez "Authentification à deux facteurs"
3. Choisissez votre méthode (Email ou SMS)
4. Générez des codes de secours

**Connexion avec 2FA:**
1. Entrez email/mot de passe
2. Recevez un code OTP
3. Entrez le code dans les 10 minutes
4. Accédez à votre tableau de bord

**Codes de secours:**
- 10 codes générés à l'activation
- Utilisables une seule fois
- À conserver en lieu sûr

### Utilisation de l'Application

#### Leçons
1. **Parcourir les cours**
   - Sélectionnez une langue
   - Choisissez votre niveau
   - Commencez une leçon

2. **Types de leçons**
   - Vocabulaire
   - Grammaire
   - Prononciation
   - Conversation
   - Culture

3. **Progression**
   - Points d'expérience (XP)
   - Badges
   - Niveaux
   - Séries de connexion

#### Dictionnaire
1. **Recherche**
   - Français → Langue locale
   - Langue locale → Français
   - Recherche vocale

2. **Fonctionnalités**
   - Prononciation audio
   - Exemples d'utilisation
   - Catégories de mots
   - Favoris

3. **Contribution** (Enseignants uniquement)
   - Ajouter de nouveaux mots
   - Suggérer des corrections
   - Ajouter des exemples

#### IA Assistant
1. **Conversation**
   - Pratiquez en temps réel
   - Correction de prononciation
   - Suggestions contextuelles

2. **Fonctionnalités**
   - Reconnaissance vocale
   - Synthèse vocale
   - Traduction instantanée
   - Suggestions personnalisées

#### Jeux Éducatifs
1. **Types de jeux**
   - Cartes mémoire
   - Quiz interactifs
   - Associations de mots
   - Défis quotidiens

2. **Multijoueur**
   - Défier d'autres apprenants
   - Classements
   - Tournois

### Abonnements et Paiements

#### Plans disponibles:
1. **Gratuit**
   - 3 langues (Ewondo, Duala, Bafang)
   - Leçons de base
   - Dictionnaire limité
   - Publicités

2. **Premium - 2500 FCFA/mois**
   - 6 langues
   - Toutes les leçons
   - Dictionnaire complet
   - IA conversationnelle
   - Sans publicité
   - Mode hors ligne
   - Priorité support

#### Méthodes de paiement:

1. **Mobile Money (Cameroun)**
   - **CamPay** (Primaire)
     - MTN Mobile Money
     - Orange Money
   - **Noupia** (Alternatif)
     - Autres opérateurs

2. **Carte bancaire (International)**
   - **Stripe**
     - Visa, Mastercard, Amex
     - Paiement sécurisé 3D Secure

#### Processus de paiement:
1. Sélectionnez un plan
2. Choisissez la méthode de paiement
3. Entrez les informations
4. Confirmez le paiement
5. Accès immédiat aux fonctionnalités

#### Gestion d'abonnement:
- Voir l'historique des paiements
- Renouveler l'abonnement
- Annuler à tout moment
- Demander un remboursement (7 jours)

---

## Guide Développeur

### Prérequis

#### Logiciels requis:
- Flutter SDK 3.8+
- Dart 3.0+
- Android Studio / VS Code
- Git
- Firebase CLI
- Python 3.x (pour scripts)

#### Comptes nécessaires:
- Compte Firebase
- Compte CamPay (paiements Cameroun)
- Compte Stripe (paiements internationaux)
- Compte Google Cloud (pour AI)

### Installation

```bash
# Cloner le repository
git clone https://github.com/votre-org/mayegue.git
cd mayegue

# Installer les dépendances
flutter pub get

# Configurer Firebase
flutterfire configure

# Générer les fichiers de localisation
flutter gen-l10n

# Créer la base de données locale
cd docs/database-scripts
python create_cameroon_db.py
cd ../..
```

### Configuration

#### 1. Fichier .env

Créez un fichier `.env` à la racine du projet:

```env
# Firebase (optionnel, déjà dans firebase_options.dart)
FIREBASE_API_KEY=
FIREBASE_PROJECT_ID=

# Gemini AI
GEMINI_API_KEY=votre_cle_gemini

# CamPay (Cameroun)
CAMPAY_API_KEY=votre_cle_campay
CAMPAY_SECRET=votre_secret_campay
CAMPAY_WEBHOOK_SECRET=votre_webhook_secret

# Noupia (Alternatif)
NOUPAI_API_KEY=votre_cle_noupai
NOUPAI_WEBHOOK_SECRET=votre_webhook_secret

# Stripe (International)
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Admin par défaut
DEFAULT_ADMIN_EMAIL=admin@mayegue.app
DEFAULT_ADMIN_PASSWORD=MotDePasseSecurise123!
DEFAULT_ADMIN_NAME=Administrateur

# Configuration
APP_ENV=development
```

#### 2. Firebase

1. **Créer un projet Firebase**
   - Allez sur https://console.firebase.google.com
   - Créez un nouveau projet
   - Activez les services:
     - Authentication (Email, Google, Phone)
     - Firestore Database
     - Storage
     - Cloud Functions
     - Cloud Messaging

2. **Configurer les règles Firestore**
   - Déployez `firestore.rules`
   ```bash
   firebase deploy --only firestore:rules
   ```

3. **Configurer les index Firestore**
   - Déployez `firestore.indexes.json`
   ```bash
   firebase deploy --only firestore:indexes
   ```

4. **Créer l'admin par défaut**
   - Au premier lancement, l'app créera automatiquement l'admin
   - Ou exécutez manuellement via l'interface admin

#### 3. APIs Externes

**CamPay:**
1. Inscrivez-vous sur https://www.campay.net
2. Obtenez vos clés API
3. Configurez les webhooks
4. Ajoutez les clés dans `.env`

**Stripe:**
1. Inscrivez-vous sur https://dashboard.stripe.com
2. Obtenez vos clés de test
3. Configurez les webhooks
4. Ajoutez les clés dans `.env`

**Gemini AI:**
1. Allez sur https://makersuite.google.com
2. Créez une clé API
3. Ajoutez dans `.env`

### Structure du Projet

```
lib/
├── core/                  # Code partagé
│   ├── config/           # Configuration (env, payment)
│   ├── constants/        # Constantes (routes, etc.)
│   ├── models/           # Modèles communs (user_role)
│   ├── network/          # Client HTTP (Dio)
│   ├── router.dart       # Navigation (GoRouter)
│   └── services/         # Services globaux
│       ├── firebase_service.dart
│       ├── admin_setup_service.dart
│       └── two_factor_auth_service.dart
├── features/             # Fonctionnalités par domaine
│   ├── authentication/   # Connexion, inscription
│   ├── lessons/          # Leçons
│   ├── dictionary/       # Dictionnaire
│   ├── games/            # Jeux
│   ├── payment/          # Paiements
│   ├── admin/            # Administration
│   ├── guest/            # Interface visiteur
│   └── ...
├── shared/               # Widgets/Providers partagés
│   ├── providers/
│   ├── themes/
│   └── widgets/
├── l10n/                 # Internationalisation
└── main.dart             # Point d'entrée

assets/
├── databases/            # SQLite databases
├── firebase/             # Seeds Firebase
└── logo/                 # Assets graphiques

docs/                     # Documentation
├── GUIDE_COMPLET_FR.md
├── ARCHITECTURE_FR.md
└── ...
```

### Commandes Utiles

```bash
# Lancer en dev
flutter run

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Analyser le code
flutter analyze

# Tester
flutter test

# Générer les traductions
flutter gen-l10n

# Clean
flutter clean && flutter pub get
```

### Tests

```bash
# Tests unitaires
flutter test test/unit/

# Tests d'intégration
flutter test integration_test/

# Tests spécifiques
flutter test test/features/authentication/
```

---

## Architecture

### Clean Architecture

L'application suit les principes de Clean Architecture:

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│   (Views, ViewModels, Widgets)      │
└────────────┬────────────────────────┘
             │
┌────────────▼────────────────────────┐
│          Domain Layer               │
│  (Entities, UseCases, Repositories) │
└────────────┬────────────────────────┘
             │
┌────────────▼────────────────────────┐
│           Data Layer                │
│ (Models, DataSources, Repositories) │
└─────────────────────────────────────┘
```

#### Avantages:
- Séparation des préoccupations
- Testabilité
- Maintenabilité
- Indépendance des frameworks

### State Management

**Provider** est utilisé pour la gestion d'état:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthViewModel(...)),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    // ...
  ],
  child: MyApp(),
)
```

### Navigation

**GoRouter** gère la navigation avec:
- Routes nommées
- Redirection basée sur l'authentification
- Redirection basée sur le rôle
- Deep linking

### Base de Données

1. **Firebase Firestore** (Cloud)
   - Données utilisateurs
   - Leçons dynamiques
   - Paiements
   - Analytics

2. **SQLite** (Local)
   - Dictionnaire de base
   - Cache hors ligne
   - Données des visiteurs

---

## Configuration

### Variables d'Environnement

Voir `ENV_TEMPLATE.md` pour la liste complète.

### Feature Flags

Activez/désactivez des fonctionnalités:

```env
ENABLE_2FA=true
ENABLE_GOOGLE_AUTH=true
ENABLE_FACEBOOK_AUTH=false
ENABLE_AI_ASSISTANT=true
```

### Thèmes

L'app supporte 3 modes:
- Clair
- Sombre
- Système (automatique)

Configuration dans `lib/shared/themes/`

---

## Déploiement

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (Play Store)
flutter build appbundle --release

# Localisation
ls build/app/outputs/flutter-apk/
ls build/app/outputs/bundle/release/
```

### Configuration Firestore

```bash
# Déployer les règles
firebase deploy --only firestore:rules

# Déployer les index
firebase deploy --only firestore:indexes
```

### Cloud Functions (optionnel)

```bash
cd functions
npm install
firebase deploy --only functions
```

---

## Support

Pour toute question:
- **Email**: support@mayegue.app
- **Documentation**: https://docs.mayegue.app
- **GitHub**: https://github.com/votre-org/mayegue

---

© 2025 Ma'a yegue. Tous droits réservés.

