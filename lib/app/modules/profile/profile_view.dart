import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../routes/app_routes.dart';
import '../auth/change_password_view.dart'; // New file import

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final AuthController authController = Get.find<AuthController>();
  final RxMap<String, dynamic> userData = <String, dynamic>{}.obs;

  @override
  Widget build(BuildContext context) {
    if (authController.user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(authController.user!.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) userData.value = snapshot.data()!;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () => Get.to(() => ChangePasswordView()),
          ),
        ],
      ),
      body: Obx(() {
        if (userData.value.isEmpty) return const Center(child: CircularProgressIndicator());

        final data = userData.value;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: data['avatar'] != null
                        ? NetworkImage(data['avatar'])
                        : const NetworkImage('https://i.pravatar.cc/150'),
                    backgroundColor: Colors.grey[300],
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.lightGreen[400],
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        onPressed: authController.uploadAvatar,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _infoCard(Icons.email, 'Email', data['email'] ?? ''),
            _infoCard(Icons.person, 'Full Name', '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'),
            _infoCard(Icons.phone, 'Mobile', data['mobile'] ?? 'Not set'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(Routes.editProfile),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: authController.logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        );
      }),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.lightGreen[400]),
        title: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(label),
      ),
    );
  }
}
