import 'package:flutter/material.dart';

class StudentProgressWidget extends StatelessWidget {
  final List<Map<String, dynamic>> students;
  final Function(Map<String, dynamic>) onStudentTap;

  const StudentProgressWidget({
    super.key,
    required this.students,
    required this.onStudentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Student Progress Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (students.isEmpty)
              const Text('No students found')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: students.length > 3
                    ? 3
                    : students.length, // Show max 3 students
                itemBuilder: (context, index) {
                  final student = students[index];
                  final progress =
                      (student['progress'] as num?)?.toDouble() ?? 0.0;
                  final color = progress > 0.7
                      ? Colors.green
                      : progress > 0.4
                          ? Colors.orange
                          : Colors.red;

                  return Column(
                    children: [
                      InkWell(
                        onTap: () => onStudentTap(student),
                        child: _buildProgressItem(
                          student['name'] ?? 'Unknown',
                          student['currentCourse'] ?? 'No course',
                          progress,
                          color,
                        ),
                      ),
                      if (index <
                          (students.length > 3 ? 2 : students.length - 1))
                        const SizedBox(height: 12),
                    ],
                  );
                },
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to detailed student progress
              },
              child: const Text('View All Students'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(
    String studentName,
    String courseName,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              studentName,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          courseName,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}
