import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_app/ImportantPage.dart';
import 'package:my_app/SettingPage.dart';
import 'package:my_app/TaskCard.dart';
import 'package:my_app/AddTask.dart';

class HomePage extends StatefulWidget {
  final User? user;
  const HomePage({super.key, this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late final User? user;

  @override
  void initState() {
    super.initState();
    user = widget.user ?? FirebaseAuth.instance.currentUser;
  }

Widget _getPage(int index) {
  switch (index) {
    case 0:
      return const MyTasksPage();
    case 1:
      return ImportantPage(user: user);
    case 2:
      return SettingsPage(user: user);
    default:
      return const MyTasksPage();
  }
}


  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_outlined),
            label: 'My Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            label: 'Important',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ------------------------------
// My Tasks Page
// ------------------------------
class MyTasksPage extends StatelessWidget {
  const MyTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
appBar: AppBar(
  elevation: 0,
  backgroundColor: Colors.pink.shade100, // <-- background color
  title: const Text(
    'My Tasks',
    style: TextStyle(
      color: Colors.white,           // text color contrasts with background
      fontWeight: FontWeight.w600,
      fontFamily: 'Cursive',         // handwriting style
      fontSize: 24,
      shadows: [
        Shadow(
          blurRadius: 2,
          color: Colors.black26,
          offset: Offset(1, 1),
        ),
      ],
    ),
  ),
  centerTitle: true,
  actions: [
    IconButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddTaskPage()),
        );
      },
      icon: const Icon(Icons.add, color: Colors.white),
    ),
  ],
  bottom: const TabBar(
    labelColor: Colors.white,
    unselectedLabelColor: Colors.white70,
    indicatorColor: Colors.white,
    tabs: [
      Tab(text: 'To Do'),
      Tab(text: 'In Progress'),
      Tab(text: 'Completed'),
    ],
  ),
),

        body: const TabBarView(
          children: [
            ToDoTab(),
            InProgressTab(),
            CompletedTab(),
          ],
        ),
      ),
    );
  }
}

class ToDoTab extends StatefulWidget {
  const ToDoTab({super.key});

  @override
  State<ToDoTab> createState() => _ToDoTabState();
}

class _ToDoTabState extends State<ToDoTab> {
  late final User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text('Please log in to view your tasks'));
    }

    final uid = user!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: uid)
          .where('status', whereIn: ['todo', 'inprogress'])
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading tasks: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No tasks yet'));
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
    );
  }
}


// ------------------------------
// In Progress Tab
// ------------------------------
class InProgressTab extends StatelessWidget {
  const InProgressTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('Please log in to view your tasks'),
      );
    }

    final uid = user.uid; // get the current user's UID


    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: uid) // now it's defined
          .where('status', isEqualTo: 'inprogress')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading tasks: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No tasks in progress'));
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
    );
  }
}

// ------------------------------
// Completed Tab
// ------------------------------
class CompletedTab extends StatelessWidget {
  const CompletedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Check if user is logged in
    if (user == null) {
      return const Center(
        child: Text('Please log in to view completed tasks'),
      );
    }

    final String uid = user.uid; // safely get UID

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: uid) // filter tasks for current user
          .where('status', isEqualTo: 'completed')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading tasks: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No completed tasks'));
        }

        final tasks = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskCard(task: task);
          },
        );
      },
    );
  }
}
