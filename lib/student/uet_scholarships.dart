import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart' show rootBundle;

class UetScholarships extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const UetScholarships({super.key, required this.studentData});

  @override
  _UetScholarshipsState createState() => _UetScholarshipsState();
}

class _UetScholarshipsState extends State<UetScholarships> {
  List<dynamic> scholarships = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadScholarships();
  }

  Future<void> loadScholarships() async {
    final String jsonString =
        await rootBundle.loadString('assets/scholarships.json');
    final jsonData = json.decode(jsonString);

    setState(() {
      scholarships = jsonData["universities"][0]["scholarships"];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UET Scholarships"),
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
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: scholarships.length,
              itemBuilder: (context, index) {
                final scholarship = scholarships[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: Colors.indigo.shade50,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                     
                        Text(
                          scholarship["title"] ?? "",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 4),
                     
                        Text(
                          scholarship["category"] ?? "",
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                  
                        if (scholarship["description"] != null)
                          Text(
                            scholarship["description"],
                            style: const TextStyle(fontSize: 14),
                          ),
                        const SizedBox(height: 6),
                       
                        if (scholarship["committee"] != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Committee:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                              ...scholarship["committee"]
                                  .map<Widget>(
                                      (c) => Text("• $c", style: const TextStyle(fontSize: 14)))
                                  .toList(),
                            ],
                          ),
                        
                        if (scholarship["rules"] != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              const Text(
                                "Rules:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                              ...scholarship["rules"]
                                  .map<Widget>(
                                      (r) => Text("• $r", style: const TextStyle(fontSize: 14)))
                                  .toList(),
                            ],
                          ),
                       
                        if (scholarship["criteria"] != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              const Text(
                                "Criteria:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                              ...scholarship["criteria"]
                                  .map<Widget>(
                                      (c) => Text("• $c", style: const TextStyle(fontSize: 14)))
                                  .toList(),
                            ],
                          ),
                      
                        if (scholarship["providers"] != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              const Text(
                                "Providers:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                              ...scholarship["providers"].map<Widget>((p) {
                                String name = p["name"];
                                String? link = p["link"];
                                return Text(
                                  "• $name${link != null ? " ($link)" : ""}",
                                  style: const TextStyle(fontSize: 14),
                                );
                              }).toList(),
                            ],
                          ),
                        
                        if (scholarship["benefits"] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              "Benefits: ${scholarship["benefits"] is List ? scholarship["benefits"].join(", ") : scholarship["benefits"]}",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
