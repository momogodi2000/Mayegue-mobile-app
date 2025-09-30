import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../monitoring/app_monitoring.dart';
class AppErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget? fallbackWidget;
  final String? title;
  final String? message;
  const AppErrorBoundary({
    super.key,
    required this.child,
    this.fallbackWidget,
    this.title,
    this.message,
  });
  @override
  State<AppErrorBoundary> createState() => _AppErrorBoundaryState();
}
class _AppErrorBoundaryState extends State<AppErrorBoundary> {
  bool _hasError = false;
  FlutterErrorDetails? _errorDetails;
  @override
  void initState() {
    super.initState();
    FlutterError.onError = (FlutterErrorDetails details) {
      AppMonitoring().recordError(
        details.exception,
        details.stack,
        reason: 'Flutter Error: ',
        context: {
          'error_type': 'flutter_error',
          'library': details.library ?? 'unknown',
          'context': details.context?.toString() ?? 'no_context',
        },
        fatal: false,
      );
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorDetails = details;
        });
      }
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      AppMonitoring().recordError(
        error,
        stack,
        reason: 'Platform Error',
        context: {
          'error_type': 'platform_error',
          'platform': defaultTargetPlatform.name,
        },
        fatal: true,
      );
      return true;
    };
  }
  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.fallbackWidget ?? _buildErrorWidget(context);
    }
    return widget.child;
  }
  Widget _buildErrorWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                widget.title ?? 'Oups ! Une erreur s\'est produite',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                widget.message ??
                    'L\'application a rencontré un problème inattendu. '
                        'Nous avons été notifiés et travaillons sur une solution.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (kDebugMode && _errorDetails != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Détails de l\'erreur (mode debug):',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorDetails!.exception.toString(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _restart,
                      child: const Text('Redémarrer'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _retry,
                      child: const Text('Réessayer'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _reportBug,
                child: const Text('Signaler le problème'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _retry() {
    setState(() {
      _hasError = false;
      _errorDetails = null;
    });
    AppMonitoring().logEvent('error_boundary_retry', parameters: {
      'error_type': _errorDetails?.exception.runtimeType.toString(),
    });
  }
  void _restart() {
    setState(() {
      _hasError = false;
      _errorDetails = null;
    });
    AppMonitoring().logEvent('error_boundary_restart', parameters: {
      'error_type': _errorDetails?.exception.runtimeType.toString(),
    });
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }
  void _reportBug() {
    AppMonitoring().logEvent('error_boundary_report_bug', parameters: {
      'error_type': _errorDetails?.exception.runtimeType.toString(),
      'user_initiated': true,
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler un problème'),
        content: const Text(
          'Votre rapport d\'erreur a été envoyé automatiquement. '
          'Si le problème persiste, vous pouvez nous contacter à '
          'support@mayegue.com avec une description détaillée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
