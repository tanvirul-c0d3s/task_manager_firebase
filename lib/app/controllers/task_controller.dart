// task_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class TaskController extends GetxController {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final _db = FirebaseFirestore.instance;

  CollectionReference get taskRef =>
      _db.collection('users').doc(uid).collection('tasks');

  // All tasks stream
  Stream<QuerySnapshot> getTasks() {
    return taskRef.orderBy('createdAt', descending: true).snapshots();
  }

  // Single task by id (helper)
  Future<DocumentSnapshot> getTaskById(String id) async {
    return await taskRef.doc(id).get();
  }

  // Add task
  Future<void> addTaskWithDetails(String title, String priority, String category) async {
    await taskRef.add({
      'title': title,
      'isCompleted': false,
      'priority': priority,
      'category': category,
      'createdAt': Timestamp.now(),
    });
  }

  // Update task
  Future<void> updateTaskWithDetails(String id, String title, String priority, String category) async {
    await taskRef.doc(id).update({
      'title': title,
      'priority': priority,
      'category': category,
    });
  }

  // Toggle completed
  Future<void> toggleTask(String id, bool value) async {
    await taskRef.doc(id).update({'isCompleted': value});
  }

  // Delete
  Future<void> deleteTask(String id) async {
    await taskRef.doc(id).delete();
  }
}
