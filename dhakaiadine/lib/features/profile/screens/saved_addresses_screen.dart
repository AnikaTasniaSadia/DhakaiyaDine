import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen>
    with SingleTickerProviderStateMixin {
  static const _yellow = Color(0xFFF4B400);
  static const _navy = Color(0xFF1F2937);
  static const _bg = Color(0xFFFAF6EA);

  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  List<Map<String, dynamic>> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) {
      setState(() => _loading = false);
      _ctrl.forward();
      return;
    }
    try {
      final res = await Supabase.instance.client
          .from('addresses')
          .select()
          .eq('user_id', uid)
          .order('is_default', ascending: false);
      if (mounted) {
        setState(() {
          _addresses = List<Map<String, dynamic>>.from(res);
          _loading = false;
        });
        _ctrl.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _ctrl.forward();
      }
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    try {
      await Supabase.instance.client
          .from('addresses')
          .delete()
          .eq('id', addressId);
      await _loadAddresses();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Address deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Saved Addresses'),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _yellow))
          : _addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_rounded, size: 64, color: _yellow),
                  const SizedBox(height: 16),
                  const Text(
                    'No Addresses Saved',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _navy,
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fade,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _addresses.length,
                itemBuilder: (ctx, i) => _AddressCard(
                  address: _addresses[i],
                  onDelete: () => _deleteAddress(_addresses[i]['id']),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _yellow,
        onPressed: () {},
        child: const Icon(Icons.add, color: _navy),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address, required this.onDelete});

  final Map<String, dynamic> address;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final label = address['label'] as String? ?? 'Home';
    final street = address['street'] as String? ?? '';
    final city = address['city'] as String? ?? '';
    final isDefault = address['is_default'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDefault
            ? Border.all(color: const Color(0xFFF4B400), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: const Color(0xFFF4B400),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  if (isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4B400).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Default',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF4B400),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              PopupMenuButton(
                itemBuilder: (ctx) => [
                  const PopupMenuItem(child: Text('Edit')),
                  PopupMenuItem(
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$street, $city',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF3E4A63),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
