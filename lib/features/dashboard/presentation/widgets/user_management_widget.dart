import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/admin_dashboard_viewmodel.dart';

class UserManagementWidget extends StatefulWidget {
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
  State<UserManagementWidget> createState() => _UserManagementWidgetState();
}

class _UserManagementWidgetState extends State<UserManagementWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRoleFilter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search users by name or email',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: widget.onUserSearch,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedRoleFilter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'learner', child: Text('Learners')),
                    DropdownMenuItem(value: 'teacher', child: Text('Teachers')),
                    DropdownMenuItem(value: 'admin', child: Text('Admins')),
                  ],
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() => _selectedRoleFilter = val);
                    widget.onUserFilter(val);
                  },
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _showCreateAccountDialog,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Create'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildUserTypeSummary(),
            const SizedBox(height: 16),
            _buildUserListSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeSummary() {
    return Row(
      children: [
        _buildUserTypeCard(
          'Total Users',
          widget.totalUsers.toString(),
          Colors.blue,
        ),
        const SizedBox(width: 12),
        _buildUserTypeCard(
          'New Today',
          widget.newUsers.toString(),
          Colors.green,
        ),
        const SizedBox(width: 12),
        _buildUserTypeCard('Banned', widget.bannedUsers.toString(), Colors.red),
      ],
    );
  }

  Widget _buildUserListSection() {
    final vm = Provider.of<AdminDashboardViewModel>(context);
    if (vm.users.isEmpty) {
      return const Text('No users found');
    }

    final filtered = vm.users.where((u) {
      final matchesRole =
          _selectedRoleFilter == 'all' || u['role'] == _selectedRoleFilter;
      final q = _searchController.text.trim().toLowerCase();
      final matchesQuery =
          q.isEmpty ||
          (u['name']?.toString().toLowerCase().contains(q) ?? false) ||
          (u['email']?.toString().toLowerCase().contains(q) ?? false);
      return matchesRole && matchesQuery;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Users', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final user = filtered[index];
            final isActive = user['status'] == 'active';
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: Text(
                      (user['name'] as String?)?.isNotEmpty == true
                          ? (user['name'] as String)
                                .substring(0, 1)
                                .toUpperCase()
                          : '?',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'] as String? ?? 'Unnamed',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          user['email'] as String? ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Role dropdown
                  DropdownButton<String>(
                    value: (user['role'] as String?) ?? 'learner',
                    items: const [
                      DropdownMenuItem(
                        value: 'learner',
                        child: Text('Learner'),
                      ),
                      DropdownMenuItem(
                        value: 'teacher',
                        child: Text('Teacher'),
                      ),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (val) async {
                      if (val == null) return;
                      final ok = await vm.updateUserRole(
                        user['id'] as String,
                        val,
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? 'Role updated to $val'
                                : 'Failed to update role',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  // Active toggle
                  Row(
                    children: [
                      const Text('Active', style: TextStyle(fontSize: 12)),
                      Switch(
                        value: isActive,
                        onChanged: (val) async {
                          final ok = await vm.setUserActive(
                            user['id'] as String,
                            val,
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? (val
                                          ? 'User activated'
                                          : 'User deactivated')
                                    : 'Failed to update user status',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
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
            Text(type, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  void _showCreateAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => const _CreateAccountDialog(),
    );
  }
}

class _CreateAccountDialog extends StatefulWidget {
  const _CreateAccountDialog();

  @override
  State<_CreateAccountDialog> createState() => _CreateAccountDialogState();
}

class _CreateAccountDialogState extends State<_CreateAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = 'teacher';
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Account'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Display name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'Invalid email' : null,
            ),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password (min 8 chars)',
              ),
              validator: (v) =>
                  (v == null || v.length < 8) ? 'Too short' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Role:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _role,
                  items: const [
                    DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (val) => setState(() => _role = val ?? 'teacher'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : () => _submit(context),
          child: _loading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    // Access ViewModel via Provider without listening
    final vm = Provider.of<AdminDashboardViewModel>(context, listen: false);
    bool ok;
    if (_role == 'admin') {
      ok = await vm.createAdminAccount(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        displayName: _nameCtrl.text.trim(),
      );
    } else {
      ok = await vm.createTeacherAccount(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        displayName: _nameCtrl.text.trim(),
      );
    }
    if (!context.mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Account created')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to create account')));
    }
  }
}
