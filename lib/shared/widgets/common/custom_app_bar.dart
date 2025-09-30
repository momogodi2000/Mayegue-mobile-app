import 'package:flutter/material.dart';
import '../../themes/colors.dart';

/// Custom App Bar - Reusable app bar component with theme integration
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.centerTitle = true,
    this.flexibleSpace,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: foregroundColor ?? AppColors.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? AppColors.onPrimary,
      elevation: elevation,
      centerTitle: centerTitle,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      leading: leading ??
          (showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                )
              : null),
      actions: actions,
      iconTheme: IconThemeData(
        color: foregroundColor ?? AppColors.onPrimary,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Custom App Bar with Search - App bar with integrated search functionality
class CustomAppBarWithSearch extends StatefulWidget
    implements PreferredSizeWidget {
  final String title;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? searchHint;

  const CustomAppBarWithSearch({
    super.key,
    required this.title,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.searchHint,
  });

  @override
  State<CustomAppBarWithSearch> createState() => _CustomAppBarWithSearchState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarWithSearchState extends State<CustomAppBarWithSearch> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.searchHint ?? 'Rechercher...',
                hintStyle: TextStyle(
                  color: (widget.foregroundColor ?? AppColors.onPrimary)
                      .withValues(alpha: 0.7),
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: widget.foregroundColor ?? AppColors.onPrimary,
              ),
              onChanged: widget.onSearchChanged,
              onSubmitted: (value) {
                widget.onSearchSubmitted?.call();
                setState(() {
                  _isSearching = false;
                });
              },
            )
          : Text(
              widget.title,
              style: TextStyle(
                color: widget.foregroundColor ?? AppColors.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
      backgroundColor: widget.backgroundColor ?? AppColors.primary,
      foregroundColor: widget.foregroundColor ?? AppColors.onPrimary,
      elevation: 0,
      centerTitle: true,
      leading: _isSearching
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
              },
            )
          : IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
      actions: _isSearching
          ? [
              if (widget.onSearchSubmitted != null)
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: widget.onSearchSubmitted,
                ),
            ]
          : [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
              ),
              if (widget.actions != null) ...widget.actions!,
            ],
      iconTheme: IconThemeData(
        color: widget.foregroundColor ?? AppColors.onPrimary,
      ),
    );
  }
}
