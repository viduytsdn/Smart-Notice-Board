import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/notice.dart';
import '../providers/auth_provider.dart';
import '../providers/content_provider.dart';
import '../widgets/add_content_dialog.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contentProvider = context.watch<ContentProvider>();
    final notices = contentProvider.notices;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Notice Board Admin'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () {
              context.read<AuthProvider>().signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 720;
          final int gridCount;
          if (isWide) {
            final count = (constraints.maxWidth / 360).floor();
            gridCount = count < 2
                ? 2
                : count > 4
                    ? 4
                    : count;
          } else {
            gridCount = 1;
          }

          if (notices.isEmpty) {
            return const Center(
              child: Text('No content yet. Tap the + button to create a notice.'),
            );
          }

          if (gridCount == 1) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notice = notices[index];
                return _NoticeCard(
                  notice: notice,
                  onEdit: () => _openEditor(context, notice),
                  onDelete: () => contentProvider.deleteNotice(notice.id),
                );
              },
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridCount,
              mainAxisExtent: 240,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: notices.length,
            itemBuilder: (context, index) {
              final notice = notices[index];
              return _NoticeCard(
                notice: notice,
                onEdit: () => _openEditor(context, notice),
                onDelete: () => contentProvider.deleteNotice(notice.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New notice'),
        onPressed: () => _openEditor(context, null),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, Notice? notice) async {
    final contentProvider = context.read<ContentProvider>();
    await showDialog<void>(
      context: context,
      builder: (_) => AddContentDialog(
        notice: notice,
        onSubmit: (result) {
          if (notice == null) {
            contentProvider.addNotice(result);
          } else {
            contentProvider.updateNotice(
              notice.copyWith(
                title: result.title,
                description: result.description,
                imageUrl: result.imageUrl,
                deviceIds: result.deviceIds,
              ),
            );
          }
        },
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.notice,
    required this.onEdit,
    required this.onDelete,
  });

  final Notice notice;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: notice.imageUrl.isNotEmpty
                ? Image.network(
                    notice.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.blueGrey.shade50,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  )
                : Container(
                    color: Colors.blueGrey.shade50,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_outlined),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notice.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  notice.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: notice.deviceIds
                      .map(
                        (device) => Chip(
                          label: Text(device),
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete notice'),
        content: Text('Are you sure you want to delete "${notice.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDelete();
    }
  }
}
