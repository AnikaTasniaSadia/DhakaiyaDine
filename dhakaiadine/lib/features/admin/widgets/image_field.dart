import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ImageField extends StatefulWidget {
  const ImageField({super.key, required this.label, required this.onChanged});

  final String label;
  final ValueChanged<({String path, Uint8List bytes})> onChanged;

  @override
  State<ImageField> createState() => _ImageFieldState();
}

class _ImageFieldState extends State<ImageField> {
  String? _fileName;

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;
    setState(() => _fileName = file.name);
    widget.onChanged((path: file.name, bytes: Uint8List.fromList(bytes)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _pick,
          icon: const Icon(Icons.upload_file),
          label: Text(_fileName ?? 'Pick image'),
        ),
      ],
    );
  }
}
