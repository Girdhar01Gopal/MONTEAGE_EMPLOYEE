import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; 

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
            
            _StatsCard(),
            SizedBox(height: 20.h),
            
            Expanded(
              child: _TaskList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskForm(context),
        backgroundColor: const Color(0xFF6A3027),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  
  void _showTaskForm(BuildContext context) {
    Get.bottomSheet(
      TaskForm(),
      isScrollControlled: true, 
      backgroundColor: Colors.transparent, 
    );
  }
}


class _StatsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    int total = 10;
    int pending = 5;
    int completed = 3;
    int missed = 2;

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
          _StatTile(label: "Total", value: "$total", icon: Icons.view_agenda_rounded),
          _StatTile(label: "Pending", value: "$pending", icon: Icons.schedule_rounded),
          _StatTile(label: "Completed", value: "$completed", icon: Icons.check_circle_rounded),
          _StatTile(label: "Missed", value: "$missed", icon: Icons.cancel_rounded),
        ],
      ),
    );
  }
}


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


class _TaskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      
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
    
    return [
      {
        "title": "Task 1",
        "description": "Task description goes here.",
        "due_date": "2026-04-30",
        "status": "Pending",
      },
      
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


class TaskForm extends StatefulWidget {
  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final TextEditingController _dueDateController = TextEditingController();
  String _selectedEmployee = "1";
  String _priority = "Medium";
  String _recurrence = "Weekly";

  DateTime? _dueDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: SingleChildScrollView( 
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7, 
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Padding(
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
                
                DropdownButtonFormField<String>(
                  value: _selectedEmployee,
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
                  onChanged: (value) {
                    setState(() {
                      _selectedEmployee = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Select Employee",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.h),
                
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
                
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _dueDateController,
                      decoration: InputDecoration(
                        labelText: "Due Date",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                
                Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text("Recurrence:"),
    SingleChildScrollView( 
      scrollDirection: Axis.horizontal, 
      child: Row(
        children: [
          Radio<String>(
            value: "Daily",
            groupValue: _recurrence,
            onChanged: (value) {
              setState(() {
                _recurrence = value!;
              });
            },
          ),
          Text("Daily"),
          SizedBox(width: 16), 
          Radio<String>(
            value: "Weekly",
            groupValue: _recurrence,
            onChanged: (value) {
              setState(() {
                _recurrence = value!;
              });
            },
          ),
          Text("Weekly"),
          SizedBox(width: 16),
          Radio<String>(
            value: "Alternate",
            groupValue: _recurrence,
            onChanged: (value) {
              setState(() {
                _recurrence = value!;
              });
            },
          ),
          Text("Alternate"),
          SizedBox(width: 16),
          Radio<String>(
            value: "Monthly",
            groupValue: _recurrence,
            onChanged: (value) {
              setState(() {
                _recurrence = value!;
              });
            },
          ),
          Text("Monthly"),
        ],
      ),
    ),
  ],
),
                SizedBox(height: 16.h),
                
                Row(
                  children: [
                    Radio<String>(
                      value: "High",
                      groupValue: _priority,
                      onChanged: (value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                    ),
                    Text("High Priority"),
                    Radio<String>(
                      value: "Medium",
                      groupValue: _priority,
                      onChanged: (value) {
                        setState(() {
                          _priority = value!;
                        });
                      },
                    ),
                    Text("Medium Priority"),
                  ],
                ),
                SizedBox(height: 16.h),
                
                ElevatedButton(
                  onPressed: _submitTask,
                  child: Text("Assign Task"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate){
      setState(() {
        _dueDate = picked;
        _dueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }  
  }

  
  void _submitTask() {
    
    print("Task Assigned");
    print("Employee: $_selectedEmployee");
    print("Due Date: ${_dueDateController.text}");
    print("Priority: $_priority");
    print("Recurrence: $_recurrence");

    
    Get.back();
  }
}