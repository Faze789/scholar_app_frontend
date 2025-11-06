import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class SwedenScholarshipsScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const SwedenScholarshipsScreen({super.key, required this.studentData});

  @override
  State<SwedenScholarshipsScreen> createState() =>
      _SwedenScholarshipsScreenState();
}

class _SwedenScholarshipsScreenState extends State<SwedenScholarshipsScreen> {
  Map<String, dynamic>? scholarshipData;
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    fetchScholarshipData();
  }

  Future<void> fetchScholarshipData() async {
    try {
      final response =
          await http.get(Uri.parse("http://192.168.100.121:5000/sisgp"));

      if (response.statusCode == 200) {
        setState(() {
          scholarshipData = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "Failed to load data: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  Widget buildSection(String title, List<dynamic>? items) {
    if (items == null || items.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                items.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• ",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          items[i].toString(),
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [  IconButton(
            icon: const Icon(Icons.dashboard_customize),
            tooltip: 'Student Dashboard',
            onPressed: () {
              context.go(
                '/student_dashboard',
                extra: widget.studentData,
              );
            },
          ),],
        title: const Text("Sweden Scholarships"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/abroad-scholarships',
              extra: widget.studentData),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.purple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          errorMessage,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scholarshipData?['title'] ?? "No Title",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              padding: const EdgeInsets.all(12.0),
                              child: ListView(
                                children: [
                                  buildSection("Introduction",
                                      scholarshipData?['introduction']),
                                  buildSection("Community Info",
                                      scholarshipData?['community_info']),
                                  buildSection("Eligibility",
                                      scholarshipData?['eligibility']),
                                  buildSection("Benefits",
                                      scholarshipData?['benefits']),
                                  buildSection("Application Steps",
                                      scholarshipData?['apply_steps']),
                                  buildSection("Final Thoughts",
                                      scholarshipData?['final_thoughts']),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}
