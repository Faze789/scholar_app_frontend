import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class all_chats extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const all_chats({super.key, required this.studentData});

  @override
  State<all_chats> createState() => _ConnectWithAlumniState();
}

class _ConnectWithAlumniState extends State<all_chats> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff1f1f1),
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text('Connect with Alumni', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view_rounded),
            onPressed: () {
              context.go('/student_dashboard', extra: widget.studentData); 
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                onChanged: (v) => setState(() => searchQuery = v.trim().toLowerCase()),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search alumni by name, field, or institute',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.white54),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('alumni_data').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final name = data['name'].toString().toLowerCase();
                  final field = data['field'].toString().toLowerCase();
                  final institute = data['institute'].toString().toLowerCase();
                  return name.contains(searchQuery) ||
                      field.contains(searchQuery) ||
                      institute.contains(searchQuery);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text('No alumni found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundImage: NetworkImage(data['image_url']),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.yellow.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(data['institute'], style: const TextStyle(color: Colors.black87, fontSize: 12)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.computer, size: 16, color: Colors.black54),
                                    const SizedBox(width: 4),
                                    Text(data['field'], style: const TextStyle(fontSize: 13, color: Colors.black54)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(8)),
                                      child: Text('BS: ${data['cgpa']}', style: const TextStyle(fontSize: 12)),
                                    ),
                                    const SizedBox(width: 3),
                                   
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                      AlumniDetailsScreen(alumniData: data , student_data: widget.studentData)));
                                },
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.visibility, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  context.go('/chat', extra: {
                                    'currentStudent': widget.studentData,
                                    'alumni': data,
                                  });
                                },
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.message, color: Colors.white),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class AlumniDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> alumniData;
  final Map<String, dynamic> student_data;
  const AlumniDetailsScreen({super.key, required this.alumniData , required this.student_data});

  Future<String?> fetchDegreeImage() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('alumni_degree_data')
        .where('email', isEqualTo: alumniData['email'])
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first['degree_image_url'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f7f7),
      appBar: AppBar(
        
        backgroundColor: Colors.black87,
        title: Text(alumniData['name'], style: const TextStyle(color: Colors.white)),
      ),
      body: FutureBuilder<String?>(
        future: fetchDegreeImage(),
        builder: (context, snapshot) {
          final degreeImage = snapshot.data;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundImage: NetworkImage(alumniData['image_url']),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        alumniData['name'],
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alumniData['email'],
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.school, color: Colors.blue),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Institute: ${alumniData['institute']}",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.computer, color: Colors.green),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Field of Study: ${alumniData['field']}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.grade, color: Colors.orange),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text("BS CGPA: ${alumniData['cgpa']}", style: const TextStyle(fontSize: 16)),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                     
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                degreeImage != null
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullDegreeImage(imageUrl: degreeImage),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12)
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(degreeImage, height: 260, fit: BoxFit.cover),
                          ),
                        ),
                      )
                    : const Text('Degree Image Not Uploaded', style: TextStyle(fontSize: 15)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class FullDegreeImage extends StatelessWidget {
  final String imageUrl;
  const FullDegreeImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: InteractiveViewer(
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }
}