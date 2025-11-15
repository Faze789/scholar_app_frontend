import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCheckAllUsers extends StatefulWidget {
  final String email;
  final String password;

  const AdminCheckAllUsers({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<AdminCheckAllUsers> createState() => _AdminCheckAllUsersState();
}

class _AdminCheckAllUsersState extends State<AdminCheckAllUsers> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    List<Map<String, dynamic>> users = [];

    QuerySnapshot studentsSnapshot =
        await _firestore.collection('students_data').get();
    for (var doc in studentsSnapshot.docs) {
      users.add({
        'type': 'Student',
        'email': doc['email'],
        'name': doc['student_name'],
        'image': doc['profile_image_url'],
        'program_level': doc['program_level'],
      });
    }

    QuerySnapshot alumniSnapshot =
        await _firestore.collection('alumni_data').get();
    for (var doc in alumniSnapshot.docs) {
      users.add({
        'type': 'Alumni',
        'email': doc['gmail'],
        'name': doc['name'],
        'image': doc['image_url'],
        'institute': doc['institute'],
      });
    }

    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
               IconButton(
  onPressed: () {
    context.go(
      '/admin_dashboard',
      extra: {
        'email': widget.email,
        'password': widget.password,
      },
    );
  },
  icon: const Icon(Icons.home),
)
        ],
        title: const Text("All Users"),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          List<Map<String, dynamic>> users = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(user['image']),
                    ),
                    title: Text(
                      user['name'],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(user['email']),
                        const SizedBox(height: 2),
                        if (user['type'] == 'Student')
                          Text(
                            "Program Level: ${user['program_level']}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        if (user['type'] == 'Alumni')
                          Text(
                            "Institute: ${user['institute']}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 6),
                          decoration: BoxDecoration(
                            color: user['type'] == 'Student'
                                ? Colors.blueAccent
                                : Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user['type'],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
