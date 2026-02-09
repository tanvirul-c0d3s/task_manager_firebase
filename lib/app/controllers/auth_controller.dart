import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final isLoading = false.obs;

  User? get user => _auth.currentUser;

  Future<void> login(String email, String password) async {
    try {
      isLoading(true);
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.offAllNamed(Routes.home);
    } finally {
      isLoading(false);
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String mobile,
    required String email,
    required String password,
  }) async {
    try {
      isLoading(true);
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _db.collection('users').doc(cred.user!.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'mobile': mobile,
        'email': email,
        'createdAt': Timestamp.now(),
      });
      await _auth.signOut();
      Get.offAllNamed(Routes.login);
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String mobile,
  }) async {
    await _db.collection('users').doc(user!.uid).update({
      'firstName': firstName,
      'lastName': lastName,
      'mobile': mobile,
    });
    Get.back();
    Get.snackbar('Success', 'Profile updated');
  }

  Future<void> uploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final ref = FirebaseStorage.instance.ref('avatars/${user!.uid}.jpg');

    if (kIsWeb) {
      Uint8List bytes = await picked.readAsBytes();
      await ref.putData(bytes);
    } else {
      await ref.putFile(File(picked.path));
    }

    final url = await ref.getDownloadURL();
    await _db.collection('users').doc(user!.uid).update({'avatar': url});
    Get.snackbar('Success', 'Profile image updated');
  }

  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed(Routes.login);
  }

  Future<void> changePassword(String oldPass, String newPass) async {
    try {
      isLoading(true);
      final cred = EmailAuthProvider.credential(email: user!.email!, password: oldPass);
      await user!.reauthenticateWithCredential(cred);
      await user!.updatePassword(newPass);
      Get.snackbar('Success', 'Password changed');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }
}
