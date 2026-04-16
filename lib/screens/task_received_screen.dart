import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskReceivedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1ED),
      appBar: AppBar(
        title: Text(
          "Tasks Assigned to You",
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
    );
  }

  
  Widget _StatsCard() {
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

  
  Widget _StatTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
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

  
  Widget _TaskList() {
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
        'title': 'Complete Monthly Report',
        'description': 'Prepare and submit the monthly report by end of day.',
      },
     
    ];

    
    
  }

  
  Widget _TaskCard(Map<String, dynamic> task) {
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
          
        },
      ),
    );
  }
}