import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskGivenScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1ED),
      appBar: AppBar(
        title: Text(
          "Tasks You Assigned",
          style: GoogleFonts.manrope(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF241917),
          ),
        ),
        backgroundColor: const Color(0xFFF6F1ED),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Stats cards for Total, Pending, Completed, and Missed tasks
            _StatsCard(),
            SizedBox(height: 20.h),
            // List of tasks given
            Expanded(
              child: _TaskList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskForm(context),
        backgroundColor: const Color(0xFF6A3027),
        child: Icon(Icons.add),
      ),
    );
  }

  // Method to open the task assignment form
  void _showTaskForm(BuildContext context) {
    Get.bottomSheet(
      TaskForm(),
      isScrollControlled: true,
    );
  }
}

// Stats card for total, pending, completed, and missed tasks
class _StatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatTile(label: "Total", value: "10", icon: Icons.view_agenda_rounded),
          _StatTile(label: "Pending", value: "5", icon: Icons.schedule_rounded),
          _StatTile(label: "Completed", value: "3", icon: Icons.check_circle_rounded),
          _StatTile(label: "Missed", value: "2", icon: Icons.cancel_rounded),
        ],
      ),
    );
  }
}

// Stat tile used in the overview cards
class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 30.sp, color: const Color(0xFF6A3027)),
        SizedBox(height: 8.h),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF241917),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8B7D77),
          ),
        ),
      ],
    );
  }
}

// Task List to show all tasks assigned
class _TaskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Replace with real data fetching logic (API call)
      future: _fetchTasks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final tasks = snapshot.data as List<Map<String, dynamic>>;

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return _TaskCard(task);
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchTasks() async {
    // Fetch tasks from API (replace with real API call)
    return [
      {
        "title": "Task 1",
        "description": "Task description goes here.",
        "due_date": "2026-04-30",
        "status": "Pending",
      },
      // Add more tasks here
    ];
  }
}

// Task card to show each task in the list
class _TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;

  const _TaskCard(this.task);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: ListTile(
        title: Text(
          task['title'],
          style: GoogleFonts.manrope(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF241917),
          ),
        ),
        subtitle: Text(
          task['description'],
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: const Color(0xFF8B7D77),
          ),
        ),
        trailing: Icon(Icons.more_vert, color: const Color(0xFF6A3027)),
        onTap: () {
          // Handle task edit or details
        },
      ),
    );
  }
}

// Task assignment form when user clicks the FAB to assign a task
class TaskForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Assign New Task",
            style: GoogleFonts.manrope(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF241917),
            ),
          ),
          SizedBox(height: 16.h),
          // Employee Dropdown
          DropdownButtonFormField<String>(
            items: [
              DropdownMenuItem(
                child: Text("Employee 1"),
                value: "1",
              ),
              DropdownMenuItem(
                child: Text("Employee 2"),
                value: "2",
              ),
            ],
            onChanged: (value) {},
            decoration: InputDecoration(
              labelText: "Select Employee",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16.h),
          // Title and Description
          TextField(
            decoration: InputDecoration(
              labelText: "Task Title",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Task Description",
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16.h),
          // Due Date Picker
          GestureDetector(
            onTap: () {
              // Handle date picker
            },
            child: AbsorbPointer(
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Due Date",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Recurrence Options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Recurrence:"),
              Row(
                children: [
                  Radio(value: "Daily", groupValue: "Weekly", onChanged: (value) {}),
                  Text("Daily"),
                  Radio(value: "Weekly", groupValue: "Weekly", onChanged: (value) {}),
                  Text("Weekly"),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Priority
          Row(
            children: [
              Radio(value: "High", groupValue: "Medium", onChanged: (value) {}),
              Text("High Priority"),
              Radio(value: "Medium", groupValue: "Medium", onChanged: (value) {}),
              Text("Medium Priority"),
            ],
          ),
          SizedBox(height: 16.h),
          // Submit Button
          ElevatedButton(
            onPressed: () {
              // Submit task logic
            },
            child: Text("Assign Task"),
          ),
        ],
      ),
    );
  }
}