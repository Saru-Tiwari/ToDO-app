import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // for formatting dates

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool isCompleted = false;

  // Pick date
  Future<void> _pickDate() async {
    final DateTime today = DateTime.now();
    final DateTime oneYearLater = DateTime(today.year + 1, today.month, today.day);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: oneYearLater,
      helpText: 'Select Due Date',
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  // Pick time
  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  // Add task
  void addTask() async {
    try {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select both date and time')),
        );
        return;
      }

      final dueDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await FirebaseFirestore.instance.collection('tasks').add({
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'title': titleController.text,
        'description': descriptionController.text,
        'isCompleted': isCompleted,
        'status': isCompleted ? 'completed' : 'todo',
        'timestamp': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'dueDate': Timestamp.fromDate(dueDateTime),
        'priority': priorityController.text.isNotEmpty
            ? priorityController.text
            : 'medium',
        'category': categoryController.text.isNotEmpty
            ? categoryController.text
            : 'general',
      });

      // Clear fields
      titleController.clear();
      descriptionController.clear();
      priorityController.clear();
      categoryController.clear();
      _selectedDate = null;
      _selectedTime = null;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Task added successfully')));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: PreferredSize(
  preferredSize: const Size.fromHeight(100), // increase height to match MyTasksPage
  child: AppBar(
    elevation: 0,
    backgroundColor: Colors.pink.shade100, // same pink shade
    centerTitle: true,
    title: const Text(
      'Add Task',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontFamily: 'Cursive', // cursive handwriting
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
  ),
),

    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Title
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              labelStyle: const TextStyle(fontWeight: FontWeight.w500),
              filled: true,
              fillColor: Colors.pink.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Description
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: const TextStyle(fontWeight: FontWeight.w500),
              filled: true,
              fillColor: Colors.pink.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 15),

          // Date & Time
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      filled: true,
                      fillColor: Colors.pink.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _selectedDate == null
                          ? 'Select Date'
                          : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: _pickTime,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Due Time',
                      filled: true,
                      fillColor: Colors.pink.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: const Icon(Icons.access_time),
                    ),
                    child: Text(
                      _selectedTime == null
                          ? 'Select Time'
                          : _selectedTime!.format(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Priority
          TextField(
            controller: priorityController,
            decoration: InputDecoration(
              labelText: 'Priority (low, medium, high)',
              labelStyle: const TextStyle(fontWeight: FontWeight.w500),
              filled: true,
              fillColor: Colors.pink.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Category
          TextField(
            controller: categoryController,
            decoration: InputDecoration(
              labelText: 'Category',
              labelStyle: const TextStyle(fontWeight: FontWeight.w500),
              filled: true,
              fillColor: Colors.pink.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Completed Checkbox
          Row(
            children: [
              const Text('Completed:', style: TextStyle(fontWeight: FontWeight.w500)),
              Checkbox(
                value: isCompleted,
                onChanged: (value) {
                  setState(() {
                    isCompleted = value!;
                  });
                },
                activeColor: Colors.pink.shade300,
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Add Task Button
          ElevatedButton(
            onPressed: addTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cursive', // cursive font for button text
              ),
            ),
            child: const Text('Add Task'),
          ),
        ],
      ),
    ),
  );
}
}