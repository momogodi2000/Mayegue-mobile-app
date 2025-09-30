import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lessons_view.dart';
import '../viewmodels/courses_viewmodel.dart';
import '../../domain/entities/course.dart';

class CoursesView extends StatefulWidget {
  final String? langueChoisie;
  final String? nomUtilisateur;
  final String? emailUtilisateur;
  final String? niveau;

  const CoursesView({
    super.key,
    this.langueChoisie,
    this.nomUtilisateur,
    this.emailUtilisateur,
    this.niveau,
  });

  @override
  State<CoursesView> createState() => _CoursesViewState();
}

class _CoursesViewState extends State<CoursesView> {
  @override
  void initState() {
    super.initState();
    // Load courses when the view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoursesViewModel>().loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CoursesViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cours'),
        actions: [
          // Filter button
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                viewModel.clearFilters();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'language',
                child: Text('Filtrer par langue'),
              ),
              const PopupMenuItem(
                value: 'level',
                child: Text('Filtrer par niveau'),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Effacer les filtres'),
              ),
            ],
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => viewModel.loadCourses(),
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : _buildCoursesList(viewModel),
    );
  }

  Widget _buildCoursesList(CoursesViewModel viewModel) {
    final courses = viewModel.filteredCourses;

    if (courses.isEmpty) {
      return const Center(
        child: Text('Aucun cours disponible'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final isEnrolled = viewModel.isEnrolled(course.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              // Navigate to course details/lessons
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LessonsView(courseId: course.id),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (course.status == CourseStatus.published)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Premium',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.language,
                        course.languageCode.toUpperCase(),
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.school,
                        course.level.name,
                        Colors.green,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        Icons.book,
                        '${course.totalLessonsCount} leçons',
                        Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (course.completedLessonsCount > 0) ...[
                    LinearProgressIndicator(
                      value: course.progressPercentage,
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${course.completedLessonsCount}/${course.totalLessonsCount} leçons terminées',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEnrolled ? 'Inscrit' : 'Non inscrit',
                        style: TextStyle(
                          color: isEnrolled ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Handle enrollment
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Fonctionnalité d\'inscription à venir'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isEnrolled ? Colors.green : Colors.blue,
                        ),
                        child: Text(isEnrolled ? 'Continuer' : 'S\'inscrire'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
