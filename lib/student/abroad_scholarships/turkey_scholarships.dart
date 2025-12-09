import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class TurkeyScholarshipsScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const TurkeyScholarshipsScreen({super.key, required this.studentData});

  @override
  State<TurkeyScholarshipsScreen> createState() => _TurkeyScholarshipsScreenState();
}

class _TurkeyScholarshipsScreenState extends State<TurkeyScholarshipsScreen> {
  Map<String, dynamic>? scholarshipData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchScholarshipData();
  }

  Future<void> fetchScholarshipData() async {
    try {
      final response = await http.get(Uri.parse("http://35.174.6.20:5000/turkiye"));
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
        title: const Text("Turkey Scholarships"),
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
                            scholarshipData!["title"] ?? "Turkey Scholarships",
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
                                  if (scholarshipData!["introduction"] != null)
                                    ListTile(
                                      title: const Text(
                                        "Introduction",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(scholarshipData!["introduction"]),
                                    ),
                                  const Divider(),

                                
                                  if (scholarshipData!["benefits"] != null)
                                    ListTile(
                                      title: const Text(
                                        "Benefits",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: (scholarshipData!["benefits"] as Map<String, dynamic>)
                                            .entries
                                            .map((e) => Text("• ${e.key}: ${e.value}"))
                                            .toList(),
                                      ),
                                    ),
                                  const Divider(),

                                 
                                  if (scholarshipData!["eligibility"] != null)
                                    ListTile(
                                      title: const Text(
                                        "Eligibility",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text("Details coming soon..."), 
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
