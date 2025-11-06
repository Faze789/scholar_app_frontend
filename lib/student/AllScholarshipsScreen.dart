import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart' show rootBundle;

class AllScholarshipsScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const AllScholarshipsScreen({super.key, required this.studentData});

  @override
  State<AllScholarshipsScreen> createState() => _AllScholarshipsScreenState();
}

class _AllScholarshipsScreenState extends State<AllScholarshipsScreen> {
  List<dynamic> universities = [];

  @override
  void initState() {
    super.initState();
    loadScholarships();
  }

  Future<void> loadScholarships() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/scholarships.json');
      final data = jsonDecode(jsonString);
      setState(() {
        universities = data['universities'] ?? [];
      });
    } catch (e) {
      print('Error loading scholarships: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentName = widget.studentData['name'] ?? 'Student';

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎓 Scholarships Finder'),
        backgroundColor: Colors.indigo.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            tooltip: 'Go to Dashboard',
            onPressed: () {
              context.go(
                '/student_dashboard',
                extra: widget.studentData,
              );
            },
          ),
          IconButton(
            onPressed: () {
              print(widget.studentData);
            },
            icon: const Icon(Icons.select_all, color: Colors.white),
          ),
        ],
      ),

      body: universities.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListView.builder(
                itemCount: universities.length,
                itemBuilder: (context, index) {
                  final university = universities[index];
                  return Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: const CircleAvatar(
                        backgroundColor: Colors.indigo,
                        child: Icon(Icons.school, color: Colors.white),
                      ),
                      title: Text(
                        university['name'] ?? 'Unnamed University',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      children: (university['scholarships'] as List<dynamic>?)
                              ?.map((scholarship) => _buildScholarshipCard(scholarship))
                              .toList() ??
                          [],
                    ),
                  );
                },
              ),
            ),
    );
  }

  /// Builds each scholarship card under the university section
  Widget _buildScholarshipCard(Map<String, dynamic> scholarship) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.card_giftcard, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  scholarship['name'] ??
                      scholarship['faculty'] ??
                      'Unnamed Scholarship',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          if (scholarship['description'] != null)
            Text(
              scholarship['description'],
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),

          // 🎯 Eligibility
          if (scholarship['eligibility'] != null) ...[
            const SizedBox(height: 8),
            badgeLabel('🎯 Eligibility'),
            if (scholarship['eligibility'] is List)
              ...(scholarship['eligibility'] as List)
                  .map((e) => Text('• $e'))
                  
            else
              Text('• ${scholarship['eligibility']}'),
          ],

          // 📌 Criteria
          if (scholarship['scholarship_criteria'] != null) ...[
            const SizedBox(height: 8),
            badgeLabel('📌 Criteria'),
            if (scholarship['scholarship_criteria'] is Map)
              ...(scholarship['scholarship_criteria'] as Map<String, dynamic>)
                  .entries
                  .map((entry) => Text('• ${entry.key}: ${entry.value}'))
                  
            else
              Text('• ${scholarship['scholarship_criteria']}'),
          ],

          // 📘 Programs
          if (scholarship['programs'] != null) ...[
            const SizedBox(height: 8),
            badgeLabel('📘 Programs'),
            if (scholarship['programs'] is List)
              ...(scholarship['programs'] as List)
                  .map((e) => Text('• $e'))
                  
            else
              Text('• ${scholarship['programs']}'),
          ],

          // 📍 Campus
          if (scholarship['campus'] != null) ...[
            const SizedBox(height: 8),
            badgeLabel('📍 Campus'),
            Text(
              scholarship['campus'],
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  /// Small label bubble for section headers (e.g., "Eligibility", "Criteria")
  Widget badgeLabel(String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}
