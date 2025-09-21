import 'package:flutter/material.dart';

import '../models/notice.dart';

class AddContentDialog extends StatefulWidget {
  const AddContentDialog({
    super.key,
    this.notice,
    required this.onSubmit,
  });

  final Notice? notice;
  final ValueChanged<Notice> onSubmit;

  @override
  State<AddContentDialog> createState() => _AddContentDialogState();
}

class _AddContentDialogState extends State<AddContentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _deviceIdsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.notice?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.notice?.description ?? '');
    _imageUrlController =
        TextEditingController(text: widget.notice?.imageUrl ?? '');
    _deviceIdsController = TextEditingController(
      text: widget.notice?.deviceIds.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _deviceIdsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final notice = (widget.notice ??
            Notice(
              id: '',
              title: '',
              description: '',
              imageUrl: '',
              deviceIds: const <String>[],
              createdAt: DateTime.now(),
            ))
        .copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      deviceIds: _deviceIdsController.text
          .split(',')
          .map((id) => id.trim())
          .where((id) => id.isNotEmpty)
          .toList(),
    );

    widget.onSubmit(notice);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.notice == null ? 'Add Content' : 'Edit Content'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deviceIdsController,
                decoration: const InputDecoration(
                  labelText: 'Device IDs',
                  helperText: 'Comma separated list of displays to target',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (optional)',
                  helperText: 'Paste a web image link to preview on the board',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
