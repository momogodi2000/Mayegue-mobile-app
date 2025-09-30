import 'package:flutter/material.dart';
import '../../../../shared/themes/colors.dart';

/// Card widget for displaying user testimonials in the guest dashboard
class TestimonialCard extends StatelessWidget {
  final String name;
  final String role;
  final String comment;
  final int rating;
  final String avatarUrl;

  const TestimonialCard({
    super.key,
    required this.name,
    required this.role,
    required this.comment,
    required this.rating,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Rating stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Comment
            Text(
              '"$comment"',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // User info
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(avatarUrl),
                  onBackgroundImageError: (_, __) => const Icon(Icons.person),
                  child: const Icon(Icons.person, color: Colors.white),
                ),

                const SizedBox(width: 12),

                // Name and role
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                    ),
                    Text(
                      role,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
