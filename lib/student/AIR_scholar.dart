import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart' show rootBundle;

class AIRScholarshipScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const AIRScholarshipScreen({super.key, required this.studentData});

  @override
  State<AIRScholarshipScreen> createState() => _AirUniFeesState();
}

class _AirUniFeesState extends State<AIRScholarshipScreen> {
  Map<String, dynamic>? feeData;
  Map<String, dynamic>? scholarshipData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/scholarships.json');
      final decoded = json.decode(jsonString);

      if (decoded is Map && decoded['universities'] is List) {
        final universities = decoded['universities'] as List;
        final airUni = universities.firstWhere(
          (u) => u['name']
              .toString()
              .toLowerCase()
              .contains('air'),
          orElse: () => null,
        );

        if (airUni != null) {
          setState(() {
            scholarshipData = airUni;
            feeData = airUni['fee_structure'] ?? {};
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Air University data not found';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Invalid JSON format';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading data: $e';
        isLoading = false;
      });
    }
  }

  Widget buildHeader(String title, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color ?? Colors.indigo.shade700,
            (color ?? Colors.indigo.shade700).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(title,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ],
      ),
    );
  }

  Widget buildScholarshipSection() {
    if (scholarshipData == null) {
      return const Center(child: Text("No scholarships found."));
    }

    final scholarships = scholarshipData!['scholarships'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader("Scholarships & Financial Aid", Icons.volunteer_activism,
            color: Colors.purple.shade700),
        const SizedBox(height: 16),
        ...scholarships.map((s) {
          return Card(
            color: Colors.purple.shade50,
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['category'] ?? 'Unnamed Scholarship',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade900)),
                    const SizedBox(height: 8),
                    if (s['schemes'] != null)
                      ...((s['schemes'] as List).map((scheme) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(scheme['name'] ?? "",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  if (scheme['benefits'] != null)
                                    ...((scheme['benefits'] as List)
                                        .map((b) => Text("• $b"))),
                                  if (scheme['eligibility'] != null)
                                    Text("Eligibility: ${scheme['eligibility']}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500)),
                                ]),
                          ))),
                    if (s['overview'] != null)
                      Text(s['overview'], textAlign: TextAlign.justify),
                    if (s['benefits'] != null)
                      ...((s['benefits'] as List)
                          .map((b) => Text("• $b", style: const TextStyle(fontSize: 15)))),
                    if (s['eligibility'] != null)
                      Text("Eligibility: ${s['eligibility']}",
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                  ]),
            ),
          );
        }),
      ],
    );
  }

  Widget buildContactSection() {
    final contact = scholarshipData?['contact'] ?? {};
    final uniContact = scholarshipData?['university_contact'] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader("Contact Information", Icons.phone, color: Colors.teal.shade700),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Financial Aid Officer: ${contact['name'] ?? 'N/A'}"),
              Text("Designation: ${contact['designation'] ?? 'N/A'}"),
              Text("Extension: ${contact['extension'] ?? 'N/A'}"),
              Text("Email: ${contact['email'] ?? 'N/A'}"),
              const Divider(),
              Text("UAN: ${uniContact['UAN'] ?? 'N/A'}"),
              Text("Address: ${uniContact['address'] ?? 'N/A'}"),
              Text("Email: ${uniContact['email'] ?? 'N/A'}"),
            ]),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.studentData;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Air University Fee & Scholarships",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
              icon: const Icon(Icons.dashboard_customize, color: Colors.white),
              onPressed: () {
                context.go('/student_dashboard', extra: student);
              }),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text("⚠️ $errorMessage",
                      style: const TextStyle(fontSize: 16)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildScholarshipSection(),
                        const SizedBox(height: 24),
                        buildContactSection(),
                      ]),
                ),
    );
  }
}
