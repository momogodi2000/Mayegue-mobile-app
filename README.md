# Mayegue - Application d'Apprentissage des Langues Camerounaises

## 🌍 À Propos de l'Application

**Mayegue** est une application mobile innovante dédiée à l'apprentissage et à la préservation des langues traditionnelles camerounaises. Développée avec Flutter, elle offre une expérience d'apprentissage immersive combinant intelligence artificielle, gamification et paiements mobiles africains.

### Mission
Préserver et promouvoir les langues traditionnelles camerounaises en rendant l'apprentissage accessible à tous grâce aux technologies modernes.

### Langues Supportées
- **Ewondo** (Beti-Pahuin) - Région Centre
- **Duala** (Bantu côtier) - Littoral commercial
- **Bafang/Fe'efe'e** (Grassfields) - Hauts-plateaux Ouest
- **Fulfulde** (Niger-Congo) - Nord pastoral
- **Bassa** (A40 Bantu) - Centre-Littoral traditionnel
- **Bamum** (Grassfields) - Patrimoine culturel Ouest

## 🚀 Fonctionnalités Principales

### 📚 Apprentissage Intelligent
- **Leçons structurées** : Contenu progressif du débutant à l'avancé
- **IA intégrée** : Assistant conversationnel Gemini spécialisé dans les langues camerounaises
- **Contenu multimédia** : Audio, vidéo et exercices interactifs
- **Prononciation guidée** : Guides phonétiques IPA et exemples culturels

### 🎮 Gamification Avancée
- **Système de badges** : 8 niveaux de progression culturelle
- **Réalisations** : 10 succès spécifiques au Cameroun
- **Classements** : Compétition sociale motivante
- **Système de niveaux** : 10 niveaux avec noms camerounais significatifs

### 💳 Paiements Mobiles Africains
- **CamPay** : Passerelle principale pour Mobile Money camerounais (MTN, Orange)
- **NouPai** : Passerelle secondaire pour redondance
- **Plans d'abonnement** : Freemium, Premium mensuel/annuel, plans enseignants
- **Transactions sécurisées** : Validation webhook et suivi des transactions

### 👥 Gestion des Utilisateurs
- **Rôles multiples** : Apprenant, Enseignant, Administrateur
- **Authentification multi-fournisseurs** : Email, Google, Facebook, Apple, téléphone
- **Tableaux de bord personnalisés** : Interface adaptée à chaque rôle
- **Suivi de progression** : Analytics détaillés des apprentissages

### 🌐 Fonctionnalités Communautaires
- **Forums de discussion** : Échanges entre apprenants
- **Système de mentorat** : Connexion enseignants-élèves
- **Profils utilisateurs** : Gestion des informations personnelles
- **Contenu généré par les utilisateurs** : Insights culturels communautaires

## 🏗️ Architecture du Projet

### Structure des Dossiers
```
lib/
├── core/                    # Noyau de l'application
│   ├── config/             # Configuration (environnement, constantes)
│   ├── errors/             # Gestion d'erreurs
│   ├── network/            # Services réseau
│   ├── payment/            # Intégration paiements
│   ├── router.dart         # Configuration de navigation
│   ├── services/           # Services métier
│   ├── usecases/           # Cas d'usage
│   └── utils/              # Utilitaires (sécurité, validation)
├── features/               # Modules fonctionnels
│   ├── authentication/     # Authentification utilisateurs
│   ├── dashboard/          # Tableaux de bord
│   ├── dictionary/         # Dictionnaire interactif
│   ├── lessons/            # Système de leçons
│   ├── languages/          # Gestion des langues
│   ├── ai/                 # Intégration IA
│   ├── gamification/       # Système de récompenses
│   ├── payment/            # Gestion des paiements
│   ├── community/          # Fonctionnalités sociales
│   ├── assessment/         # Évaluations
│   ├── games/              # Jeux éducatifs
│   ├── profile/            # Gestion des profils
│   ├── resources/          # Ressources pédagogiques
│   ├── translation/        # Services de traduction
│   ├── onboarding/         # Intégration utilisateurs
│   └── admin/              # Administration
├── shared/                 # Composants partagés
├── l10n/                   # Internationalisation
└── main.dart              # Point d'entrée
```

### Technologies Utilisées

#### Frontend
- **Flutter** : Framework cross-platform
- **Dart** : Langage de programmation
- **Provider** : Gestion d'état
- **Go Router** : Navigation type-safe
- **Material Design** : Interface utilisateur

#### Backend & Services
- **Firebase** : Suite complète (Auth, Firestore, Storage, Functions, Analytics)
- **Gemini AI** : Assistant conversationnel intelligent
- **CamPay/NouPai** : Passerelles de paiement mobile
- **Hive** : Stockage local
- **Dio** : Client HTTP

#### Sécurité & Performance
- **Cryptographie** : Chiffrement des données sensibles
- **Validation** : Sanitisation et validation des entrées
- **Rate Limiting** : Protection contre les abus
- **Cache intelligent** : Optimisation des performances

## 📋 Prérequis

- **Flutter SDK** : >= 3.0.0
- **Dart SDK** : >= 3.0.0
- **Android Studio** / **VS Code** : Environnement de développement
- **Firebase CLI** : Pour le déploiement
- **Git** : Gestion de version

## 🛠️ Installation et Configuration

### 1. Clonage du Projet
```bash
git clone https://github.com/momogodi2000/mayegue.git
cd mayegue-app
```

### 2. Installation des Dépendances
```bash
flutter pub get
```

### 3. Configuration des Variables d'Environnement

Copiez le fichier d'exemple et configurez vos clés API :

```bash
cp .env.example .env
```

Éditez `.env` avec vos vraies clés API :

```env
# Firebase (obligatoire)
FIREBASE_API_KEY=votre_clé_api_firebase
FIREBASE_PROJECT_ID=votre_id_projet_firebase
FIREBASE_APP_ID=votre_app_id_firebase

# IA Gemini (obligatoire pour les fonctionnalités IA)
GEMINI_API_KEY=votre_clé_gemini_ai

# Paiements (au moins une passerelle requise)
CAMPAY_API_KEY=votre_clé_campay
CAMPAY_SECRET=votre_secret_campay
CAMPAY_ENVIRONMENT=sandbox  # ou production

NOUPAI_API_KEY=votre_clé_noupai
NOUPAI_SECRET=votre_secret_noupai

# Autres configurations
APP_ENVIRONMENT=development  # development, staging, production
```

### 4. Configuration Firebase

#### Création du Projet Firebase
1. Accédez à [Firebase Console](https://console.firebase.google.com/)
2. Créez un nouveau projet "mayegue-app"
3. Activez les services requis :
   - **Authentication** : Email/Password, Google, Facebook, Apple, Phone
   - **Firestore** : Base de données NoSQL
   - **Storage** : Stockage de fichiers
   - **Functions** : Fonctions serverless (optionnel)
   - **Messaging** : Notifications push
   - **Analytics** : Suivi d'utilisation

#### Configuration Mobile
4. Ajoutez une application Android :
   - Package name : `com.mayegue.app`
   - Téléchargez `google-services.json` dans `android/app/`
5. Ajoutez une application iOS :
   - Bundle ID : `com.mayegue.app`
   - Téléchargez `GoogleService-Info.plist` dans `ios/Runner/`

### 5. Importation des Données de Base

Importez les données de seed dans Firestore :

```bash
# Via Firebase Console ou CLI
firebase firestore:import firebase_seed_data.json --project votre-projet-id
firebase firestore:import enhanced_dictionary_seed.json --project votre-projet-id
firebase firestore:import lesson_seed_data.json --project votre-projet-id
firebase firestore:import gamification_seed_data.json --project votre-projet-id
```

### 6. Configuration des Règles de Sécurité

Déployez les règles Firestore :

```bash
firebase deploy --only firestore:rules --project votre-projet-id
```

### 7. Génération des Ressources
```bash
# Icônes d'application
flutter pub run flutter_launcher_icons:main

# Localisations
flutter gen-l10n

# Build des assets
flutter pub run build_runner build
```

## 🚀 Lancement de l'Application

### Développement
```bash
# Android
flutter run --device-id android-device-id

# iOS (macOS uniquement)
flutter run --device-id ios-device-id

# Web
flutter run -d chrome
```

### Build Production

#### Android
```bash
# APK
flutter build apk --release

# Bundle (recommandé)
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

## 🧪 Tests et Qualité

### Tests Unitaires
```bash
flutter test
```

### Tests d'Intégration
```bash
flutter test integration_test/
```

### Analyse de Code
```bash
flutter analyze
```

### Formatage
```bash
dart format lib/
```

## 📱 Déploiement

### App Store (iOS)
1. Créez un compte développeur Apple
2. Préparez les assets (icônes, screenshots)
3. Soumettez via Xcode ou Transporter

### Google Play (Android)
1. Créez un compte développeur Google Play
2. Préparez les assets et métadonnées
3. Soumettez l'APK/AAB via Play Console

### Web
1. Configurez Firebase Hosting
2. Déployez les fichiers build :
```bash
firebase deploy --only hosting --project votre-projet-id
```

## 🔧 Scripts Utiles

### Seed des Données
```bash
# Exécution des scripts de seed
dart run scripts/seed_languages.dart
dart run scripts/seed_dictionary.dart
```

### Génération de Code
```bash
# Génération des localisations
flutter gen-l10n

# Build des assets
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📊 Métriques et KPIs

### Métriques Techniques
- **Performance** : Temps de chargement < 3 secondes
- **Taux de crash** : < 0,1%
- **Succès des paiements** : > 95%
- **Réponse IA** : < 2 secondes

### Métriques Métier
- **Utilisateurs actifs** : 1 000 MAU en 3 mois
- **Taux de rétention** : > 60% à 30 jours
- **Conversion** : > 15% freemium vers premium
- **Impact culturel** : Préservation de 6 langues traditionnelles

## 🤝 Contribution

Nous accueillons les contributions ! Voici comment participer :

### Processus de Contribution
1. Fork le projet
2. Créez une branche feature : `git checkout -b feature/NouvelleFonctionnalite`
3. Committez vos changements : `git commit -m 'Ajout de NouvelleFonctionnalite'`
4. Pushez vers la branche : `git push origin feature/NouvelleFonctionnalite`
5. Ouvrez une Pull Request

### Guidelines
- Respectez l'architecture MVVM et Clean Architecture
- Ajoutez des tests pour les nouvelles fonctionnalités
- Documentez votre code
- Suivez les conventions de nommage Dart/Flutter

## 📄 Licence

Ce projet est sous licence MIT - voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 👥 Équipe et Contact

### Équipe de Développement
- **Développement** : Équipe Mayegue
- **Design UI/UX** : Designers camerounais
- **IA** : Intégration Gemini AI
- **Paiements** : Intégration CamPay & NouPai

### Support
- **Email** : support@mayegue.app
- **Documentation** : [docs/](docs/)
- **Issues** : [GitHub Issues](https://github.com/momogodi2000/mayegue/issues)

## 🌍 Impact et Vision

### Impact Culturel
- **Préservation linguistique** : Sauvegarde du patrimoine camerounais
- **Éducation accessible** : Apprentissage pour tous, partout
- **Communauté globale** : Connexion de la diaspora camerounaise

### Vision Future
- **Expansion régionale** : Autres langues africaines
- **Partenariats éducatifs** : Écoles et universités
- **Collaboration gouvernementale** : Ministères de la culture
- **Marchés internationaux** : Diaspora mondiale

---

**🎯 Statut : Prêt pour le lancement de production 🚀**

*Application Mayegue - Préservons nos langues traditionnelles ensemble*

*Date : 25 septembre 2025*
