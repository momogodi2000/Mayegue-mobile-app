import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/themes/colors.dart';
import '../../domain/entities/lesson.dart';

/// Widget for displaying lesson progress information
class LessonProgressWidget extends StatelessWidget {
  final List<Lesson> lessons;
  final Function(Lesson)? onLessonTap;

  const LessonProgressWidget({
    super.key,
    required this.lessons,
    this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    final completedLessons = lessons.where((l) => l.isCompleted).length;
    final totalLessons = lessons.length;
    final progressPercentage =
        totalLessons > 0 ? (completedLessons / totalLessons) : 0.0;

    return Card(
      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progression du cours',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$completedLessons/$totalLessons',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingMedium),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: progressPercentage,
                  backgroundColor: Colors.grey.shade300,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 8,
                ),
                const SizedBox(height: AppDimensions.spacingSmall),
                Text(
                  '${(progressPercentage * 100).toInt()}% terminé',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.spacingLarge),

            // Lessons grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                return _buildLessonDot(lesson, index + 1);
              },
            ),

            const SizedBox(height: AppDimensions.spacingMedium),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(Icons.check_circle, Colors.green, 'Terminé'),
                _buildLegendItem(
                    Icons.play_circle, AppColors.primary, 'En cours'),
                _buildLegendItem(
                    Icons.radio_button_unchecked, Colors.grey, 'Disponible'),
                _buildLegendItem(
                    Icons.lock, Colors.grey.shade400, 'Verrouillé'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonDot(Lesson lesson, int number) {
    Color color;
    IconData icon;
    bool isAccessible = true; // You can implement accessibility logic

    switch (lesson.status) {
      case LessonStatus.completed:
        color = Colors.green;
        icon = Icons.check;
        break;
      case LessonStatus.inProgress:
        color = AppColors.primary;
        icon = Icons.play_arrow;
        break;
      case LessonStatus.available:
        color = AppColors.primary.withValues(alpha: 178);
        icon = Icons.circle_outlined;
        break;
      case LessonStatus.locked:
        color = Colors.grey.shade400;
        icon = Icons.lock;
        isAccessible = false;
        break;
    }

    return GestureDetector(
      onTap: isAccessible && onLessonTap != null
          ? () => onLessonTap!(lesson)
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 76),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: lesson.status == LessonStatus.completed
              ? Icon(icon, color: Colors.white, size: 20)
              : lesson.status == LessonStatus.locked
                  ? Icon(icon, color: Colors.white, size: 16)
                  : Text(
                      '$number',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, Color color, String label) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: AppDimensions.spacingSmall / 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

/// Widget for displaying lesson statistics
class LessonStatsWidget extends StatelessWidget {
  final List<Lesson> lessons;
  final int totalStudyTime; // in minutes
  final int streak; // study streak in days

  const LessonStatsWidget({
    super.key,
    required this.lessons,
    this.totalStudyTime = 0,
    this.streak = 0,
  });

  @override
  Widget build(BuildContext context) {
    final completedLessons = lessons.where((l) => l.isCompleted).length;
    final totalEstimatedTime = lessons.fold<int>(
      0,
      (sum, lesson) => sum + lesson.estimatedDuration,
    );
    final completedTime = lessons
        .where((l) => l.isCompleted)
        .fold<int>(0, (sum, lesson) => sum + lesson.estimatedDuration);

    return Card(
      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistiques',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.school,
                    value: '$completedLessons',
                    label: 'Leçons terminées',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMedium),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.access_time,
                    value: '${completedTime}min',
                    label: 'Temps d\'étude',
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.local_fire_department,
                    value: '$streak',
                    label: 'Jours consécutifs',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMedium),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.timer,
                    value: '${totalEstimatedTime}min',
                    label: 'Temps total',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 25),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        border: Border.all(color: color.withValues(alpha: 76)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppDimensions.spacingSmall),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSmall / 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Widget for displaying upcoming lessons
class UpcomingLessonsWidget extends StatelessWidget {
  final List<Lesson> lessons;
  final Function(Lesson)? onLessonTap;

  const UpcomingLessonsWidget({
    super.key,
    required this.lessons,
    this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    final upcomingLessons = lessons
        .where((l) =>
            l.status == LessonStatus.available ||
            l.status == LessonStatus.inProgress)
        .take(3)
        .toList();

    if (upcomingLessons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(AppDimensions.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prochaines leçons',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMedium),
            ...upcomingLessons.map(
              (lesson) => Padding(
                padding:
                    const EdgeInsets.only(bottom: AppDimensions.spacingSmall),
                child: _buildUpcomingLessonItem(lesson),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingLessonItem(Lesson lesson) {
    return InkWell(
      onTap: onLessonTap != null ? () => onLessonTap!(lesson) : null,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingSmall),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: lesson.status == LessonStatus.inProgress
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 178),
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
              ),
              child: Center(
                child: lesson.status == LessonStatus.inProgress
                    ? const Icon(Icons.play_arrow,
                        color: Colors.white, size: 20)
                    : Text(
                        '${lesson.order}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacingSmall / 2),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: AppDimensions.spacingSmall / 2),
                      Text(
                        '${lesson.estimatedDuration} min',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
