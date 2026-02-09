import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileView extends StatelessWidget {
  EditProfileView({super.key});

  final AuthController authController = Get.find<AuthController>();
  final RxMap<String, dynamic> userData = <String, dynamic>{}.obs;

  final fName = TextEditingController();
  final lName = TextEditingController();
  final mobile = TextEditingController();
  final currentPass = TextEditingController();
  final newPass = TextEditingController();
  final confirmPass = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (authController.user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(authController.user!.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          userData.value = snapshot.data()!;
          fName.text = userData.value['firstName'] ?? '';
          lName.text = userData.value['lastName'] ?? '';
          mobile.text = userData.value['mobile'] ?? '';
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Edit Profile'), backgroundColor: Colors.black),
      body: Obx(() {
        if (userData.value.isEmpty) return const Center(child: CircularProgressIndicator());

        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _field(fName, 'First Name'),
                const SizedBox(height: 12),
                _field(lName, 'Last Name'),
                const SizedBox(height: 12),
                _field(mobile, 'Mobile'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    authController.updateProfile(
                      firstName: fName.text,
                      lastName: lName.text,
                      mobile: mobile.text,
                    );
                  },
                  child: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 32),

                // Change password
                // const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                // const SizedBox(height: 12),
                // _field(currentPass, 'Current Password', true),
                // const SizedBox(height: 12),
                // _field(newPass, 'New Password', true),
                // const SizedBox(height: 12),
                // _field(confirmPass, 'Confirm Password', true),
                // const SizedBox(height: 16),
                // ElevatedButton(
                //   onPressed: _changePassword,
                //   child: const Text('Update Password'),
                //   style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.black,
                //       padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                // ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _changePassword() async {
    if (newPass.text != confirmPass.text) {
      Get.snackbar('Error', 'New password and confirm password do not match');
      return;
    }

    try {
      final user = authController.user!;
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: currentPass.text);

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPass.text);
      Get.snackbar('Success', 'Password updated successfully');

      currentPass.clear();
      newPass.clear();
      confirmPass.clear();
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Widget _field(TextEditingController c, String label, [bool obscure = false]) {
    return TextField(
      controller: c,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
