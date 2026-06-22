import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2E4),
      appBar: AppBar(
        title: const Text('Support'),
        backgroundColor: const Color(0xFFF8F2E4),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How can we help?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _SupportCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Chat with us',
                    subtitle: 'Get instant help from our support team',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _SupportCard(
                    icon: Icons.phone_outlined,
                    title: 'Call us',
                    subtitle: '+880 1700-000000',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _SupportCard(
                    icon: Icons.email_outlined,
                    title: 'Email us',
                    subtitle: 'support@dhakaiadine.com',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _SupportCard(
                    icon: Icons.help_outline_rounded,
                    title: 'FAQ',
                    subtitle: 'Find answers to common questions',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFFFC107), size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF757575)),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Color(0xFF757575),
        ),
        onTap: onTap,
      ),
    );
  }
}