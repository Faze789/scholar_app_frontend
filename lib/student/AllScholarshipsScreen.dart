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
      final String jsonString =
          await rootBundle.loadString('assets/scholarships.json');
      final data = jsonDecode(jsonString);
      setState(() {
        universities = data['universities'] ?? [];
      });
    } catch (e) {
      print('Error loading scholarships: $e');
    }
  }

  List<Map<String, dynamic>> _processUniversityScholarships(
      Map<String, dynamic> university) {
    List<Map<String, dynamic>> flatScholarships = [];

    final campuses = university['campuses'] as List<dynamic>? ?? [];
    
    bool isComsatsStyle = campuses.isNotEmpty &&
        (campuses[0] is Map) &&
        (campuses[0] as Map).containsKey('scholarships');

    if (isComsatsStyle) {
      for (var campusData in campuses.whereType<Map<String, dynamic>>()) {
        final String campusName = campusData['campus'] ?? 'Unknown Campus';
        final campusScholarships =
            campusData['scholarships'] as List<dynamic>? ?? [];
        for (var scholarship in campusScholarships.whereType<Map<String, dynamic>>()) {
          flatScholarships.add({...scholarship, 'campus': campusName});
        }
      }
    }

    if (university.containsKey('scholarships')) {
      final scholarships = university['scholarships'] as List<dynamic>? ?? [];
      for (var sch in scholarships.whereType<Map<String, dynamic>>()) {
        
        if (sch['categories'] is List) {
          final level = sch['level'] ?? 'UG';
          for (var cat in sch['categories'].whereType<Map<String, dynamic>>()) {
            final details = cat['details'] as Map<String, dynamic>?;
            if (details != null) {
              flatScholarships.add({
                ...details,
                'name': '$level - ${cat['name']}',
                'category': sch['type'],
              });
            }
          }
        }
        else if (sch['programs'] is List) {
          final level = sch['level'] ?? 'Graduate';
          for (var program in sch['programs'].whereType<Map<String, dynamic>>()) {
            final programName = program['name'] ?? 'Unnamed Program';
            final innerScholarships = program['scholarships'] as List<dynamic>? ?? [];

            for (var innerSch in innerScholarships.whereType<Map<String, dynamic>>()) {
                if (innerSch['details'] is Map) {
                     final detailsMap = innerSch['details'] as Map<String, dynamic>;
                     
                     String detailSummary = detailsMap.entries.where((e) => e.key != 'sources').map((e) => 
                        e.value is Map ? e.value.entries.map((ie) => '${ie.key}: ${ie.value}').join('; ') : '${e.key}: ${e.value}'
                     ).join(' | ');

                     flatScholarships.add({
                        'name': '$level - $programName - ${innerSch['name']}',
                        'description': detailSummary,
                        'category': sch['type'],
                        'eligibility': detailsMap['basis']
                     });
                } else {
                    flatScholarships.add({
                      ...innerSch,
                      'name': '$level - $programName - ${innerSch['name']}',
                      'category': sch['type'],
                    });
                }
            }
          }
        }
        else if (sch['schemes'] is List) {
          final category = sch['category'] ?? 'AU Scheme';
          for (var scheme in sch['schemes'].whereType<Map<String, dynamic>>()) {
            flatScholarships.add({
              ...scheme,
              'name': '$category: ${scheme['name']}',
              'category': category,
            });
          }
        }
        else if (sch['grants'] is List) {
          final category = sch['category'] ?? 'Need/Merit Grant';
          final overview = sch['overview'];
          for (var grantName in sch['grants']) {
            if (grantName is String) {
              flatScholarships.add({
                'name': grantName,
                'category': category,
                'description': overview,
              });
            }
          }
        }
        else {
          flatScholarships.add(sch);
        }
      }
    }

    return flatScholarships.where((s) => s['name'] != null || s['title'] != null).toList();
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
                  final name = university['name'] ?? 'Unnamed University';

                  final allScholarships =
                      _processUniversityScholarships(university);

                  return Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      leading: const CircleAvatar(
                        backgroundColor: Colors.indigo,
                        child: Icon(Icons.school, color: Colors.white),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      children: allScholarships
                          .map((sch) => _buildScholarshipCard(sch))
                          .toList(),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildScholarshipCard(Map<String, dynamic> scholarship) {
    final scholarshipName = scholarship['name'] ??
        scholarship['title'] ??
        scholarship['category'] ??
        scholarship['type'] ??
        '';

    if (scholarshipName.isEmpty) {
      return const SizedBox.shrink();
    }

    String? description = scholarship['description'] ?? scholarship['overview'];
    dynamic eligibility = scholarship['eligibility'] ?? scholarship['criteria'] ?? scholarship['rules'];

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
                  scholarshipName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (description != null && description.isNotEmpty)
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          if (eligibility != null) ...[
            const SizedBox(height: 8),
            badgeLabel('🎯 Eligibility'),
            if (eligibility is List)
              ...(eligibility).map((e) => Text('• $e'))
            else
              Text('• $eligibility'),
          ],
          if (scholarship['type'] != null || scholarship['category'] != null) ...[
            const SizedBox(height: 8),
            badgeLabel('🏷️ Type'),
            Text('• ${scholarship['type'] ?? scholarship['category']}'),
          ],
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
          if (scholarship['programs'] != null) ...[
            const SizedBox(height: 8),
            badgeLabel('📘 Programs'),
            if (scholarship['programs'] is List)
              ...(scholarship['programs'] as List).map((e) => Text('• $e'))
            else
              Text('• ${scholarship['programs']}'),
          ],
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