import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class RegisterView extends StatelessWidget {
  RegisterView({super.key});

  final c = Get.find<AuthController>();

  final fName = TextEditingController();
  final lName = TextEditingController();
  final mobile = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  final confirmPass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // off-white
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.lightGreen[400],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildField(fName, 'First Name', Icons.person),
            const SizedBox(height: 12),
            _buildField(lName, 'Last Name', Icons.person_outline),
            const SizedBox(height: 12),
            _buildField(mobile, 'Mobile', Icons.phone),
            const SizedBox(height: 12),
            _buildField(email, 'Email', Icons.email),
            const SizedBox(height: 12),
            _buildField(pass, 'Password', Icons.lock, true),
            const SizedBox(height: 12),
            _buildField(confirmPass, 'Confirm Password', Icons.lock_outline, true),
            const SizedBox(height: 20),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                ),
                onPressed: c.isLoading.value
                    ? null
                    : () {
                  if (pass.text != confirmPass.text) {
                    Get.snackbar('Error', 'Password not matched',
                        snackPosition: SnackPosition.BOTTOM);
                    return;
                  }
                  c.register(
                    firstName: fName.text,
                    lastName: lName.text,
                    mobile: mobile.text,
                    email: email.text,
                    password: pass.text,
                  );
                },
                child: c.isLoading.value
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text(
                  'Register',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon,
      [bool obscure = false]) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
