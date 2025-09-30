import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/supported_languages.dart';
import '../../../../core/constants/routes.dart';
import '../../../../shared/themes/colors.dart';

/// Language selection view for onboarding process
class LanguageSelectionView extends StatefulWidget {
  const LanguageSelectionView({super.key});

  @override
  State<LanguageSelectionView> createState() => _LanguageSelectionViewState();
}

class _LanguageSelectionViewState extends State<LanguageSelectionView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? _selectedNativeLanguage;
  final Set<String> _selectedLearningLanguages = {};
  int _currentStep = 0; // 0: native, 1: learning languages, 2: confirmation

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _selectNativeLanguage(String languageCode) {
    setState(() {
      _selectedNativeLanguage = languageCode;
    });
  }

  void _toggleLearningLanguage(String languageCode) {
    setState(() {
      if (_selectedLearningLanguages.contains(languageCode)) {
        _selectedLearningLanguages.remove(languageCode);
      } else {
        _selectedLearningLanguages.add(languageCode);
      }
    });
  }

  void _completeOnboarding() {
    // Store user preferences (would typically use SharedPreferences or backend)
    // For now, navigate to authentication
    context.go(Routes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélection des Langues'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / 3,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),

          // Content
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildCurrentStep(),
              ),
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                      child: const Text('Précédent'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canProceed() ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(_getNextButtonText()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildNativeLanguageStep();
      case 1:
        return _buildLearningLanguagesStep();
      case 2:
        return _buildConfirmationStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNativeLanguageStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Quelle est votre langue maternelle ?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sélectionnez la langue que vous parlez couramment. Cela nous aidera à personnaliser votre expérience d\'apprentissage.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                // Add French and English as options
                _buildLanguageCard(
                  'fr',
                  const LanguageInfo(
                    code: 'fr',
                    name: 'Français',
                    nativeName: 'Français',
                    flag: '🇫🇷',
                    region: 'International',
                    speakers: 280000000,
                    difficulty: LanguageDifficulty.intermediate,
                    description: 'Langue officielle du Cameroun',
                    culturalInfo: 'Langue héritée de la colonisation française',
                  ),
                  isSelected: _selectedNativeLanguage == 'fr',
                  onTap: () => _selectNativeLanguage('fr'),
                ),
                const SizedBox(height: 12),
                _buildLanguageCard(
                  'en',
                  const LanguageInfo(
                    code: 'en',
                    name: 'English',
                    nativeName: 'English',
                    flag: '🇬🇧',
                    region: 'International',
                    speakers: 1500000000,
                    difficulty: LanguageDifficulty.intermediate,
                    description: 'Langue officielle du Cameroun',
                    culturalInfo:
                        'Langue héritée de la colonisation britannique',
                  ),
                  isSelected: _selectedNativeLanguage == 'en',
                  onTap: () => _selectNativeLanguage('en'),
                ),
                const SizedBox(height: 24),
                Text(
                  'Langues traditionnelles camerounaises',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: 16),
                ...SupportedLanguages.languages.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildLanguageCard(
                      entry.key,
                      entry.value,
                      isSelected: _selectedNativeLanguage == entry.key,
                      onTap: () => _selectNativeLanguage(entry.key),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningLanguagesStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Quelles langues souhaitez-vous apprendre ?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sélectionnez une ou plusieurs langues traditionnelles camerounaises que vous souhaitez découvrir et apprendre.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                ...SupportedLanguages.languages.entries
                    .where((entry) => entry.key != _selectedNativeLanguage)
                    .map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildLanguageCard(
                      entry.key,
                      entry.value,
                      isSelected:
                          _selectedLearningLanguages.contains(entry.key),
                      onTap: () => _toggleLearningLanguage(entry.key),
                      isMultiSelect: true,
                    ),
                  );
                }),
              ],
            ),
          ),
          if (_selectedLearningLanguages.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_selectedLearningLanguages.length} langue(s) sélectionnée(s). Vous pourrez modifier ce choix plus tard.',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Confirmer vos choix',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Vérifiez vos sélections avant de continuer.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),
          // Native language summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.home, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Langue maternelle',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedNativeLanguage != null) ...[
                    _buildSelectedLanguageSummary(_selectedNativeLanguage!),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Learning languages summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Langues à apprendre',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedLearningLanguages.isNotEmpty) ...[
                    ..._selectedLearningLanguages.map((languageCode) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildSelectedLanguageSummary(languageCode),
                      );
                    }),
                  ] else ...[
                    const Text(
                      'Aucune langue sélectionnée pour l\'apprentissage',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Parfait ! Vous êtes maintenant prêt à commencer votre voyage d\'apprentissage des langues camerounaises.',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(
    String languageCode,
    LanguageInfo info, {
    required bool isSelected,
    required VoidCallback onTap,
    bool isMultiSelect = false,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Text(
                    info.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.primary : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${info.nativeName} • ${info.region}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.difficulty.displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              if (isMultiSelect)
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onTap(),
                  activeColor: AppColors.primary,
                )
              else if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedLanguageSummary(String languageCode) {
    final info = _getLanguageInfo(languageCode);
    if (info == null) return const SizedBox.shrink();

    return Row(
      children: [
        Text(info.flag, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${info.nativeName} • ${info.region}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  LanguageInfo? _getLanguageInfo(String languageCode) {
    if (languageCode == 'fr') {
      return const LanguageInfo(
        code: 'fr',
        name: 'Français',
        nativeName: 'Français',
        flag: '🇫🇷',
        region: 'International',
        speakers: 280000000,
        difficulty: LanguageDifficulty.intermediate,
        description: 'Langue officielle du Cameroun',
        culturalInfo: 'Langue héritée de la colonisation française',
      );
    } else if (languageCode == 'en') {
      return const LanguageInfo(
        code: 'en',
        name: 'English',
        nativeName: 'English',
        flag: '🇬🇧',
        region: 'International',
        speakers: 1500000000,
        difficulty: LanguageDifficulty.intermediate,
        description: 'Langue officielle du Cameroun',
        culturalInfo: 'Langue héritée de la colonisation britannique',
      );
    }
    return SupportedLanguages.getLanguageInfo(languageCode);
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedNativeLanguage != null;
      case 1:
        return _selectedLearningLanguages.isNotEmpty;
      case 2:
        return true;
      default:
        return false;
    }
  }

  String _getNextButtonText() {
    switch (_currentStep) {
      case 0:
        return 'Continuer';
      case 1:
        return 'Confirmer';
      case 2:
        return 'Commencer l\'aventure';
      default:
        return 'Suivant';
    }
  }

  void _handleNext() {
    if (_currentStep < 2) {
      _nextStep();
    } else {
      _completeOnboarding();
    }
  }
}
