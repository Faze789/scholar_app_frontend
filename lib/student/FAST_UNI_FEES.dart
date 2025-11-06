import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class FastUniversityScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const FastUniversityScreen({super.key, required this.studentData});

  @override
  State<FastUniversityScreen> createState() => _FastUniversityScreenState();
}

class _FastUniversityScreenState extends State<FastUniversityScreen> {
  List<String> fastVariations = [
    "FAST",
    "fast",
    "Fast",
    "FAST University",
    "fast university",
  ];

  Map<String, dynamic> fastData = {};
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchFastData();
  }

  Future<void> fetchFastData() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.100.121:5000/feesfast'));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        print('API Response: $jsonBody');

        setState(() {
          fastData = jsonBody;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Failed to load data: $e';
        isLoading = false;
      });
      print('Failed to load FAST data: $e');
    }
  }

  String formatValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is double) return value.toStringAsFixed(2);
    return value.toString();
  }

  String getProgramDisplay() {
    final program = widget.studentData['program']?.toString() ?? 'N/A';
    final fields = widget.studentData['selected_fields'] ?? widget.studentData['fields'];

    if (fields is List && fields.isNotEmpty) {
      return '$program (${fields.join(', ')})';
    }
    return program;
  }

  void showFastMeritCheck(BuildContext context) {
    print('=== FAST Merit Check Start ===');
    print('studentData: ${widget.studentData}');
    print('fastData: $fastData');
    print('is_o_a_level: ${widget.studentData['is_o_a_level']}');
    print('O-Level Marks: ${widget.studentData['o_level_marks']}');
    print('A-Level Marks: ${widget.studentData['a_level_marks']}');
    print('Matric Marks: ${widget.studentData['matric_marks']}');
    print('FSC Marks: ${widget.studentData['fsc_marks']}');
    print('=========================');

    bool hasFastMatch = false;
    String matchedField = '';
    String matchedValue = '';

    widget.studentData.forEach((key, value) {
      if (value != null) {
        final keyLower = key.toLowerCase();
        final valueLower = value.toString().toLowerCase();
        for (var fastName in fastVariations) {
          final fastLower = fastName.toLowerCase();
          if (keyLower.contains(fastLower) || valueLower.contains(fastLower)) {
            hasFastMatch = true;
            matchedField = key;
            matchedValue = value.toString();
            break;
          }
        }
      }
      if (hasFastMatch) return;
    });

    if (!hasFastMatch && widget.studentData['full_api_response'] != null) {
      final universities = widget.studentData['full_api_response']['universities'];
      if (universities is List && universities.isNotEmpty) {
        for (var uni in universities) {
          if (uni is Map && uni.containsKey('name')) {
            final uniName = uni['name']?.toString().toLowerCase() ?? '';
            for (var fastName in fastVariations) {
              if (uniName.contains(fastName.toLowerCase())) {
                hasFastMatch = true;
                matchedField = 'full_api_response.universities.name';
                matchedValue = uni['name'].toString();
                break;
              }
            }
            if (hasFastMatch) break;
          }
        }
      }
    }

    print('FAST Match: $hasFastMatch, Matched Field: $matchedField, Value: $matchedValue');

    final fastUniversityData = <String, dynamic>{};
    widget.studentData.forEach((key, value) {
      final keyLower = key.toLowerCase();
      if (keyLower.contains('fast')) {
        fastUniversityData[key] = value;
      }
    });

    final hasCGPA = widget.studentData.containsKey('bachelors_cgpa') || widget.studentData.containsKey('cgpa');
    final isOA = widget.studentData['is_o_a_level'] ?? false;

    final personalData = [
      {'key': 'Student Name', 'value': formatValue(widget.studentData['student_name'] ?? widget.studentData['name'])},
      {'key': 'Father Name', 'value': formatValue(widget.studentData['father_name'])},
      {'key': 'Email', 'value': formatValue(widget.studentData['email'])},
      {'key': 'Program', 'value': getProgramDisplay()},
    ];

    final academicMarks = [
      if (widget.studentData.containsKey('bachelors_cgpa')) {'key': 'Bachelor\'s CGPA', 'value': formatValue(widget.studentData['bachelors_cgpa'])},
      if (widget.studentData.containsKey('cgpa')) {'key': 'CGPA', 'value': formatValue(widget.studentData['cgpa'])},
      if (widget.studentData.containsKey('gpa')) {'key': 'GPA', 'value': formatValue(widget.studentData['gpa'])},
      if (isOA) ...[
        {'key': 'O-Level Marks', 'value': formatValue(widget.studentData['o_level_marks'])},
        {'key': 'A-Level Marks', 'value': formatValue(widget.studentData['a_level_marks'])},
      ] else ...[
        {'key': 'Matric Marks', 'value': formatValue(widget.studentData['matric_marks'])},
        {'key': 'FSC Marks', 'value': formatValue(widget.studentData['fsc_marks'])},
      ],
    ];

    final hasValidAcademicMarks = academicMarks.any((entry) => entry['value'] != 'N/A');

    final feeStructure = fastData['fee_structure'] ?? fastData;

    final fastFeeData = <Map<String, String>>[];
    if (feeStructure['tuition_fees'] != null && feeStructure['tuition_fees'] is List) {
      for (var fee in feeStructure['tuition_fees']) {
        fastFeeData.add({
          'key': 'Tuition Fee - ${fee['Program']}',
          'value': fee['Fee'] ?? 'N/A',
        });
      }
    }
    if (feeStructure['student_activities_fund'] != null) {
      fastFeeData.add({
        'key': 'Student Activities Fund',
        'value': feeStructure['student_activities_fund'].toString(),
      });
    }

    Widget buildSectionContent(List<Map<String, String>> data) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.where((entry) => entry['value'] != 'N/A').map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
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
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                const Text(': ', style: TextStyle(fontWeight: FontWeight.w600)),
                Expanded(
                  flex: 3,
                  child: Text(
                    entry['value']!,
                    style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FAST University Merit Check',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Admission and Fee Details',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.deepPurple,
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
                          color: Colors.deepPurple,
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
                      color: Colors.deepPurple.shade50,
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
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'FAST Match: ${hasFastMatch ? 'Yes' : 'No'}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: hasFastMatch ? Colors.green.shade700 : Colors.red.shade600,
                          ),
                        ),
                        if (hasFastMatch) ...[
                          Text(
                            'Matched Field: $matchedField',
                            style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                          ),
                          Text(
                            'Value: $matchedValue',
                            style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                          ),
                        ],
                        if (!hasFastMatch)
                          Text(
                            'No matching FAST University data found.',
                            style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                          ),
                      ],
                    ),
                  ),
                  ExpansionTile(
                    leading: const Icon(Icons.person, color: Colors.deepPurple),
                    title: const Text(
                      'Personal Details',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple),
                    ),
                    initiallyExpanded: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: buildSectionContent(personalData),
                      ),
                    ],
                  ),
                  const Divider(height: 30, thickness: 1, color: Colors.deepPurple),
                  if (hasValidAcademicMarks)
                    ExpansionTile(
                      leading: const Icon(Icons.book, color: Colors.deepPurple),
                      title: const Text(
                        'Academic Marks',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple),
                      ),
                      initiallyExpanded: true,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: buildSectionContent(academicMarks),
                        ),
                      ],
                    ),
                  if (hasValidAcademicMarks)
                    const Divider(height: 30, thickness: 1, color: Colors.deepPurple),
                  if (fastUniversityData.isNotEmpty || fastFeeData.isNotEmpty) ...[
                    if (fastUniversityData.isNotEmpty)
                      ExpansionTile(
                        leading: const Icon(Icons.school, color: Colors.deepPurple),
                        title: const Text(
                          'FAST University Data',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple),
                        ),
                        initiallyExpanded: true,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: buildSectionContent(
                              fastUniversityData.entries.map((e) => {
                                'key': _formatKey(e.key),
                                'value': formatValue(e.value),
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    if (fastFeeData.isNotEmpty) ...[
                      const Divider(height: 30, thickness: 1, color: Colors.deepPurple),
                      ExpansionTile(
                        leading: const Icon(Icons.attach_money, color: Colors.deepPurple),
                        title: const Text(
                          'FAST Fee Structure',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple),
                        ),
                        initiallyExpanded: true,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: buildSectionContent(fastFeeData),
                          ),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.w600),
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

  String _formatKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) => '${match[1]} ${match[2]}')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Widget _buildFeeCard(String title, dynamic content) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            if (content is List)
              ...content.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.circle, size: 8, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item is Map
                                ? '${item['Program'] ?? item['Percentage of Fee'] ?? ''}: ${item['Fee'] ?? item['Timeline'] ?? ''}'
                                : item.toString(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ))
            else if (content is Map)
              ...content.entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            _formatKey(entry.key),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                        const Text(': '),
                        Expanded(
                          flex: 3,
                          child: Text(
                            entry.value.toString(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ))
            else
              Text(
                content.toString(),
                style: const TextStyle(fontSize: 14),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.studentData;

    final feeStructure = fastData['fee_structure'] ?? fastData;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'FAST University',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 5,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.school),
            tooltip: 'Scholarships',
            onPressed: () {
              context.go('/fast_scholarship', extra: student);
            },
          ),
          IconButton(
            icon: const Icon(Icons.dashboard_customize),
            tooltip: 'Student Dashboard',
            onPressed: () {
              context.go('/student_dashboard', extra: student);
            },
          ),
          IconButton(
            icon: const Icon(Icons.people_alt_rounded),
            tooltip: 'Connect with Alumni',
            onPressed: () {
              context.go('/connect-alumni', extra: student);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      error!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => showFastMeritCheck(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          icon: const Icon(Icons.check_circle_outline, size: 24),
                          label: const Text(
                            'Check Merit & Details',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _sectionTitle("FAST University Fee Structure"),
                      if (feeStructure['tuition_fees'] != null)
                        _buildFeeCard('Tuition Fees', feeStructure['tuition_fees']),
                      if (feeStructure['student_activities_fund'] != null)
                        _buildFeeCard('Student Activities Fund', feeStructure['student_activities_fund']),
                      if (feeStructure['miscellaneous_fees'] != null)
                        _buildFeeCard('Miscellaneous Fees', feeStructure['miscellaneous_fees']),
                      if (feeStructure['refund_policy'] != null && feeStructure['refund_policy']['refund_timeline'] != null)
                        _buildFeeCard('Refund Policy', feeStructure['refund_policy']['refund_timeline']),
                      if (feeStructure['late_payment_fine'] != null)
                        _buildFeeCard('Late Payment Policy', feeStructure['late_payment_fine']),
                      if (feeStructure['payment_methods'] != null)
                        _buildFeeCard('Payment Methods', feeStructure['payment_methods']),
                    ],
                  ),
                ),
    );
  }
}