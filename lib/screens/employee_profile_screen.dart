import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class EmployeeProfileScreen extends GetView<EmployeeProfileController> {
  const EmployeeProfileScreen({super.key});

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF6C63FF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _badge({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        title: const Text("Employee Profile", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => controller.fetchProfile(showSuccess: true),
            icon: const Icon(Icons.refresh, color: Colors.white),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final p = controller.profile.value;
        if (p == null) {
          return Center(
            child: ElevatedButton(
              onPressed: controller.fetchProfile,
              child: const Text("Retry"),
            ),
          );
        }

        final u = p.user;
        final imgUrl = controller.fullImageUrl(u.profileImage);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    // ✅ Avatar + Edit Icon
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: ClipOval(
                            child: imgUrl.isEmpty
                                ? const Icon(Icons.person, color: Colors.white, size: 40)
                                : Image.network(
                              imgUrl,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                              const Icon(Icons.person, color: Colors.white, size: 40),
                            ),
                          ),
                        ),

                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: InkWell(
                            onTap: controller.goToFaceRegister, // ✅ opens face register
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                              ),
                              child: const Icon(Icons.edit, size: 18, color: Color(0xFF6C63FF)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.titleCase(
                              u.fullName.isNotEmpty ? u.fullName : "${u.firstName} ${u.lastName}",
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            controller.titleCase(u.department),
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _badge(
                                text: u.isActive ? "ACTIVE" : "INACTIVE",
                                color: u.isActive ? Colors.green : Colors.red,
                              ),
                              _badge(
                                text: u.isFaceRegistered ? "FACE REGISTERED" : "FACE NOT REGISTERED",
                                color: u.isFaceRegistered ? Colors.green : Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 14),

              _infoTile(icon: Icons.badge, title: "Employee ID", value: u.employeeId),
              const SizedBox(height: 10),
              _infoTile(icon: Icons.person_outline, title: "Username", value: controller.titleCase(u.username)),
              const SizedBox(height: 10),
              _infoTile(icon: Icons.email_outlined, title: "Email", value: u.email),
              const SizedBox(height: 10),
              _infoTile(icon: Icons.account_circle_outlined, title: "User ID", value: u.id.toString()),
              const SizedBox(height: 10),

              _infoTile(
                icon: Icons.face_retouching_natural,
                title: "Face Registered At",
                value: controller.formatDateTimeIndian(u.faceRegisteredAt),
              ),
              const SizedBox(height: 10),

              _infoTile(
                icon: Icons.calendar_today,
                title: "Date Joined",
                value: controller.formatDateTimeIndian(u.dateJoined),
              ),
              const SizedBox(height: 14),
            ],
          ),
        );
      }),
    );
  }
}
