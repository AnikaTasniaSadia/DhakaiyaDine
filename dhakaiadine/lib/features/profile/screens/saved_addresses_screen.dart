import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  static const _navy = Color(0xFF1F2937);
  static const _yellow = Color(0xFFF4B400);
  static const _bg = Color(0xFFFAF6EA);

  final TextEditingController _labelCtrl = TextEditingController();
  final TextEditingController _detailsCtrl = TextEditingController();
  String _selectedType = 'home';

  @override
  void dispose() {
    _labelCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  void _showAddressDialog(BuildContext context, {Map<String, dynamic>? addressToEdit}) {
    final isEditing = addressToEdit != null;
    if (isEditing) {
      _labelCtrl.text = addressToEdit['label'] ?? '';
      _detailsCtrl.text = addressToEdit['details'] ?? '';
      _selectedType = addressToEdit['type'] ?? 'home';
    } else {
      _labelCtrl.clear();
      _detailsCtrl.clear();
      _selectedType = 'home';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: _bg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                isEditing ? 'Edit Address' : 'Add New Address',
                style: const TextStyle(fontWeight: FontWeight.w800, color: _navy, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Address Label', style: TextStyle(fontWeight: FontWeight.w700, color: _navy, fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFECECEC)),
                      ),
                      child: TextField(
                        controller: _labelCtrl,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Grandma\'s House',
                          border: InputBorder.none,
                          hintStyle: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Address Details', style: TextStyle(fontWeight: FontWeight.w700, color: _navy, fontSize: 13)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFECECEC)),
                      ),
                      child: TextField(
                        controller: _detailsCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'House no, Road no, Area, City',
                          border: InputBorder.none,
                          hintStyle: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Type', style: TextStyle(fontWeight: FontWeight.w700, color: _navy, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTypeChip(setDialogState, 'home', Icons.home_rounded),
                        const SizedBox(width: 8),
                        _buildTypeChip(setDialogState, 'office', Icons.business_rounded),
                        const SizedBox(width: 8),
                        _buildTypeChip(setDialogState, 'other', Icons.place_rounded),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: _navy, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_labelCtrl.text.trim().isEmpty || _detailsCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                      return;
                    }

                    if (isEditing) {
                      await ProfileService.instance.editAddress(
                        addressToEdit['id']!,
                        _labelCtrl.text.trim(),
                        _detailsCtrl.text.trim(),
                        _selectedType,
                      );
                    } else {
                      await ProfileService.instance.addAddress(
                        _labelCtrl.text.trim(),
                        _detailsCtrl.text.trim(),
                        _selectedType,
                      );
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(isEditing ? 'Address updated' : 'Address added')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _yellow,
                    foregroundColor: _navy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(isEditing ? 'Save' : 'Add', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTypeChip(StateSetter setDialogState, String type, IconData icon) {
    final isSelected = _selectedType == type;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? _navy : const Color(0xFF6B7280)),
          const SizedBox(width: 4),
          Text(
            type.toUpperCase(),
            style: TextStyle(
              color: isSelected ? _navy : const Color(0xFF6B7280),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          setDialogState(() {
            _selectedType = type;
          });
        }
      },
      selectedColor: _yellow,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: ProfileService.instance,
      child: Consumer<ProfileService>(
        builder: (context, service, _) {
          final addresses = service.addresses;

          return Scaffold(
            backgroundColor: _bg,
            appBar: AppBar(
              title: const Text('Saved Addresses', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              backgroundColor: Colors.white,
              foregroundColor: _navy,
              elevation: 0.5,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: addresses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_off_outlined, size: 72, color: Color(0xFF9CA3AF)),
                              const SizedBox(height: 16),
                              const Text(
                                'No Addresses Saved',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _navy),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Save your home or office address for faster checkout.',
                                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: addresses.length,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          itemBuilder: (context, index) {
                            final addr = addresses[index];
                            IconData leadingIcon = Icons.place_rounded;
                            if (addr['type'] == 'home') leadingIcon = Icons.home_rounded;
                            if (addr['type'] == 'office') leadingIcon = Icons.business_rounded;

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: _bg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(leadingIcon, color: _yellow, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              addr['label'] ?? 'Address',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                                color: _navy,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.map_rounded, color: Colors.green, size: 14),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          addr['details'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: Color(0xFF4B5563),
                                            fontWeight: FontWeight.w500,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_rounded, color: _navy, size: 20),
                                    onPressed: () => _showAddressDialog(context, addressToEdit: addr),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                    onPressed: () {
                                      service.deleteAddress(addr['id']!);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Address deleted')),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFECECEC))),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddressDialog(context),
                      icon: const Icon(Icons.add_location_alt_rounded, size: 20),
                      label: const Text('Add New Address', style: TextStyle(fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _yellow,
                        foregroundColor: _navy,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
