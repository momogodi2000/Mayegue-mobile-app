import 'package:flutter/material.dart';
import '../../../../shared/themes/colors.dart';
import '../../../../shared/themes/dimensions.dart';
import '../../domain/entities/language_entity.dart';

/// Card widget to display language information
class LanguageCard extends StatelessWidget {
  final LanguageEntity language;
  final VoidCallback? onTap;
  final bool isSelected;

  const LanguageCard({
    super.key,
    required this.language,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 8 : 2,
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusMObj,
        side: isSelected
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderRadiusMObj,
        child: Padding(
          padding: AppDimensions.paddingM,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language name
              Text(
                language.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? AppColors.primary : AppColors.onSurface,
                    ),
              ),

              const SizedBox(height: AppDimensions.spacingS),

              // Group and region
              Row(
                children: [
                  const Icon(
                    Icons.category,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppDimensions.spacingXS),
                  Text(
                    language.group,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.8),
                        ),
                  ),
                  const SizedBox(width: AppDimensions.spacingM),
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: AppDimensions.spacingXS),
                  Text(
                    language.region,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.8),
                        ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingS),

              // Type and status
              Row(
                children: [
                  _buildTypeChip(context, language.type),
                  const SizedBox(width: AppDimensions.spacingS),
                  _buildStatusChip(context, language.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context, String type) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: AppDimensions.spacingXS,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: AppDimensions.borderRadiusSObj,
      ),
      child: Text(
        type,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'active':
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        break;
      default:
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: AppDimensions.spacingXS,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppDimensions.borderRadiusSObj,
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
