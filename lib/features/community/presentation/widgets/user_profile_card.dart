import 'package:flutter/material.dart';
import '../../domain/entities/community_entity.dart';

/// Widget for displaying a user profile card
class UserProfileCard extends StatelessWidget {
  final CommunityUserEntity user;
  final VoidCallback? onFollowPressed;
  final VoidCallback? onUnfollowPressed;
  final bool isFollowing;
  final bool showFollowButton;

  const UserProfileCard({
    Key? key,
    required this.user,
    this.onFollowPressed,
    this.onUnfollowPressed,
    this.isFollowing = false,
    this.showFollowButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundImage:
                  user.avatar != null ? NetworkImage(user.avatar!) : null,
              child: user.avatar == null
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      user.bio!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.language, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        user.languages.join(', '),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (user.location != null && user.location!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          user.location!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildStat('Posts', user.postsCount),
                      const SizedBox(width: 16),
                      _buildStat('Reputation', user.reputation),
                      const SizedBox(width: 16),
                      _buildStat('Likes', user.likesReceived),
                    ],
                  ),
                ],
              ),
            ),

            // Follow button
            if (showFollowButton) ...[
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: isFollowing ? onUnfollowPressed : onFollowPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing
                      ? Colors.grey
                      : Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(isFollowing ? 'Unfollow' : 'Follow'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
