import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class RhodesScholarshipScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const RhodesScholarshipScreen({super.key, required this.studentData});

  @override
  State<RhodesScholarshipScreen> createState() => _RhodesScholarshipScreenState();
}

class _RhodesScholarshipScreenState extends State<RhodesScholarshipScreen> {
  Map<String, dynamic>? scholarshipData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchScholarshipData();
  }

  Future<void> fetchScholarshipData() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.100.121:5000/rhodes"));
      if (response.statusCode == 200) {
        setState(() {
          scholarshipData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        scholarshipData = {"error": e.toString()};
      });
    }
  }

  Widget buildBulletList(List items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((e) => Text("• $e")).toList(),
    );
  }

  Widget buildQuickFacts(Map facts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: facts.entries
          .map((entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text("${entry.key}: ${entry.value}"),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: const Text("Rhodes Scholarship"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/abroad-scholarships', extra: widget.studentData),
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
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : scholarshipData == null || scholarshipData!.containsKey("error")
                    ? Center(
                        child: Text(
                          "Failed to load data",
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scholarshipData!["title"] ?? "Rhodes Scholarship",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                              ),
                              padding: const EdgeInsets.all(12.0),
                              child: ListView(
                                children: [
                                  // ✅ Introduction
                                  if ((scholarshipData!["introduction"] ?? "").toString().isNotEmpty)
                                    ListTile(
                                      title: const Text(
                                        "Introduction",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(scholarshipData!["introduction"]),
                                    ),
                                  const Divider(),

                                  // ✅ Quick Facts
                                  if (scholarshipData!["quick_facts"] != null &&
                                      (scholarshipData!["quick_facts"] as Map).isNotEmpty)
                                    ListTile(
                                      title: const Text(
                                        "Quick Facts",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: buildQuickFacts(
                                          scholarshipData!["quick_facts"] as Map),
                                    ),
                                  const Divider(),

                                  // ✅ Eligibility
                                  if (scholarshipData!["eligibility"] != null &&
                                      (scholarshipData!["eligibility"] as List).isNotEmpty)
                                    ListTile(
                                      title: const Text(
                                        "Eligibility",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: buildBulletList(
                                          scholarshipData!["eligibility"] as List),
                                    ),
                                  const Divider(),

                                  // ✅ Benefits
                                  if (scholarshipData!["benefits"] != null &&
                                      (scholarshipData!["benefits"] as List).isNotEmpty)
                                    ListTile(
                                      title: const Text(
                                        "Benefits",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: buildBulletList(
                                          scholarshipData!["benefits"] as List),
                                    ),
                                  const Divider(),

                                  // ✅ Application Process
                                  if (scholarshipData!["application_process"] != null &&
                                      (scholarshipData!["application_process"] as List).isNotEmpty)
                                    ListTile(
                                      title: const Text(
                                        "Application Process",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: buildBulletList(
                                          scholarshipData!["application_process"] as List),
                                    ),
                                  const Divider(),

                                  // ✅ Final Thoughts
                                  if ((scholarshipData!["final_thoughts"] ?? "").toString().isNotEmpty)
                                    ListTile(
                                      title: const Text(
                                        "Final Thoughts",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(scholarshipData!["final_thoughts"]),
                                    ),
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
