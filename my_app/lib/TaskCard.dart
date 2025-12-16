import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatefulWidget {
  final QueryDocumentSnapshot task;

  const TaskCard({super.key, required this.task});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;
  bool isImportant = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();

    // Initialize isImportant from Firestore data
    final data = widget.task.data() as Map<String, dynamic>;
    isImportant = data['isImportant'] ?? false;
  }

  void _startCountdown() {
    final data = widget.task.data() as Map<String, dynamic>;
    final Timestamp? dueTimestamp = data['dueDate'];

    if (dueTimestamp != null) {
      final due = dueTimestamp.toDate();
      final now = DateTime.now();
      final diff = due.difference(now);

      _remaining = diff.isNegative ? Duration.zero : diff;

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        final now = DateTime.now();
        final diff = due.difference(now);

        if (mounted) {
          setState(() {
            _remaining = diff.isNegative ? Duration.zero : diff;
          });
        }
      });
    }
  }

  // Toggle Important
  void toggleImportant() async {
    setState(() {
      isImportant = !isImportant;
    });

    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(widget.task.id)
        .update({'isImportant': isImportant});
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.task.data() as Map<String, dynamic>;

    final String title = data['title'] ?? 'No title';
    final String description = data['description'] ?? '';
    final String category = data['category'] ?? 'General';
    final String priority = data['priority'] ?? 'medium';
    final Timestamp? dueTimestamp = data['dueDate'];
    final String dueDate = dueTimestamp != null
        ? DateFormat('dd MMM, yyyy – HH:mm').format(dueTimestamp.toDate())
        : 'No due date';
    final String status = data['status'] ?? 'todo';

    // Priority color
    Color priorityColor;
    switch (priority.toLowerCase()) {
      case 'high':
        priorityColor = Colors.red;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      case 'low':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.orange;
    }

    // Card color by status
    Color cardColor;
    switch (status) {
      case 'todo':
        cardColor = Colors.white;
        break;
      case 'inprogress':
        cardColor = Colors.lightBlue.shade50;
        break;
      case 'completed':
        cardColor = Colors.grey.shade200;
        break;
      default:
        cardColor = Colors.white;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Row with Star
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isImportant ? Icons.star : Icons.star_border,
                    color: isImportant ? Colors.yellow[700] : Colors.grey,
                  ),
                  onPressed: toggleImportant,
                  tooltip: 'Mark as Important',
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Description
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 10),

            // Countdown Timer
            if (dueTimestamp != null && status != 'completed')
              Text(
                _remaining == Duration.zero
                    ? "Time’s Up!"
                    : "Time Remaining: ${_formatDuration(_remaining)}",
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: _remaining.inHours < 1 ? Colors.red : Colors.blueGrey,
                ),
              ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Category
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),

                // Priority
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    priority.toUpperCase(),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: priorityColor),
                  ),
                ),

                // Due date
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      dueDate,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),

                // Start / Complete Button
                if (status == 'todo')
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('tasks')
                          .doc(widget.task.id)
                          .update({
                        'status': 'inprogress',
                        'startedAt': FieldValue.serverTimestamp(),
                        'updatedAt': FieldValue.serverTimestamp(),
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Start'),
                  )
                else if (status == 'inprogress')
                  IconButton(
                    icon: const Icon(Icons.check_circle,
                        color: Colors.green, size: 26),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('tasks')
                          .doc(widget.task.id)
                          .update({
                        'status': 'completed',
                        'isCompleted': true,
                        'completedAt': FieldValue.serverTimestamp(),
                      });
                    },
                    tooltip: 'Mark as done',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
