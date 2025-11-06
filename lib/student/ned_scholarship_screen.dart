import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class NedScholarshipsScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const NedScholarshipsScreen({super.key, required this.studentData});

  @override
  State<NedScholarshipsScreen> createState() => _NedScholarshipsScreenState();
}

class _NedScholarshipsScreenState extends State<NedScholarshipsScreen> {
  List<dynamic> scholarships = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadScholarships();
  }

  Future<void> loadScholarships() async {
    try {
      // Load JSON file from assets
      final String response =
          await rootBundle.loadString('assets/scholarships.json');
      final data = json.decode(response);

      // Get all universities from JSON
      final universities = data['universities'] as List<dynamic>;

      // Find NED University
      final nedUniversity = universities.firstWhere(
        (u) => u['name'] == 'NED University',
        orElse: () => {},
      );

      if (nedUniversity.isNotEmpty) {
        setState(() {
          scholarships = nedUniversity['scholarships'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading scholarships: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentName = widget.studentData['name'] ?? 'Student';

    return Scaffold(
      appBar: AppBar(
        title: const Text('NED Scholarships'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_customize),
            tooltip: 'Student Dashboard',
            onPressed: () {
              context.go('/student_dashboard', extra: widget.studentData);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : scholarships.isEmpty
              ? const Center(child: Text('No scholarships found for NED University.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: scholarships.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Dear $studentName,\nHere are the available scholarships for NED University:',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }

                    final scholarship = scholarships[index - 1];
                    final title = scholarship['name'] ?? 'Unnamed Scholarship';
                    final type = scholarship['type'] ?? 'N/A';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.shade100,
                          child: Text('$index'),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text('Type: $type'),
                      ),
                    );
                  },
                ),
    );
  }
}
