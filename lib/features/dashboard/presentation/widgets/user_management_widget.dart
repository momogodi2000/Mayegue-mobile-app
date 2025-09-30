import 'package:flutter/material.dart';

class UserManagementWidget extends StatelessWidget {
  final int totalUsers;
  final int newUsers;
  final int bannedUsers;
  final Function(String) onUserSearch;
  final Function(String) onUserFilter;

  const UserManagementWidget({
    super.key,
    required this.totalUsers,
    required this.newUsers,
    required this.bannedUsers,
    required this.onUserSearch,
    required this.onUserFilter,
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
              'User Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildUserTypeSummary(),
            const SizedBox(height: 16),
            const Text(
              'Recent Users',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            _buildUserItem('Alice Johnson', 'Student', 'Active', Colors.green),
            _buildUserItem('Dr. Michael Brown', 'Teacher', 'Active', Colors.green),
            _buildUserItem('Sarah Wilson', 'Student', 'Pending', Colors.orange),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to add new user
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add User'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to user list
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('View All'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeSummary() {
    return Row(
      children: [
        _buildUserTypeCard('Total Users', totalUsers.toString(), Colors.blue),
        const SizedBox(width: 12),
        _buildUserTypeCard('New Today', newUsers.toString(), Colors.green),
        const SizedBox(width: 12),
        _buildUserTypeCard('Banned', bannedUsers.toString(), Colors.red),
      ],
    );
  }

  Widget _buildUserTypeCard(String type, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1 * 255),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              type,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserItem(String name, String role, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            child: Text(
              name[0],
              style: const TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  role,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1 * 255),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // Edit user
            },
            icon: const Icon(Icons.more_vert, size: 20),
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}