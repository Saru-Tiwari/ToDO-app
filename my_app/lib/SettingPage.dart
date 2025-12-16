import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/EditProfile.dart';
import 'package:my_app/login.dart';

class SettingsPage extends StatefulWidget {
  final User? user;
  const SettingsPage({super.key, this.user});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String phone = 'Not added yet';
  bool isLoading = true;
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // wait for Firebase to restore the user if not passed
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {
          user = FirebaseAuth.instance.currentUser;
          isLoading = false;
        });
      });
    } else {
      isLoading = false;
      _loadUserPhone();
    }
  }

  Future<void> _loadUserPhone() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()?['phone'] != null) {
        setState(() {
          phone = doc.data()?['phone'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please log in to view settings',
            style: TextStyle(fontSize: 16, fontFamily: 'Cursive'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white, // White page background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100), // same height as Important Tasks
        child: AppBar(
          backgroundColor: Colors.purple.shade100, // Light purple AppBar
          elevation: 0,
          centerTitle: true,
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Settings',
                style: TextStyle(
                  fontFamily: 'Cursive',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                  shadows: [
                    Shadow(
                      blurRadius: 2,
                      color: Colors.black26,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage your profile & preferences!',
                style: TextStyle(
                  fontFamily: 'Cursive',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.purple.shade50,
                  child: const Icon(Icons.person, size: 60, color: Colors.deepPurple),
                ),
                const SizedBox(height: 30),

                // Email Card (read-only)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.email, color: Colors.deepPurple),
                    title: const Text('Email'),
                    subtitle: Text(user!.email ?? 'Not added'),
                  ),
                ),
                const SizedBox(height: 20),

                // Phone Card (editable)
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.phone, color: Colors.deepPurple),
                    title: const Text('Phone'),
                    subtitle: Text(phone),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.deepPurple),
                      onPressed: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const EditProfilePage()));
                        _loadUserPhone(); // refresh updated phone
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 80), // leave space for logout button
              ],
            ),
          ),

          // Logout button at bottom-right
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout, size: 16, color: Colors.white),
              label: const Text('Logout', style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 197, 68, 59),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
