import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class LumsScholarships extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const LumsScholarships({super.key, required this.studentData});

  @override
  State<LumsScholarships> createState() => _LumsScholarshipsState();
}

class _LumsScholarshipsState extends State<LumsScholarships> {
  final List<Map<String, String>> _scholarshipData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScholarshipData();
  }

  Future<void> _loadScholarshipData() async {
    try {
      final rawData = await rootBundle.loadString("assets/scholarships.json");
      final jsonData = json.decode(rawData);

      final universities = jsonData["universities"] as List;
      final lums = universities.firstWhere(
        (u) => u["name"]
            .toString()
            .toLowerCase()
            .contains("lahore university of management sciences"),
        orElse: () => null,
      );

      if (lums != null && lums["scholarships"] is List) {
        for (var sch in lums["scholarships"]) {
          // Summary Table
          if (sch["type"] == "Summary Table" && sch["data"] is List) {
            for (var item in sch["data"]) {
              _scholarshipData.add({
                "program_level": item["program_level"] ?? "",
                "criteria": item["criteria"] ?? "",
                "award": item["award"] ?? "",
              });
            }
          }

         
          if (sch["categories"] is List) {
            for (var cat in sch["categories"]) {
              final details = cat["details"] ?? {};
              _scholarshipData.add({
                "program_level": "${sch["level"] ?? ""} - ${cat["name"] ?? ""}",
                "criteria": details["criteria"] ??
                    details["awarded_to"] ??
                    "",
                "award": details["coverage"] ??
                    details["number_of_awards"] ??
                    (details["typical_breakdown"]?.toString() ?? ""),
              });
            }
          }

       
          if (sch["programs"] is List) {
            for (var prog in sch["programs"]) {
              if (prog["scholarships"] is List) {
                for (var progSch in prog["scholarships"]) {
                  final details = progSch["details"] ?? {};
                  _scholarshipData.add({
                    "program_level":
                        "${sch["level"] ?? ""} - ${prog["name"] ?? ""} - ${progSch["name"] ?? ""}",
                    "criteria": details["eligibility"] ??
                        details["for_programs"] ??
                        details["basis"] ??
                        "",
                    "award": details["coverage"] ??
                        details["benefit"] ??
                        details["duration"] ??
                        (details["gmat_gre_based"]?.toString() ?? ""),
                  });
                }
              }
            }
          }
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading JSON: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LUMS Scholarships"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
           IconButton(
      icon: const Icon(Icons.dashboard_customize),
      tooltip: 'Student Dashboard',
      onPressed: () {
        context.go(
          '/student_dashboard',
          extra: widget.studentData, // ✅ send directly
        );
      },
    ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _scholarshipData.isEmpty
              ? const Center(child: Text("No LUMS scholarships found."))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Welcome ${widget.studentData['name'] ?? 'Student'}, here are all LUMS scholarships!",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _scholarshipData.length,
                        itemBuilder: (context, index) {
                          final data = _scholarshipData[index];
                          return _buildScholarshipCard(
                            data["program_level"] ?? "",
                            data["criteria"] ?? "",
                            data["award"] ?? "",
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildScholarshipCard(
      String programLevel, String criteria, String award) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              programLevel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Criteria: $criteria",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Award: $award",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
