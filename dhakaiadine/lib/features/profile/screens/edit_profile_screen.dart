import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  bool _loading = false;
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    final email = Supabase.instance.client.auth.currentUser?.email;
    if (uid == null) {
      setState(() => _loadingData = false);
      return;
    }
    try {
      final res = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', uid)
          .single();
      if (mounted) {
        setState(() {
          _nameCtrl.text = res['name'] ?? '';
          _phoneCtrl.text = res['phone'] ?? '';
          _emailCtrl.text = email ?? '';
          _loadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _emailCtrl.text = email ?? '';
          _loadingData = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name is required')));
      return;
    }

    setState(() => _loading = true);
    try {
      await Supabase.instance.client
          .from('users')
          .update({
            'name': _nameCtrl.text.trim(),
            'phone': _phoneCtrl.text.trim(),
          })
          .eq('id', uid);

      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loadingData
          ? const Center(child: CircularProgressIndicator(color: _yellow))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildField('Full Name', _nameCtrl, Icons.person_rounded),
                  const SizedBox(height: 20),
                  _buildField(
                    'Email',
                    _emailCtrl,
                    Icons.email_rounded,
                    enabled: false,
                  ),
                  const SizedBox(height: 20),
                  _buildField('Phone Number', _phoneCtrl, Icons.phone_rounded),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _yellow,
                        foregroundColor: _navy,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _loading ? null : _saveProfile,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _navy,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          enabled: enabled,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: _yellow, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8E0D0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8E0D0)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8E0D0)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
          ),
        ),
      ],
    );
  }
}
