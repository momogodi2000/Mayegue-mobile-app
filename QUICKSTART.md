# Mayègue - Quick Start Guide

## 🎯 What is Mayègue?

Mayègue is a Flutter mobile application dedicated to learning traditional Cameroonian languages including Ewondo, Bafang, and other local languages. The app features:

- 📚 Interactive lessons and courses
- 📖 Multilingual dictionary (French, English, Ewondo, Bafang)
- 🎮 Educational games
- 📝 Quizzes and assessments
- 👥 Community features
- 💳 Subscription management
- 📱 Offline support
- 🤖 AI-powered assistance

---

## 🚀 Quick Start (5 Minutes)

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Android Studio / VS Code
- Git

### 1. Clone & Setup
```bash
# Clone the repository
git clone [your-repo-url]
cd Mayegue

# Get dependencies
flutter pub get

# Generate launcher icons
flutter pub run flutter_launcher_icons
```

### 2. Configure Environment
```bash
# Copy the example environment file
cp .env.example .env

# Edit .env and add your API keys (optional for testing)
# The app will work without API keys, but some features will be limited
```

### 3. Run the App
```bash
# Connect your device or start an emulator

# Run in debug mode
flutter run

# Or build APK
flutter build apk --debug
```

**That's it!** The app should launch on your device.

---

## ✅ Critical Fixes Applied (October 1, 2025)

### 1. Provider Dependency Injection ✅ FIXED
- **Issue:** App crashed with red screen on launch
- **Error:** `ProviderNotFoundException: Could not find Provider<OnboardingRepository>`
- **Fix:** Reordered providers in dependency injection hierarchy

### 2. Logo & Splash Screen ✅ FIXED
- Logo now displays correctly
- Launcher icons generated for Android/iOS

### 3. Navigation Flow ✅ FIXED
- Splash (3s) → Terms & Conditions → Dashboard
- No more stuck on blank screen

### 4. User Guides ✅ IMPLEMENTED
- Admin, Teacher, and Student guides accessible from dashboard menus

---

## 📱 App Navigation Flow

### First Launch
```
Splash Screen (3 seconds)
    ↓
Terms & Conditions (must accept)
    ↓
Landing Page
    ↓
Login / Register
    ↓
Role-Based Dashboard
```

### User Roles & Dashboards
- **Admin** → `/admin-dashboard` - Full system management
- **Teacher** → `/teacher-dashboard` - Content creation, student management
- **Student** → `/dashboard` - Learning interface

---

## 🔑 Configuration (Optional)

### Firebase (Required for Auth & Cloud Features)
The app uses Firebase. Configuration is auto-generated in `lib/firebase_options.dart`.

If you need to reconfigure:
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

### API Keys (Optional - Add to `.env`)
```bash
# Gemini AI (for AI features)
GEMINI_API_KEY=your_key

# Payment Gateways (for subscription features)
CAMPAY_API_KEY=your_key
CAMPAY_SECRET=your_secret
NOUPAI_API_KEY=your_key
```

**Note:** The app will work without these keys, but some features (AI assistant, payments) will be disabled.

---

## 🧪 Testing

### Run Tests
```bash
# All tests
flutter test

# Integration tests
flutter test integration_test/

# Specific test file
flutter test test/features/authentication/auth_viewmodel_test.dart
```

### Test Accounts (for development)
Create test accounts in Firebase Console or register in-app.

---

## 🏗️ Project Structure

```
lib/
├── main.dart                      # App entry point
├── core/                          # Core utilities
│   ├── config/                    # Environment config
│   ├── constants/                 # App constants
│   ├── database/                  # Local database
│   ├── network/                   # API clients
│   ├── router.dart                # Navigation
│   └── services/                  # Core services
├── features/                      # Features (Clean Architecture)
│   ├── authentication/            # Auth (login, register, etc.)
│   ├── dashboard/                 # Role-based dashboards
│   ├── dictionary/                # Multilingual dictionary
│   ├── games/                     # Educational games
│   ├── guides/                    # User guides
│   ├── lessons/                   # Course content
│   ├── onboarding/                # Splash, terms, onboarding
│   ├── payment/                   # Subscriptions & payments
│   └── ...
└── shared/                        # Shared widgets, themes
    ├── providers/                 # Provider configuration
    ├── themes/                    # App themes
    └── widgets/                   # Reusable widgets
```

---

## 📚 Documentation

- **[FIXES_SUMMARY.md](FIXES_SUMMARY.md)** - Detailed list of all fixes applied
- **[DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)** - Production deployment guide
- **[.env.example](.env.example)** - Environment variables template

---

## 🐛 Troubleshooting

### Issue: App crashes on launch
**Solution:** Delete the app and reinstall. The provider hierarchy fix requires a fresh install.

### Issue: "No Firebase App" error
**Solution:** Ensure `flutterfire configure` has been run and `firebase_options.dart` exists.

### Issue: Logo not showing
**Solution:** Run `flutter pub run flutter_launcher_icons` to regenerate icons.

### Issue: Build fails
**Solution:**
```bash
flutter clean
flutter pub get
flutter pub run flutter_launcher_icons
flutter build apk --debug
```

### Issue: Provider errors
**Solution:** Hot-restart the app (not hot-reload). Provider changes require full restart.

---

## 🚀 Build for Production

### Android (APK)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android (App Bundle for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (macOS required)
```bash
flutter build ios --release
# Then archive in Xcode
```

---

## 📦 Key Dependencies

- **State Management:** Provider
- **Navigation:** go_router
- **Backend:** Firebase (Auth, Firestore, Storage, etc.)
- **Local Database:** SQLite (sqflite)
- **Payments:** CamPay & NouPai
- **AI:** Gemini AI
- **Localization:** flutter_localizations (French/English)

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## 📞 Support

- **Email:** support@mayegue.com
- **Technical Issues:** admin@mayegue.com

---

## 📄 License

[Add your license here]

---

**Version:** 1.0.0+1
**Last Updated:** October 1, 2025
**Status:** ✅ Production Ready (after API keys configured)

---

## 🎉 Ready to Go!

Your Mayègue app is now configured and ready for development or deployment!

```bash
# Run it now!
flutter run
```

Happy coding! 🚀
