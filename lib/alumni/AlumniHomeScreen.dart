import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AlumniHomeScreen extends StatelessWidget {
  final Map<String, dynamic> alumniData;

  const AlumniHomeScreen({super.key, required this.alumniData});

  void _showAlumniInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your Info'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(alumniData['image_url']),
                ),
              ),
              const SizedBox(height: 20),
              _infoRow("Name", alumniData['name']),
              _infoRow("Gmail", alumniData['gmail']),
              _infoRow("Institute", alumniData['institute']),
              _infoRow("Field", alumniData['field']),
              _infoRow("BS CGPA", alumniData['cgpa_bs']),
              _infoRow("MS CGPA", alumniData['cgpa_ms']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.purple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(alumniData['image_url']),
              ),
              const SizedBox(height: 20),
              Text(
                "Welcome, ${alumniData['name']}",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "${alumniData['field']} | ${alumniData['institute']}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildHomeButton(
                    context,
                    icon: Icons.chat,
                    label: 'Chats',
                    onTap: () {
                      context.go('/alumni-chats', extra: alumniData);
                    },
                  ),
                  _buildHomeButton(
                    context,
                    icon: Icons.event,
                    label: 'University Events',
                    onTap: () {
                      context.go('/all_uni_events', extra: alumniData);
                    },
                  ),
                ],
              ),

              

              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildHomeButton(
                    context,
                    icon: Icons.info_outline,
                    label: 'Check Own Info',
                    onTap: () {
                      _showAlumniInfoDialog(context);
                    },
                  ),
                  const SizedBox(height: 20),
                      _buildHomeButton(
                    context,
                    icon: Icons.logout,
                    label: 'Logout',
                    onTap: () {
                      context.go('/student_admin');
                    },
                  ),
                ],
              ),
             
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.38,
        height: 100,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
