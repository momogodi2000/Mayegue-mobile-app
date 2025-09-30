import 'package:flutter/material.dart';
import '../../themes/colors.dart';
import '../common/loading_widget.dart';
import '../common/error_widget.dart' as custom_error;

/// App Scaffold - Reusable scaffold wrapper with common patterns
class AppScaffold extends StatelessWidget {
  final String? title;
  final Widget? body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final bool? resizeToAvoidBottomInset;
  final Color? backgroundColor;
  final PreferredSizeWidget? appBar;
  final bool showAppBar;
  final bool isLoading;
  final String? loadingMessage;
  final bool hasError;
  final String? errorTitle;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Widget? bottomSheet;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const AppScaffold({
    super.key,
    this.title,
    this.body,
    this.floatingActionButton,
    this.actions,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,
    this.backgroundColor,
    this.appBar,
    this.showAppBar = true,
    this.isLoading = false,
    this.loadingMessage,
    this.hasError = false,
    this.errorTitle,
    this.errorMessage,
    this.onRetry,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.bottomSheet,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget;

    if (isLoading) {
      bodyWidget = LoadingWidget(
        message: loadingMessage ?? 'Chargement...',
      );
    } else if (hasError) {
      bodyWidget = Center(
        child: custom_error.ErrorWidget(
          title: errorTitle ?? 'Erreur',
          message: errorMessage,
          onRetry: onRetry,
        ),
      );
    } else {
      bodyWidget = body ?? const Center(child: Text('Contenu non défini'));
    }

    return Scaffold(
      appBar: showAppBar
          ? (appBar ??
              (title != null
                  ? AppBar(
                      title: Text(title!),
                      actions: actions,
                      leading: leading,
                      automaticallyImplyLeading: automaticallyImplyLeading,
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 0,
                    )
                  : null))
          : null,
      body: bodyWidget,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      backgroundColor: backgroundColor ?? AppColors.background,
      bottomSheet: bottomSheet,
    );
  }
}

/// Loading Scaffold - Scaffold with loading state
class LoadingScaffold extends StatelessWidget {
  final String? title;
  final String? message;
  final List<Widget>? actions;
  final Color? backgroundColor;

  const LoadingScaffold({
    super.key,
    this.title,
    this.message,
    this.actions,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      actions: actions,
      backgroundColor: backgroundColor,
      isLoading: true,
      loadingMessage: message,
    );
  }
}

/// Error Scaffold - Scaffold with error state
class ErrorScaffold extends StatelessWidget {
  final String? title;
  final String? errorTitle;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final List<Widget>? actions;
  final Color? backgroundColor;

  const ErrorScaffold({
    super.key,
    this.title,
    this.errorTitle,
    this.errorMessage,
    this.onRetry,
    this.actions,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      actions: actions,
      backgroundColor: backgroundColor,
      hasError: true,
      errorTitle: errorTitle,
      errorMessage: errorMessage,
      onRetry: onRetry,
    );
  }
}

/// Simple Scaffold - Minimal scaffold for simple pages
class SimpleScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Color? backgroundColor;

  const SimpleScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      body: body,
      actions: actions,
      floatingActionButton: floatingActionButton,
      backgroundColor: backgroundColor,
    );
  }
}
