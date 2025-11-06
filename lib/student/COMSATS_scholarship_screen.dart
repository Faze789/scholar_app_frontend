import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class Comsats_ScholarshipScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const Comsats_ScholarshipScreen({super.key, required this.studentData});

  @override
  State<Comsats_ScholarshipScreen> createState() =>
      _Comsats_ScholarshipScreenState();
}

class _Comsats_ScholarshipScreenState
    extends State<Comsats_ScholarshipScreen> {
  List<Map<String, dynamic>> comsatsCampuses = [];

  @override
  void initState() {
    super.initState();
    _loadScholarships();
  }

  Future<void> _loadScholarships() async {
    try {
      final String response =
          await rootBundle.loadString('assets/scholarships.json');
      final data = json.decode(response);

      
      final universities = data['universities'] ?? data;
      final comsats = universities.firstWhere(
        (u) => (u['name'] ?? '').toString().toLowerCase().contains('comsats'),
        orElse: () => null,
      );

      if (comsats != null) {
        final campusesData = comsats['campuses'];

        if (campusesData is Map<String, dynamic>) {
  
          comsatsCampuses = campusesData.entries.map((entry) {
            return {
              'campus': entry.key,
              'scholarships': entry.value['scholarships'] ?? [],
            };
          }).toList();
        } else if (campusesData is List) {
          comsatsCampuses = List<Map<String, dynamic>>.from(campusesData);
        }
      }

      setState(() {});
    } catch (e) {
      debugPrint("Error loading scholarships: $e");
    }
  }

  void _showUserDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.indigo[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "🎓 Student Details",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _userDetailRow("👤 Name", widget.studentData['name']),
                _userDetailRow("✉️ Email", widget.studentData['email']),
                _userDetailRow("🎓 Program", widget.studentData['program']),
                _userDetailRow("📊 CGPA", widget.studentData['cgpa'].toString()),
                _userDetailRow(
                    "🔍 Fields", (widget.studentData['fields'] as List).join(', ')),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _userDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scholarshipCard(Map<String, dynamic> item) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.indigo.shade50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.indigo[700],
          child: const Icon(Icons.school, color: Colors.white, size: 26),
        ),
        title: Text(
          item['name'] ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.indigo,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Type: ${item['type'] ?? 'N/A'}",
                  style: const TextStyle(fontSize: 15, color: Colors.black87)),
              const SizedBox(height: 4),
              const Text(
                "Eligibility Criteria:",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo),
              ),
              Text(item['eligibility'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campusSection(String campusName, List<dynamic> scholarships) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          campusName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const Divider(thickness: 1.5),
        ...scholarships.map((s) => _scholarshipCard(Map<String, dynamic>.from(s)))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("COMSATS Scholarships"),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard, color: Colors.white),
            tooltip: "Go to Dashboard",
            onPressed: () {
              GoRouter.of(context)
                  .go('/student_dashboard', extra: widget.studentData);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
            tooltip: "Show Student Info",
            onPressed: () => _showUserDetails(context),
          ),
        ],
      ),
      body: comsatsCampuses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "Available Scholarships",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...comsatsCampuses.map(
                  (campus) => _campusSection(
                    campus['campus'],
                    campus['scholarships'] ?? [],
                  ),
                ),
              ],
            ),
    );
  }
}
