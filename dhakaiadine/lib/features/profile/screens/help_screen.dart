import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen>
    with SingleTickerProviderStateMixin {
  static const _yellow = Color(0xFFF4B400);
  static const _navy = Color(0xFF1F2937);
  static const _bg = Color(0xFFFAF6EA);

  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('FAQ'),
              const SizedBox(height: 12),
              _FAQItem(
                question: 'How do I track my order?',
                answer:
                    'Go to Order History from your profile and tap "View Details" on any order.',
              ),
              _FAQItem(
                question: 'Can I cancel my order?',
                answer:
                    'You can cancel orders that are still pending. Visit Order History and select cancel.',
              ),
              _FAQItem(
                question: 'What payment methods are accepted?',
                answer: 'We accept Cash, Card, and Mobile Banking payments.',
              ),
              _FAQItem(
                question: 'How do I add a new delivery address?',
                answer:
                    'Go to Saved Addresses and tap the + button to add a new address.',
              ),
              const SizedBox(height: 28),
              _buildSection('Contact Us'),
              const SizedBox(height: 12),
              _ContactCard(
                icon: Icons.restaurant_rounded,
                label: 'Call Restaurant',
                value: '+880 1234 567890',
                onTap: () => _launchPhone('+8801234567890'),
              ),
              const SizedBox(height: 12),
              _ContactCard(
                icon: Icons.email_rounded,
                label: 'Email Support',
                value: 'support@dhakaia.com',
                onTap: () => _launchEmail('support@dhakaia.com'),
              ),
              const SizedBox(height: 28),
              _buildSection('About App'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                    const Text(
                      'Dhakaia Dine',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _navy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Version 1.0.0',
                      style: TextStyle(fontSize: 14, color: Color(0xFF7A8599)),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Premium restaurant delivery experience at your fingertips.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF3E4A63),
                        height: 1.6,
                      ),
                    ),
                    const Text(
                      'Created by Sowrav Dey & Anika Tasnia Sultana',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF3E4A63),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '© 2026 Dhakaia Dine. All rights reserved.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title) => Text(
    title,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: _navy,
    ),
  );
}

class _FAQItem extends StatefulWidget {
  const _FAQItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          widget.question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              widget.answer,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF7A8599),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF4B400).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFF4B400), size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7A8599),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFFBBBBBB),
            ),
          ],
        ),
      ),
    );
  }
}
