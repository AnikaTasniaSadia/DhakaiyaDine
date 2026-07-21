import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../widgets/profile_avatar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const _yellow = Color(0xFFF4B400);
  static const _navy = Color(0xFF1F2937);
  static const _bg = Color(0xFFFAF6EA);

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  String? _selectedGender;
  String? _selectedDob;
  bool _loading = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    final profile = ProfileService.instance.profile;
    _nameCtrl = TextEditingController(text: profile?.name ?? '');
    _emailCtrl = TextEditingController(text: profile?.email ?? '');
    _phoneCtrl = TextEditingController(text: profile?.phone ?? '');
    _addressCtrl = TextEditingController(text: profile?.address ?? '');
    _selectedGender = profile?.gender;
    _selectedDob = profile?.dob;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _yellow,
              onPrimary: _navy,
              onSurface: _navy,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDob = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    await ProfileService.instance.updateProfile(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      dob: _selectedDob,
      gender: _selectedGender,
      address: _addressCtrl.text.trim(),
      avatarUrl: ProfileService.instance.profile?.avatarUrl,
    );

    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ProfileService.instance.profile;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            Center(
              child: ProfileAvatar(
                name: profile?.name ?? 'User',
                avatarData: profile?.avatarUrl,
                size: 96,
                isEditable: true,
              ),
            ),
            const SizedBox(height: 24),
            _buildField('Full Name', _nameCtrl, Icons.person_rounded),
            const SizedBox(height: 16),
            _buildField('Email (Read Only)', _emailCtrl, Icons.email_rounded, enabled: false),
            const SizedBox(height: 16),
            _buildField('Phone Number', _phoneCtrl, Icons.phone_rounded, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            
            // Gender Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gender',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _navy),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFECECEC)),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedGender,
                    decoration: const InputDecoration(border: InputBorder.none),
                    items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (val) => setState(() => _selectedGender = val),
                    hint: const Text('Select Gender', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date of birth field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Date of Birth',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _navy),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFECECEC)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: _yellow, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _selectedDob ?? 'Select Date of Birth',
                          style: TextStyle(
                            color: _selectedDob != null ? _navy : const Color(0xFF9CA3AF),
                            fontSize: 14,
                            fontWeight: _selectedDob != null ? FontWeight.w700 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildField('Address', _addressCtrl, Icons.home_rounded),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _navy,
                      side: const BorderSide(color: _navy),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _yellow,
                      foregroundColor: _navy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Save', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _navy),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFECECEC)),
          ),
          child: TextField(
            controller: ctrl,
            enabled: enabled,
            keyboardType: keyboardType,
            style: TextStyle(color: enabled ? _navy : const Color(0xFF6B7280)),
            decoration: InputDecoration(
              icon: Icon(icon, color: _yellow, size: 20),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}
