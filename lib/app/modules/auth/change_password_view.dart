import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class ChangePasswordView extends StatelessWidget {
  ChangePasswordView({super.key});

  final AuthController authController = Get.find<AuthController>();
  final oldPass = TextEditingController();
  final newPass = TextEditingController();
  final confirmPass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _field(oldPass, 'Old Password', true),
            const SizedBox(height: 12),
            _field(newPass, 'New Password', true),
            const SizedBox(height: 12),
            _field(confirmPass, 'Confirm Password', true),
            const SizedBox(height: 24),
            Obx(() => ElevatedButton(
              onPressed: authController.isLoading.value ? null : () async {
                if (newPass.text != confirmPass.text) {
                  Get.snackbar('Error', 'Passwords do not match');
                  return;
                }
                await authController.changePassword(oldPass.text, newPass.text);
                oldPass.clear();
                newPass.clear();
                confirmPass.clear();
              },
              child: authController.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Change Password'),
            )),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, [bool obscure = false]) {
    return TextField(
      controller: c,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
