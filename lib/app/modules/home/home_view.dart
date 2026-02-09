import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/task_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TaskController tc = Get.put(TaskController());
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController taskText = TextEditingController();
  String selectedPriority = 'Medium';
  String selectedCategory = 'Work';
  int _currentIndex = 0; // bottom nav index

  final List<String> categories = ['Work', 'Personal', 'Urgent'];
  final List<String> priorities = ['High', 'Medium', 'Low'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          _buildProfileIcon(),
        ],
        backgroundColor: Colors.lightGreen[400],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: tc.getTasks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          // Filter by category for bottom nav
          final filteredTasks = docs.where((task) {
            final data = task.data() as Map<String, dynamic>;
            final category = data.containsKey('category') ? data['category'] : 'Work';
            if (_currentIndex == 0) return category == 'Work';
            if (_currentIndex == 1) return category == 'Personal';
            return category == 'Urgent';
          }).toList();

          if (filteredTasks.isEmpty) return const Center(child: Text('No tasks added'));

          // Stats
          final completedCount = docs.where((t) => (t.data() as Map<String, dynamic>)['isCompleted'] == true).length;
          final pendingCount = docs.where((t) => (t.data() as Map<String, dynamic>)['isCompleted'] == false).length;

          return Column(
            children: [
              // Stats bar
              Container(
                color: Colors.grey[200],
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statCard('Completed', completedCount, Colors.green),
                    _statCard('Pending', pendingCount, Colors.orange),
                  ],
                ),
              ),

              // Tasks list
              Expanded(
                child: ListView.builder(
                  itemCount: filteredTasks.length,
                  itemBuilder: (_, i) {
                    final task = filteredTasks[i];
                    final data = task.data() as Map<String, dynamic>;
                    final title = data['title'] ?? '';
                    final isCompleted = data['isCompleted'] ?? false;
                    final priority = data.containsKey('priority') ? data['priority'] : 'Medium';

                    Color priorityColor;
                    if (priority == 'High') {
                      priorityColor = Colors.red;
                    } else if (priority == 'Medium') {
                      priorityColor = Colors.orange;
                    } else {
                      priorityColor = Colors.green;
                    }

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      elevation: 2,
                      child: ListTile(
                        leading: Checkbox(
                          value: isCompleted,
                          onChanged: (v) => tc.toggleTask(task.id, v ?? false),
                        ),
                        title: Text(
                          title,
                          style: TextStyle(
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black45),
                        ),
                        subtitle: Text(priority,
                            style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: () {
                                taskText.text = title;
                                selectedPriority = data['priority'] ?? 'Medium';
                                selectedCategory = data['category'] ?? 'Work';
                                _showAddEditDialog(isEdit: true, taskId: task.id);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _showDeleteDialog(task.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Work'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Personal'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Urgent'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _statCard(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildProfileIcon() {
    final user = authController.user;
    if (user == null) {
      return IconButton(
        icon: const Icon(Icons.person),
        onPressed: () => Get.toNamed(Routes.profile),
      );
    } else {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            );
          }
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final avatarUrl = data?['avatar'];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => Get.toNamed(Routes.profile),
              child: CircleAvatar(
                radius: 18,
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null ? const Icon(Icons.person, size: 18, color: Colors.white) : null,
                backgroundColor: Colors.black,
              ),
            ),
          );
        },
      );
    }
  }

  void _showAddEditDialog({bool isEdit = false, String? taskId}) {
    Get.defaultDialog(
      title: isEdit ? 'Edit Task' : 'New Task',
      titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: taskText,
              decoration: InputDecoration(
                hintText: 'Enter task title',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            // Priority dropdown
            DropdownButtonFormField<String>(
              value: selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: priorities
                  .map((p) => DropdownMenuItem(
                value: p,
                child: Text(p),
              ))
                  .toList(),
              onChanged: (v) => selectedPriority = v!,
            ),
            const SizedBox(height: 12),
            // Category dropdown
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: categories
                  .map((c) => DropdownMenuItem(
                value: c,
                child: Text(c),
              ))
                  .toList(),
              onChanged: (v) => selectedCategory = v!,
            ),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.all(16),
      textConfirm: isEdit ? 'Update' : 'Add',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        if (taskText.text.trim().isEmpty) return;
        if (isEdit) {
          await tc.updateTaskWithDetails(taskId!, taskText.text, selectedPriority, selectedCategory);
        } else {
          await tc.addTaskWithDetails(taskText.text, selectedPriority, selectedCategory);
        }
        taskText.clear();
        Get.back();
      },
      textCancel: 'Cancel',
      cancelTextColor: Colors.black,
    );
  }

  void _showDeleteDialog(String taskId) {
    Get.defaultDialog(
      title: 'Delete Task?',
      middleText: 'Are you sure you want to delete this task?',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () {
        tc.deleteTask(taskId);
        Get.back();
      },
      textCancel: 'Cancel',
      cancelTextColor: Colors.black,
    );
  }
}
