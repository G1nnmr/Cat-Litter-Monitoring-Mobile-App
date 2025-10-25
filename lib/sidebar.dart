import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'login.dart';

class Sidebar extends StatelessWidget {
  final String username;
  final String email;

  const Sidebar({super.key, required this.username, required this.email});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(username, style: TextStyle(fontSize: 18.sp)),
            accountEmail: Text(email, style: TextStyle(fontSize: 16.sp)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : '',
                style: TextStyle(fontSize: 24.sp, color: Colors.teal),
              ),
            ),
            decoration: const BoxDecoration(color: Colors.teal),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.teal),
            title: Text("Settings", style: TextStyle(fontSize: 18.sp)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.teal),
            title: Text("Profile", style: TextStyle(fontSize: 18.sp)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.teal),
            title: Text("Sign Out", style: TextStyle(fontSize: 18.sp)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
