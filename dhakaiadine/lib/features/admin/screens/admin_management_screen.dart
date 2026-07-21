import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../services/admin_repository.dart';
import '../widgets/image_field.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({
    super.key,
    required this.title,
    required this.tableName,
    required this.itemLabel,
    required this.fields,
  });

  final String title;
  final String tableName;
  final String itemLabel;
  final List<AdminFieldDefinition> fields;

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  late final Stream<List<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = AdminRepository.instance.watchCollection(widget.tableName);
  }

  Future<void> _showEditor({Map<String, dynamic>? existing}) async {
    final values = <String, dynamic>{
      for (final field in widget.fields)
        field.key: existing?[field.key] ?? field.defaultValue,
    };
    final controllers = {
      for (final field in widget.fields)
        field.key: TextEditingController(
          text: (existing?[field.key] ?? field.defaultValue)?.toString() ?? '',
        ),
    };
    ({String path, Uint8List bytes})? imageUpload;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            existing == null
                ? 'Add ${widget.itemLabel}'
                : 'Edit ${widget.itemLabel}',
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final field in widget.fields)
                    if (field.key.contains('image'))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ImageField(
                          label: field.label,
                          onChanged: (upload) => imageUpload = upload,
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TextField(
                          controller: controllers[field.key],
                          decoration: InputDecoration(labelText: field.label),
                          keyboardType: field.isNumber
                              ? TextInputType.number
                              : TextInputType.text,
                          maxLines: field.isMultiline ? 3 : 1,
                        ),
                      ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                for (final field in widget.fields) {
                  final raw = controllers[field.key]!.text.trim();
                  if (field.isNumber) {
                    values[field.key] = double.tryParse(raw) ?? 0;
                  } else {
                    values[field.key] = raw;
                  }
                }
                Navigator.pop(context, true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != true) {
      for (final controller in controllers.values) {
        controller.dispose();
      }
      return;
    }

    try {
      if (imageUpload != null) {
        final bucket = widget.tableName == 'banners' ? 'banners' : 'images';
        final fileName =
            '${widget.tableName}/${DateTime.now().millisecondsSinceEpoch}_${imageUpload!.path}';
        await AdminRepository.instance.uploadImage(
          bucket: bucket,
          fileName: fileName,
          mimeType: 'image/jpeg',
          bytes: imageUpload!.bytes.toList(),
        );
        values['image_url'] = fileName;
      }

      await AdminRepository.instance.upsertRecord(
        widget.tableName,
        id: existing?['id']?.toString(),
        payload: values,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.itemLabel} saved successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save ${widget.itemLabel.toLowerCase()}: $error',
          ),
        ),
      );
    } finally {
      for (final controller in controllers.values) {
        controller.dispose();
      }
    }
  }

  Future<void> _confirmDelete(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete item'),
          content: Text(
            'Delete this ${widget.itemLabel.toLowerCase()} permanently?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;
    try {
      await AdminRepository.instance.deleteRecord(widget.tableName, id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${widget.itemLabel} deleted.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to delete ${widget.itemLabel.toLowerCase()}: $error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 56, color: AppTheme.primary),
                  const SizedBox(height: 12),
                  Text('No ${widget.itemLabel.toLowerCase()}s yet.'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['name']?.toString() ??
                                  item['title']?.toString() ??
                                  widget.itemLabel,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit',
                            onPressed: () => _showEditor(existing: item),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            onPressed: () =>
                                _confirmDelete(item['id'].toString()),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      for (final field in widget.fields)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${field.label}: ${item[field.key] ?? '—'}',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditor(),
        icon: const Icon(Icons.add),
        label: Text('Add ${widget.itemLabel}'),
      ),
    );
  }
}

class AdminFieldDefinition {
  const AdminFieldDefinition({
    required this.key,
    required this.label,
    this.defaultValue = '',
    this.isNumber = false,
    this.isMultiline = false,
  });

  final String key;
  final String label;
  final Object defaultValue;
  final bool isNumber;
  final bool isMultiline;
}
