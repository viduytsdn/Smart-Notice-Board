import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/notice.dart';
import '../providers/auth_provider.dart';
import '../services/content_service.dart';
import '../widgets/add_content_dialog.dart';
import 'login_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  Future<void> _addNotice(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final contentService = context.read<ContentService>();
    final userId = auth.user?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to add content.')),
      );
      return;
    }

    final result = await showDialog<Notice>(
      context: context,
      builder: (_) => AddContentDialog(
        contentService: contentService,
        adminId: userId,
      ),
    );

    if (result != null) {
      await contentService.addNotice(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content added successfully.')),
        );
      }
    }
  }

  Future<void> _editNotice(BuildContext context, Notice notice) async {
    final auth = context.read<AuthProvider>();
    final contentService = context.read<ContentService>();
    final userId = auth.user?.uid;
    if (userId == null) {
      return;
    }

    final result = await showDialog<Notice>(
      context: context,
      builder: (_) => AddContentDialog(
        contentService: contentService,
        adminId: userId,
        notice: notice,
      ),
    );

    if (result != null) {
      final updated = Notice(
        id: notice.id,
        title: result.title,
        description: result.description,
        imageUrl: result.imageUrl,
        deviceIds: result.deviceIds,
        createdAt: notice.createdAt,
      );
      await contentService.updateNotice(updated);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content updated.')),
        );
      }
    }
  }

  Future<void> _deleteNotice(BuildContext context, Notice notice) async {
    final contentService = context.read<ContentService>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete content'),
        content: Text('Delete "${notice.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await contentService.deleteNotice(notice.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Content deleted.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentService = context.watch<ContentService>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<List<Notice>>(
        stream: contentService.streamNotices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load content: ${snapshot.error}'),
            );
          }
          final notices = snapshot.data ?? [];
          if (notices.isEmpty) {
            return const Center(child: Text('No content available yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final notice = notices[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: notice.imageUrl.isNotEmpty
                      ? SizedBox(
                          width: 56,
                          height: 56,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              notice.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                            ),
                          ),
                        )
                      : const Icon(Icons.image_outlined),
                  title: Text(notice.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notice.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (notice.deviceIds.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: notice.deviceIds
                              .map((id) => Chip(
                                    label: Text(id),
                                    visualDensity: VisualDensity.compact,
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<_MenuAction>(
                    onSelected: (value) {
                      switch (value) {
                        case _MenuAction.edit:
                          _editNotice(context, notice);
                          break;
                        case _MenuAction.delete:
                          _deleteNotice(context, notice);
                          break;
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _MenuAction.edit,
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                        ),
                      ),
                      PopupMenuItem(
                        value: _MenuAction.delete,
                        child: ListTile(
                          leading: Icon(Icons.delete),
                          title: Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNotice(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

enum _MenuAction { edit, delete }
