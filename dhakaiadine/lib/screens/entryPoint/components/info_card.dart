import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.name, required this.bio});

  final String name, bio;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFFFC107),
        child: Icon(CupertinoIcons.person, color: Color(0xFF212121)),
      ),
      title: Text(name, style: const TextStyle(color: Color(0xFF212121)), maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(bio, style: const TextStyle(color: Color(0xFF757575)), maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}
