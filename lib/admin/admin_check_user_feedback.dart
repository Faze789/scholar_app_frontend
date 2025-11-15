import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCheckUserFeedback extends StatefulWidget {
  final String email;
  final String password;
  const AdminCheckUserFeedback({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<AdminCheckUserFeedback> createState() => _AdminCheckUserFeedbackState();
}

class _AdminCheckUserFeedbackState extends State<AdminCheckUserFeedback> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _truncateFeedback(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  Future<String?> _getProfileImage(String email) async {
    final snapshot = await _firestore
        .collection('students_data')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first['profile_image_url'];
    }
    return null;
  }

  void _showFullFeedbackDialog(Map<String, dynamic> data, String? imageUrl) {
    final String name = data['student_name'] ?? 'Anonymous';
    final String email = data['email'] ?? 'No email';
    final String feedback = data['feedback'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  imageUrl != null ? NetworkImage(imageUrl) : null,
              backgroundColor: Colors.indigo.shade100,
              child: imageUrl == null
                  ? Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: Colors.indigo.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(name,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email: $email', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              const Text('Feedback', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(feedback),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'User Feedback',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        centerTitle: false,
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
            icon: const Icon(Icons.home, color: Colors.white),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.purple.shade700],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('feedback')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No feedback submitted yet',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                );
              }

              final feedbacks = snapshot.data!.docs;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListView.builder(
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    final doc = feedbacks[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String name = data['student_name'] ?? 'Anonymous';
                    final String feedback = data['feedback'] ?? '';
                    final String preview = _truncateFeedback(feedback, 140);
                    final String email = data['email'] ?? '';

                    return FutureBuilder<String?>(
                      future: _getProfileImage(email),
                      builder: (context, snapshot) {
                        String? profileImage = snapshot.data;
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          color: Colors.white.withOpacity(0.15),
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () =>
                                _showFullFeedbackDialog(data, profileImage),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.white24,
                                        backgroundImage: profileImage != null
                                            ? NetworkImage(profileImage)
                                            : null,
                                        child: profileImage == null
                                            ? Text(
                                                name.isNotEmpty
                                                    ? name[0].toUpperCase()
                                                    : '?',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios,
                                          size: 16, color: Colors.white70),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    preview,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        height: 1.4,
                                        color: Colors.white70),
                                  ),
                                  if (feedback.length > 140)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Tap to read more',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.85),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
