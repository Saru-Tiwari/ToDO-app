import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/TaskCard.dart';

class ImportantPage extends StatefulWidget {
  final User? user; // add this
  const ImportantPage({super.key, this.user});

  @override
  State<ImportantPage> createState() => _ImportantPageState();
}

class _ImportantPageState extends State<ImportantPage> {
  late User? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    user = widget.user; // use the passed user
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
            'Please log in to view important tasks',
            style: TextStyle(fontSize: 16, fontFamily: 'Cursive'),
          ),
        ),
      );
    }

    final String uid = user!.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: AppBar(
          backgroundColor: Colors.orange.shade100,
          elevation: 0,
          centerTitle: true,
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(height: 20),
              Text(
                'Important Tasks ⭐',
                style: TextStyle(
                  fontFamily: 'Cursive',
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                  shadows: [
                    Shadow(
                      blurRadius: 2,
                      color: Colors.black26,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Keep your priorities in check!',
                style: TextStyle(
                  fontFamily: 'Cursive',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 119, 79, 27),
                ),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('userId', isEqualTo: uid)
            .where('isImportant', isEqualTo: true)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading tasks: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.star, size: 80, color: Colors.orange),
                  SizedBox(height: 16),
                  Text(
                    'No important tasks yet.',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Cursive',
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            );
          }

          final tasks = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return TaskCard(task: tasks[index]);
            },
          );
        },
      ),
    );
  }
}
