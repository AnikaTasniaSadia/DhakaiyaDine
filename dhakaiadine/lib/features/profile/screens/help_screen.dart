import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen>
    with SingleTickerProviderStateMixin {
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

  void _launchEmail(String email) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening email client to: $email')),
    );
  }

  void _launchPhone(String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling support line: $phone')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FAQ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                ),
              ),
              const SizedBox(height: 12),
              const _FAQItem(
                question: 'How do I track my order?',
                answer: 'Go to Order History from your profile and tap "View Details" on any order.',
              ),
              const _FAQItem(
                question: 'Can I cancel my order?',
                answer: 'You can cancel orders that are still pending. Visit Order History and select cancel.',
              ),
              const _FAQItem(
                question: 'What payment methods are accepted?',
                answer: 'We accept Cash, Card, and Mobile Banking payments.',
              ),
              const _FAQItem(
                question: 'How do I add a new delivery address?',
                answer: 'Go to Saved Addresses and tap the + button to add a new address.',
              ),
              const SizedBox(height: 28),
              const Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                ),
              ),
              const SizedBox(height: 12),
              _ContactCard(
                icon: Icons.restaurant_rounded,
                label: 'Call Restaurant',
                value: '+880 1700 000000',
                onTap: () => _launchPhone('+8801700000000'),
              ),
              const SizedBox(height: 12),
              _ContactCard(
                icon: Icons.email_rounded,
                label: 'Email Support',
                value: 'support@dhakaiadine.com',
                onTap: () => _launchEmail('support@dhakaiadine.com'),
              ),
              const SizedBox(height: 28),

              const Text(
                'About Dhakaia Dine',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// Logo & App Name
                    Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4B400).withOpacity(.12),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.restaurant_menu_rounded,
                            size: 30,
                            color: Color(0xFFF4B400),
                          ),
                        ),

                        const SizedBox(width: 16),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Dhakaia Dine",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1F2937),
                                ),
                              ),

                              SizedBox(height: 4),

                              Text(
                                "Smart Restaurant Experience",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF7A8599),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        "Dhakaia Dine is a smart restaurant management and food ordering application developed as a Final Year Project using Flutter and Supabase.\n\nIt offers Home Delivery, Smart Dine-In Table Ordering, Real-Time Order Tracking, Digital Token Collection, and Restaurant Management features to provide a modern dining experience.",
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.7,
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Developed By",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const _DeveloperTile(
                      icon: Icons.code_rounded,
                      name: "Sowrav Dey",
                      role: "Lead Developer",
                      description: "Flutter • Backend • UI/UX",
                    ),

                    const SizedBox(height: 10),

                    const _DeveloperTile(
                      icon: Icons.design_services_rounded,
                      name: "Anika Tasnia Sadia",
                      role: "Co-Developer",
                      description: "System Analysis • Testing • Documentation",
                    ),

                    const SizedBox(height: 22),

                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TechChip("Flutter"),
                        _TechChip("Supabase"),
                        _TechChip("Material 3"),
                        _TechChip("Lottie"),
                        _TechChip("PostgreSQL"),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Divider(),

                    const SizedBox(height: 10),

                    Center(
                      child: Column(
                        children: [
                          Text(
                            "Version 1.0.0",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF4B400),
                            ),
                          ),

                          SizedBox(height: 6),

                          Text(
                            "© 2026 Dhakaia Dine Team",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7A8599),
                            ),
                          ),
                        ],
                      ),
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
}

class _FAQItem extends StatelessWidget {
  const _FAQItem({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF7A8599),
                fontWeight: FontWeight.w500,
                height: 1.5,
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

  static const _yellow = Color(0xFFF4B400);
  static const _navy = Color(0xFF1F2937);

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
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _yellow.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _yellow, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7A8599),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: _navy,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFFBBBBBB),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeveloperTile extends StatelessWidget {
  const _DeveloperTile({
    required this.icon,
    required this.name,
    required this.role,
    required this.description,
  });

  final IconData icon;
  final String name;
  final String role;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF4B400).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFF4B400), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF4B400),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF7A8599),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  const _TechChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4B400).withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF4B400).withOpacity(0.25),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF4B400),
        ),
      ),
    );
  }
}
