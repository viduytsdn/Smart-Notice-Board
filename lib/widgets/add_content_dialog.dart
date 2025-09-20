import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/notice.dart';
import '../services/content_service.dart';

class AddContentDialog extends StatefulWidget {
  const AddContentDialog({
    super.key,
    required this.contentService,
    required this.adminId,
    this.notice,
  });

  final ContentService contentService;
  final String adminId;
  final Notice? notice;

  @override
  State<AddContentDialog> createState() => _AddContentDialogState();
}

class _AddContentDialogState extends State<AddContentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _deviceIdsController;
  bool _uploading = false;

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

  Future<void> _uploadImage() async {
    setState(() {
      _uploading = true;
    });
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null || result.files.isEmpty) {
        return;
      }
      final file = result.files.single;

      String? url;
      if (kIsWeb) {
        final bytes = file.bytes;
        if (bytes == null) {
          throw Exception('No file bytes received.');
        }
        url = await widget.contentService.uploadWebImage(
          data: bytes,
          adminId: widget.adminId,
          fileName: file.name,
        );
      } else {
        final path = file.path;
        if (path == null) {
          throw Exception('No file path received.');
        }
        url = await widget.contentService.uploadImage(
          file: File(path),
          adminId: widget.adminId,
        );
      }

      if (!mounted) return;
      setState(() {
        _imageUrlController.text = url!;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
        });
      }
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final notice = Notice(
      id: widget.notice?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      deviceIds: _deviceIdsController.text
          .split(',')
          .map((id) => id.trim())
          .where((id) => id.isNotEmpty)
          .toList(),
      createdAt: widget.notice?.createdAt,
    );

    Navigator.of(context).pop(notice);
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
                  if (value == null || value.isEmpty) {
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
                  if (value == null || value.isEmpty) {
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
                  helperText: 'Comma separated list of device identifiers',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _uploading ? null : _uploadImage,
                  icon: _uploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: const Text('Upload Image'),
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
          onPressed: _uploading ? null : _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
