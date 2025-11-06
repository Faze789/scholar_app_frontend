import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart' show rootBundle;

class AirUniFees extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const AirUniFees({super.key, required this.studentData});

  @override
  State<AirUniFees> createState() => _AirUniFeesState();
}

class _AirUniFeesState extends State<AirUniFees> {
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
          (u) => u['university'].toString().toLowerCase().contains('air university'),
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

  String formatValue(dynamic value) {
    if (value is double) {
      return value.toStringAsFixed(1);
    }
    return value?.toString() ?? 'N/A';
  }

  String _formatKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) => '${match[1]} ${match[2]}')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  void _showMeritCheck(BuildContext context) {
    print('=== Air University Merit Check Start ===');
    print('studentData: ${widget.studentData}');
    print('is_o_a_level: ${widget.studentData['is_o_a_level']}');
    print('O-Level Marks: ${widget.studentData['o_level_marks']}');
    print('A-Level Marks: ${widget.studentData['a_level_marks']}');
    print('Matric Marks: ${widget.studentData['matric_marks']}');
    print('FSC Marks: ${widget.studentData['fsc_marks']}');
    print('Bachelors CGPA: ${widget.studentData['bachelors_cgpa']}');
    print('CGPA: ${widget.studentData['cgpa']}');
    print('NTS Marks: ${widget.studentData['nts_marks']}');
    print('NET Marks: ${widget.studentData['net_marks']}');
    print('====================================');

    final airData = <String, dynamic>{};
    widget.studentData.forEach((key, value) {
      if (key.toLowerCase().contains('air')) {
        airData[key] = value;
      }
    });

    bool hasAirMatch = airData.isNotEmpty;
    String matchedField = '';
    String matchedValue = '';

    if (hasAirMatch) {
      var firstEntry = airData.entries.first;
      matchedField = firstEntry.key;
      matchedValue = formatValue(firstEntry.value);
    }

    final personalDetails = <String, dynamic>{};
    widget.studentData.forEach((key, value) {
      if (['student_name', 'name', 'father_name', 'email'].contains(key)) {
        personalDetails[key] = value;
      }
    });

    final hasCGPA = widget.studentData.containsKey('bachelors_cgpa') || widget.studentData.containsKey('cgpa');
    final isOA = widget.studentData['is_o_a_level'] ?? false;

    final academicMarks = [
      if (widget.studentData.containsKey('bachelors_cgpa')) {'key': 'Bachelors CGPA', 'value': formatValue(widget.studentData['bachelors_cgpa'])},
      if (widget.studentData.containsKey('cgpa')) {'key': 'CGPA', 'value': formatValue(widget.studentData['cgpa'])},
      if (widget.studentData.containsKey('nts_marks')) {'key': 'NTS Marks', 'value': formatValue(widget.studentData['nts_marks'])},
      if (widget.studentData.containsKey('net_marks')) {'key': 'NET Marks', 'value': formatValue(widget.studentData['net_marks'])},
      if (isOA) ...[
        {'key': 'O-Level Marks', 'value': formatValue(widget.studentData['o_level_marks'])},
        {'key': 'A-Level Marks', 'value': formatValue(widget.studentData['a_level_marks'])},
      ] else ...[
        {'key': 'Matric Marks', 'value': formatValue(widget.studentData['matric_marks'])},
        {'key': 'FSC Marks', 'value': formatValue(widget.studentData['fsc_marks'])},
      ],
    ];

    final hasValidAcademicMarks = academicMarks.any((entry) => entry['value'] != 'N/A');

    Widget buildSectionContent(Map<String, dynamic> data) {
      if (data.isEmpty) {
        return const Text(
          'No data available',
          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    _formatKey(entry.key),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.indigo,
                    ),
                  ),
                ),
                const Text(': ', style: TextStyle(fontWeight: FontWeight.w600)),
                Expanded(
                  flex: 3,
                  child: Text(
                    formatValue(entry.value),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    Widget buildSectionContentList(List<Map<String, String>> data) {
      if (data.isEmpty || data.every((entry) => entry['value'] == 'N/A')) {
        return const Text(
          'No data available',
          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.where((entry) => entry['value'] != 'N/A').map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    entry['key']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.indigo,
                    ),
                  ),
                ),
                const Text(': ', style: TextStyle(fontWeight: FontWeight.w600)),
                Expanded(
                  flex: 3,
                  child: Text(
                    entry['value']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    String getProgramDisplay() {
      String program = widget.studentData['program']?.toString() ?? '';
      List<dynamic> selectedFields = widget.studentData['selected_fields']?.cast<String>() ?? [];
      List<dynamic> fields = widget.studentData['fields']?.cast<String>() ?? [];

      List<dynamic> fieldsToUse = selectedFields.isNotEmpty ? selectedFields : fields;

      if (fieldsToUse.isNotEmpty) {
        return '$program ${fieldsToUse.join(', ')}';
      }
      return program.isEmpty ? 'N/A' : program;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Air University Merit Check',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Admission Details',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.indigo,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/placeholder_student.jpg',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.person,
                          size: 120,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Merit Check Result',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Air University Match: ${hasAirMatch ? 'Yes' : 'No'}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: hasAirMatch ? Colors.green.shade700 : Colors.red.shade600,
                          ),
                        ),
                        if (hasAirMatch) ...[
                          Text(
                            'Matched Field: $matchedField',
                            style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                          ),
                          Text(
                            'Value: $matchedValue',
                            style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                          ),
                        ],
                        if (!hasAirMatch)
                          Text(
                            'No matching Air University data found.',
                            style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                          ),
                      ],
                    ),
                  ),
                  if (hasAirMatch && !hasCGPA) ...[
                    ExpansionTile(
                      leading: const Icon(Icons.school, color: Colors.indigo),
                      title: const Text(
                        'Air University Data',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo),
                      ),
                      initiallyExpanded: true,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: buildSectionContent(airData),
                        ),
                      ],
                    ),
                    const Divider(height: 30, thickness: 1, color: Colors.indigo),
                  ],
                  ExpansionTile(
                    leading: const Icon(Icons.person, color: Colors.indigo),
                    title: const Text(
                      'Personal Details',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo),
                    ),
                    initiallyExpanded: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: buildSectionContent(personalDetails),
                      ),
                    ],
                  ),
                  if (hasValidAcademicMarks) ...[
                    const Divider(height: 30, thickness: 1, color: Colors.indigo),
                    ExpansionTile(
                      leading: const Icon(Icons.book, color: Colors.indigo),
                      title: const Text(
                        'Academic Marks',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo),
                      ),
                      initiallyExpanded: true,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: buildSectionContentList(academicMarks),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 30, thickness: 1, color: Colors.indigo),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Program Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Full Program: ${getProgramDisplay()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.indigo,
                          ),
                        ),
                        Text(
                          'Program: ${formatValue(widget.studentData['program'])}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                        ),
                        Text(
                          'Fields: ${getProgramDisplay().split(' ').skip(1).join(', ')}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.indigo, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.all(20),
          elevation: 8,
        );
      },
    );
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
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
        buildHeader("Scholarships & Financial Aid", Icons.volunteer_activism, color: Colors.purple.shade700),
        const SizedBox(height: 16),
        ...scholarships.map((s) {
          return Card(
            color: Colors.purple.shade50,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s['category'] ?? 'Unnamed Scholarship',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (s['schemes'] != null)
                    ...((s['schemes'] as List).map((scheme) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                scheme['name'] ?? "",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (scheme['benefits'] != null)
                                ...((scheme['benefits'] as List).map((b) => Text("• $b"))),
                              if (scheme['eligibility'] != null)
                                Text(
                                  "Eligibility: ${scheme['eligibility']}",
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                            ],
                          ),
                        ))),
                  if (s['overview'] != null)
                    Text(s['overview'], textAlign: TextAlign.justify),
                  if (s['benefits'] != null)
                    ...((s['benefits'] as List).map((b) => Text(
                          "• $b",
                          style: const TextStyle(fontSize: 15),
                        ))),
                  if (s['eligibility'] != null)
                    Text(
                      "Eligibility: ${s['eligibility']}",
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                ],
              ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Financial Aid Officer: ${contact['name'] ?? 'N/A'}"),
                Text("Designation: ${contact['designation'] ?? 'N/A'}"),
                Text("Extension: ${contact['extension'] ?? 'N/A'}"),
                Text("Email: ${contact['email'] ?? 'N/A'}"),
                const Divider(),
                Text("UAN: ${uniContact['UAN'] ?? 'N/A'}"),
                Text("Address: ${uniContact['address'] ?? 'N/A'}"),
                Text("Email: ${uniContact['email'] ?? 'N/A'}"),
              ],
            ),
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
        title: const Text(
          "Air University Fee & Scholarships",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment, color: Colors.white),
            tooltip: 'Merit Check',
            onPressed: () => _showMeritCheck(context),
          ),
          IconButton(
            icon: const Icon(Icons.school_sharp, color: Colors.white),
            tooltip: 'Scholarships',
            onPressed: () {
              context.go('/air-scholarship', extra: student);
            },
          ),
          IconButton(
            icon: const Icon(Icons.dashboard_customize, color: Colors.white),
            tooltip: 'Student Dashboard',
            onPressed: () {
              context.go('/student_dashboard', extra: student);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    "⚠️ $errorMessage",
                    style: const TextStyle(fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildScholarshipSection(),
                      const SizedBox(height: 24),
                      buildContactSection(),
                    ],
                  ),
                ),
    );
  }
}