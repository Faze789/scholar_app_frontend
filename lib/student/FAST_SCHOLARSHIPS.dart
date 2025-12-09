import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class FAST_SCHOALRSHIPS extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const FAST_SCHOALRSHIPS({super.key, required this.studentData});

  @override
  State<FAST_SCHOALRSHIPS> createState() => _FAST_SCHOALRSHIPSState();
}

class _FAST_SCHOALRSHIPSState extends State<FAST_SCHOALRSHIPS> {
  Map<String, dynamic>? universityData;

  @override
  void initState() {
    super.initState();
    loadScholarshipData();
  }

  Future<void> loadScholarshipData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/scholarships.json');
      final data = json.decode(response);

      
      final List universities = data['universities'] ?? [];
      if (universities.isNotEmpty) {
        setState(() {
          universityData = universities.firstWhere(
            (u) => (u['university'] ?? '')
                .toString()
                .contains('FAST-NUCES'), 
            orElse: () => universities.first,
          );
        });
      }
    } catch (e) {
      debugPrint("Error loading JSON: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (universityData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List scholarships = universityData?['scholarships'] ?? [];
    final contact = universityData?['contact'] ?? {};
    final campuses = universityData?['campuses'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FAST Scholarships'),
        backgroundColor: Colors.teal,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("Name: ${widget.studentData['name'] ?? 'N/A'}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Program: ${widget.studentData['program'] ?? 'N/A'}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("GPA: ${widget.studentData['gpa'] ?? 'N/A'}",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            Text(
              universityData?['university'] ?? '',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const Divider(),
            const SizedBox(height: 8),

           
            ...scholarships.map((s) {
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['title'] ?? '',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      if (s['description'] != null)
                        Text("📖 ${s['description']}"),
                      const SizedBox(height: 6),
                      if (s['funding_resource'] != null)
                        Text("💰 Funding: ${s['funding_resource']}"),
                      if (s['financial_support'] != null)
                        Text("🎓 Support: ${s['financial_support']}"),
                      if (s['eligibility'] != null)
                        Text("🧾 Eligibility: ${s['eligibility']}"),
                      if (s['how_to_apply'] != null)
                        Text("📝 Apply: ${s['how_to_apply']}"),
                      if (s['repayment_terms'] != null) ...[
                        const SizedBox(height: 6),
                        const Text(
                          "📄 Repayment Terms:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                            "• Start: ${s['repayment_terms']['start'] ?? 'N/A'}"),
                        Text(
                            "• Duration: ${s['repayment_terms']['duration'] ?? 'N/A'}"),
                        Text(
                            "• Conditions: ${s['repayment_terms']['conditions'] ?? 'N/A'}"),
                      ],
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),
            const Divider(),

            const Text(
              "📞 Contact Information",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text("Phone: ${contact['phone'] ?? 'Not Available'}"),
            Text("Address: ${contact['address'] ?? 'Not Available'}"),

            const SizedBox(height: 20),

         
            const Text(
              "🏫 Campuses",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            ...List.generate(
              campuses.length,
              (index) => Text("• ${campuses[index]}"),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
