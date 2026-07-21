import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/profile_service.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.avatarData,
    this.size = 100,
    this.isEditable = true,
  });

  final String name;
  final String? avatarData;
  final double size;
  final bool isEditable;

  String _getInitials() {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Future<void> _pickImage(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.first.bytes != null) {
        // Base64 encode for cross-platform (works on web and mobile)
        final base64String = base64Encode(result.files.first.bytes!);
        final service = ProfileService.instance;
        if (service.profile != null) {
          await service.updateProfile(
            name: service.profile!.name,
            phone: service.profile!.phone,
            dob: service.profile!.dob,
            gender: service.profile!.gender,
            address: service.profile!.address,
            avatarUrl: 'data:image/png;base64,$base64String',
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile picture updated!')),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _removeImage(BuildContext context) async {
    final service = ProfileService.instance;
    if (service.profile != null) {
      await service.updateProfile(
        name: service.profile!.name,
        phone: service.profile!.phone,
        dob: service.profile!.dob,
        gender: service.profile!.gender,
        address: service.profile!.address,
        avatarUrl: null,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture removed.')),
        );
      }
    }
  }

  void _showBottomSheet(BuildContext context) {
    if (!isEditable) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: const Color(0xFFFAF6EA),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: Color(0xFFF4B400)),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(context);
                },
              ),
              if (avatarData != null)
                ListTile(
                  leading: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                  title: const Text('Remove Photo', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(context);
                    _removeImage(context);
                  },
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials();
    final hasImage = avatarData != null && avatarData!.startsWith('data:image');

    Widget avatarChild;
    if (hasImage) {
      try {
        final base64Image = avatarData!.split(',').last;
        final decodedBytes = base64Decode(base64Image);
        avatarChild = Image.memory(
          decodedBytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      } catch (e) {
        avatarChild = Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFFAF6EA),
          ),
        );
      }
    } else {
      avatarChild = Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFFAF6EA),
        ),
      );
    }

    return Hero(
      tag: 'profile_avatar_hero',
      child: GestureDetector(
        onTap: () => _showBottomSheet(context),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF4B400), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(child: Center(child: avatarChild)),
            ),
            if (isEditable)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFF4B400),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Color(0xFF1F2937),
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
