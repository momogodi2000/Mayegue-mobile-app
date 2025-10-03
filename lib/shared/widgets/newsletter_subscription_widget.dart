import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../core/services/firebase_service.dart';

/// Newsletter subscription widget for collecting email addresses
class NewsletterSubscriptionWidget extends StatefulWidget {
  final bool isCompact;
  final String? customTitle;
  final String? customDescription;

  const NewsletterSubscriptionWidget({
    super.key,
    this.isCompact = false,
    this.customTitle,
    this.customDescription,
  });

  @override
  State<NewsletterSubscriptionWidget> createState() =>
      _NewsletterSubscriptionWidgetState();
}

class _NewsletterSubscriptionWidgetState
    extends State<NewsletterSubscriptionWidget> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSubscribed = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _subscribe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final firebaseService = context.read<FirebaseService>();
      final email = _emailController.text.trim().toLowerCase();

      // Check if email already exists
      final existingSubscription = await firebaseService.firestore
          .collection('newsletter_subscriptions')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (existingSubscription.docs.isNotEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Cet email est déjà inscrit à notre newsletter';
        });
        return;
      }

      // Add new subscription
      await firebaseService.firestore
          .collection('newsletter_subscriptions')
          .add({
            'email': email,
            'subscribedAt': FieldValue.serverTimestamp(),
            'isActive': true,
            'source': 'web', // or 'mobile' based on platform
            'language': 'fr',
            'tags': ['general'],
          });

      setState(() {
        _isLoading = false;
        _isSubscribed = true;
      });

      // Clear the form after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isSubscribed = false;
            _emailController.clear();
          });
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCompact) {
      return _buildCompactForm();
    }

    return _buildFullForm();
  }

  Widget _buildFullForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mail_outline, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.customTitle ?? 'Restez informé!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.customDescription ??
                'Inscrivez-vous à notre newsletter pour recevoir les dernières actualités, nouveaux cours et offres exclusives.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 24),
          if (_isSubscribed)
            _buildSuccessMessage()
          else
            _buildSubscriptionForm(),
        ],
      ),
    );
  }

  Widget _buildCompactForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.mail_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Newsletter',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isSubscribed)
            _buildSuccessMessage()
          else
            _buildSubscriptionForm(),
        ],
      ),
    );
  }

  Widget _buildSubscriptionForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: widget.isCompact
                ? null
                : const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'votre@email.com',
              hintStyle: widget.isCompact
                  ? null
                  : TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              filled: true,
              fillColor: widget.isCompact
                  ? null
                  : Colors.white.withValues(alpha: 0.2),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: widget.isCompact
                    ? BorderSide(color: Theme.of(context).dividerColor)
                    : BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: widget.isCompact
                    ? BorderSide(color: Theme.of(context).dividerColor)
                    : BorderSide.none,
              ),
              prefixIcon: Icon(
                Icons.email,
                color: widget.isCompact
                    ? null
                    : Colors.white.withValues(alpha: 0.8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Email invalide';
              }
              return null;
            },
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: widget.isCompact ? Colors.red : Colors.white,
                fontSize: 12,
              ),
            ),
          ],
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isLoading ? null : _subscribe,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.isCompact
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
              foregroundColor: widget.isCompact
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.isCompact
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : const Text(
                    'S\'inscrire',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isCompact
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isCompact ? Colors.green : Colors.white,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: widget.isCompact ? Colors.green : Colors.white,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Merci! Vous êtes maintenant inscrit à notre newsletter.',
              style: TextStyle(
                color: widget.isCompact ? Colors.green[700] : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Footer newsletter widget for landing pages
class FooterNewsletterWidget extends StatelessWidget {
  const FooterNewsletterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        children: [
          const NewsletterSubscriptionWidget(),
          const SizedBox(height: 32),
          Text(
            '© 2025 Ma\'a yegue. Tous droits réservés.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  // Navigate to privacy policy
                },
                child: const Text('Politique de confidentialité'),
              ),
              const Text(' • '),
              TextButton(
                onPressed: () {
                  // Navigate to terms
                },
                child: const Text('Conditions d\'utilisation'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
