import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class NustScholarshipScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const NustScholarshipScreen({super.key, required this.studentData});

  @override
  State<NustScholarshipScreen> createState() => _NustScholarshipScreenState();
}

class _NustScholarshipScreenState extends State<NustScholarshipScreen> {
  List<Map<String, String>> structuredScholarships = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchScholarships();
  }

  Future<void> fetchScholarships() async {
    try {
      final response = await http.get(Uri.parse('http://35.174.6.20:5000/scholarshipsnust'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List<String> raw = List<String>.from(data['data']);

          final List<Map<String, String>> parsed = [];
          String? currentTitle;

          for (final line in raw) {
            if (!line.trim().startsWith('-')) {
              currentTitle = line;
              parsed.add({"title": currentTitle, "description": ""});
            } else if (currentTitle != null) {
              parsed.last["description"] = line.replaceFirst('- ', '').trim();
            }
          }

          setState(() {
            structuredScholarships = parsed;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Failed to load scholarships.';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentName = widget.studentData['name'] ?? 'Student';

    return Scaffold(
    appBar: AppBar(
  title: const Text("NUST Scholarships"),
  backgroundColor: Colors.indigo,
  actions: [
    IconButton(
      icon: const Icon(Icons.dashboard_customize),
      tooltip: 'Student Dashboard',
      onPressed: () {
        context.go(
          '/student_dashboard',
          extra: widget.studentData, 
        );
      },
    ),
  ],
),
    
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi $studentName 👋",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Here are the available scholarships at NUST:",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: structuredScholarships.length,
                          itemBuilder: (context, index) {
                            final item = structuredScholarships[index];
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  item['title'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: item['description']!.isNotEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 6.0),
                                        child: Text(
                                          item['description'] ?? '',
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
