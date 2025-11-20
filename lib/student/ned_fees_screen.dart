import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class NedFeesScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const NedFeesScreen({super.key, required this.studentData});

  @override
  State<NedFeesScreen> createState() => _NedFeesScreenState();
}

class _NedFeesScreenState extends State<NedFeesScreen> {
  List<String> ned = [
    "ned",
    "NED",
    "Ned University",
    "Ned",
    "NED University of Engineering and Technology",
  ];
  List<Map<String, dynamic>> feeBreakdown = [];
  List<Map<String, dynamic>> programs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchNedFees();
  }
  

  Future<void> fetchNedFees() async {
    const String url = 'http://35.174.6.20:5000/nedfees';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("Received response: $data");

        if (data != null && data is Map && data.containsKey('fee_structure')) {
          final feeStructure = data['fee_structure'];
          
          if (feeStructure is List) {
            setState(() {
              feeBreakdown = feeStructure
                  .where((item) => item.containsKey('Description'))
                  .map((item) => {
                        'description': item['Description'] ?? 'No description',
                        'amount': item['Amount'] ?? 'No amount'
                      })
                  .toList();

              programs = feeStructure
                  .where((item) => item.containsKey('Course/Program Name'))
                  .map((item) => {
                        'program': item['Course/Program Name'] ?? 'No program',
                        'duration': item['Duration'] ?? 'N/A',
                        'fee_structure': item['Fee Structure'] ?? 'Not available'
                      })
                  .toList();

              _isLoading = false;
            });
          } else {
            setState(() {
              _error = 'Unexpected fee_structure format: ${feeStructure.runtimeType}';
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _error = 'Missing fee_structure in response';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  String getProgramDisplay() {
    String program = widget.studentData['program']?.toString() ?? '';
    List<String> selectedFields = [];

    if (widget.studentData['selected_fields'] != null) {
      if (widget.studentData['selected_fields'] is List) {
        selectedFields = List<String>.from(widget.studentData['selected_fields']);
      } else if (widget.studentData['selected_fields'] is String) {
        selectedFields = [widget.studentData['selected_fields'].toString()];
      }
    } else if (widget.studentData['fields'] != null) {
      if (widget.studentData['fields'] is List) {
        selectedFields = List<String>.from(widget.studentData['fields']);
      } else if (widget.studentData['fields'] is String) {
        selectedFields = [widget.studentData['fields'].toString()];
      }
    }

    if (program == 'BS' && selectedFields.isNotEmpty) {
      if (selectedFields.contains('Computer Science') || selectedFields.contains('CS')) {
        program = 'Bachelor of Science in Computer Science';
      } else if (selectedFields.contains('Business Administration') || selectedFields.contains('BBA')) {
        program = 'Bachelor of Science in Business Administration';
      } else if (selectedFields.contains('Psychology')) {
        program = 'Bachelor of Science in Psychology';
      }
    }

    if (program.isNotEmpty && selectedFields.isNotEmpty) {
      return '$program ${selectedFields.join(", ")}';
    } else if (program.isNotEmpty) {
      return program;
    }
    return widget.studentData['program_display']?.toString() ?? 'N/A';
  }

  String formatValue(dynamic value) {
    if (value is double) {
      return value.toStringAsFixed(1);
    }
    return value?.toString() ?? 'N/A';
  }
void _showMeritCheck(BuildContext context) {
  print('=== NED Merit Check Start ===');
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
  print('NED list: $ned');
  print('=============================');

  bool hasNedMatch = false;
  String matchedField = '';
  String matchedValue = '';

  widget.studentData.forEach((key, value) {
    if (value != null) {
      final keyLower = key.toLowerCase();
      final valueLower = value.toString().toLowerCase();
      for (var nedName in ned) {
        final nedLower = nedName.toLowerCase();
        if (keyLower.contains(nedLower) || valueLower.contains(nedLower)) {
          hasNedMatch = true;
          matchedField = key;
          matchedValue = value.toString();
          break;
        }
      }
    }
    if (hasNedMatch) return;
  });

  if (!hasNedMatch && widget.studentData['full_api_response'] != null) {
    final universities = widget.studentData['full_api_response']['universities'];
    if (universities is List && universities.isNotEmpty) {
      for (var uni in universities) {
        if (uni is Map && uni.containsKey('name')) {
          final uniName = uni['name']?.toString().toLowerCase() ?? '';
          for (var nedName in ned) {
            if (uniName.contains(nedName.toLowerCase())) {
              hasNedMatch = true;
              matchedField = 'full_api_response.universities.name';
              matchedValue = uni['name'].toString();
              break;
            }
          }
          if (hasNedMatch) break;
        }
      }
    }
  }

  print('NED Match: $hasNedMatch, Matched Field: $matchedField, Value: $matchedValue');

  final nedData = <String, dynamic>{};
  widget.studentData.forEach((key, value) {
    if (key.toLowerCase().contains('ned')) {
      nedData[key] = value;
    }
  });

  final hasCGPA = widget.studentData.containsKey('bachelors_cgpa') || widget.studentData.containsKey('cgpa');
  final isOA = widget.studentData['is_o_a_level'] ?? false;

  final nedAdmissionData = [
    {'key': 'University Name', 'value': formatValue(nedData['ned_name'] ?? 'NED University')},
    {'key': 'Test Used', 'value': formatValue(nedData['ned_test_used'] ?? 'N/A')},
    {'key': 'Student Aggregate', 'value': formatValue(nedData['ned_student_aggregate'] ?? 'N/A')},
    {'key': 'Last Year Aggregate', 'value': formatValue(nedData['ned_last_year_aggregate'] ?? 'N/A')},
    {'key': 'NED Marks', 'value': formatValue(nedData['ned_marks'] ?? 'N/A')},
    if (!hasCGPA) {'key': 'Predicted 2026 Aggregate', 'value': formatValue(nedData['ned_predicted_2026_aggregate'] ?? 'N/A')},
  ];

  final personalDetails = [
    {'key': 'Name', 'value': formatValue(widget.studentData['student_name'] ?? widget.studentData['name'])},
    {'key': 'Father Name', 'value': formatValue(widget.studentData['father_name'])},
    {'key': 'Email', 'value': formatValue(widget.studentData['email'])},
    {'key': 'Program Name', 'value': getProgramDisplay()},
    {
      'key': 'Fields',
      'value': (widget.studentData['selected_fields'] is List &&
              (widget.studentData['selected_fields'] as List).isNotEmpty)
          ? (widget.studentData['selected_fields'] as List).join(', ')
          : (widget.studentData['fields'] is List &&
                  (widget.studentData['fields'] as List).isNotEmpty)
              ? (widget.studentData['fields'] as List).join(', ')
              : 'N/A'
    },
  ];

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
                    color: Colors.indigo,
                  ),
                ),
              ),
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
              'NED Merit Check',
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
                ExpansionTile(
                  leading: const Icon(Icons.school, color: Colors.indigo),
                  title: const Text(
                    'NED Admission Data',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo),
                  ),
                  initiallyExpanded: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: buildSectionContent(nedAdmissionData),
                    ),
                  ],
                ),
                const Divider(height: 30, thickness: 1, color: Colors.indigo),
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
                        child: buildSectionContent(academicMarks),
                      ),
                    ],
                  ),
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

  Widget _buildOverviewSection() {
    if (feeBreakdown.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'General Fee Breakdown:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ...feeBreakdown.map((item) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(item['description'] ?? 'No description'),
                trailing: Text(item['amount'] ?? 'No amount'),
              ),
            )),
        const Divider(),
      ],
    );
  }

  Widget _buildUniversityCard(Map<String, dynamic> uni) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(uni['program'] ?? 'Program',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Duration: ${uni['duration'] ?? 'N/A'} years'),
            const SizedBox(height: 4),
            Text('Fee Structure: ${uni['fee_structure'] ?? 'Not available'}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentName = widget.studentData['name'] ?? 'Student';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NED University',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
        elevation: 5,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment),
            tooltip: 'Merit Check',
            onPressed: () => _showMeritCheck(context),
          ),
          IconButton(
            icon: const Icon(Icons.school),
            tooltip: 'Scholarships',
            onPressed: () {
              context.push(
                '/need-scholarships',
                extra: widget.studentData,
              );
            },
          ),
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
          IconButton(
            icon: const Icon(Icons.people_alt_rounded),
            tooltip: 'Connect with Alumni',
            onPressed: () {
              context.go(
                '/connect-alumni',
                extra: widget.studentData,
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_error!,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.redAccent)),
                  ),
                )
              : ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Welcome $studentName!\nHere is the fee structure for NED:',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                    _buildOverviewSection(),
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Programs Offered:',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...programs.map((uni) => _buildUniversityCard(uni)),
                    const SizedBox(height: 16),
                  ],
                ),
    );
  }
}