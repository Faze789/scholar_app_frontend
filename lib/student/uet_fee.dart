import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class UetFeePage extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const UetFeePage({super.key, required this.studentData});

  @override
  State<UetFeePage> createState() => _UetFeePageState();
}

class _UetFeePageState extends State<UetFeePage> {
  List<String> uet = [
    'Uet Lahore',
    'uet',
    'UET',
    'University of Engineering and Technology',
  ];
  List<dynamic> feeData = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchFeeData();
  }

  Future<void> fetchFeeData() async {
    try {
      final response =
          await http.get(Uri.parse("http://192.168.100.149:5000/feesuet"));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded["status"] == "success") {
          setState(() {
            feeData = decoded["fee_structure"];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "Failed to load fee data.";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Server error: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  String formatValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is double) return value.toStringAsFixed(2);
    return value.toString();
  }

  String _formatKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) => '${match[1]} ${match[2]}')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _getProgramDisplay() {
    String program = widget.studentData['program']?.toString() ?? '';
    List<dynamic> fields = widget.studentData['selected_fields'] ?? widget.studentData['fields'] ?? [];
    if (fields.isNotEmpty) {
      return '$program ${fields.join(', ')}';
    }
    return program.isEmpty ? 'N/A' : program;
  }

  String _getFieldsDisplay() {
    List<dynamic> selectedFields = widget.studentData['selected_fields'] ?? [];
    List<dynamic> fields = widget.studentData['fields'] ?? [];
    if (selectedFields.isNotEmpty) {
      return selectedFields.join(', ');
    } else if (fields.isNotEmpty) {
      return fields.join(', ');
    }
    return 'N/A';
  }

  void _showMeritCheck(BuildContext context) {
    print('=== UET Merit Check Start ===');
    print('studentData: ${widget.studentData}');
    print('is_o_a_level: ${widget.studentData['is_o_a_level']}');
    print('O-Level Marks: ${widget.studentData['o_level_marks']}');
    print('A-Level Marks: ${widget.studentData['a_level_marks']}');
    print('O-Level Equivalence: ${widget.studentData['o_level_equivalence']}');
    print('A-Level Equivalence: ${widget.studentData['a_level_equivalence']}');
    print('Matric Marks: ${widget.studentData['matric_marks']}');
    print('FSC Marks: ${widget.studentData['fsc_marks']}');
    print('Bachelors CGPA: ${widget.studentData['bachelors_cgpa']}');
    print('CGPA: ${widget.studentData['cgpa']}');
    print('Aggregate: ${widget.studentData['aggregate']}');
    print('====================================');

    final uetData = <String, dynamic>{};
    widget.studentData.forEach((key, value) {
      if (key.toLowerCase().contains('uet')) {
        uetData[key] = value;
      }
    });

    bool hasUetMatch = uetData.isNotEmpty;
    String matchedField = '';
    String matchedValue = '';
    if (hasUetMatch) {
      var firstEntry = uetData.entries.first;
      matchedField = firstEntry.key;
      matchedValue = formatValue(firstEntry.value);
    }

    final hasCGPA = widget.studentData.containsKey('bachelors_cgpa') || widget.studentData.containsKey('cgpa');
    final isOALevel = widget.studentData['is_o_a_level'] == true;
    final educationSystem = isOALevel ? 'O/A Level' : 'Matric/FSc';

    final academicMarks = <Map<String, String>>[
      if (widget.studentData.containsKey('bachelors_cgpa'))
        {'key': 'Bachelor\'s CGPA', 'value': formatValue(widget.studentData['bachelors_cgpa'])},
      if (widget.studentData.containsKey('cgpa'))
        {'key': 'CGPA', 'value': formatValue(widget.studentData['cgpa'])},
      if (isOALevel) ...[
        if (widget.studentData.containsKey('o_level_marks'))
          {'key': 'O-Level Marks', 'value': formatValue(widget.studentData['o_level_marks'])},
        if (widget.studentData.containsKey('a_level_marks'))
          {'key': 'A-Level Marks', 'value': formatValue(widget.studentData['a_level_marks'])},
        if (widget.studentData.containsKey('o_level_equivalence'))
          {'key': 'O-Level Equivalence', 'value': formatValue(widget.studentData['o_level_equivalence'])},
        if (widget.studentData.containsKey('a_level_equivalence'))
          {'key': 'A-Level Equivalence', 'value': formatValue(widget.studentData['a_level_equivalence'])},
      ] else ...[
        if (widget.studentData.containsKey('matric_marks'))
          {'key': 'Matric Marks', 'value': formatValue(widget.studentData['matric_marks'])},
        if (widget.studentData.containsKey('fsc_marks'))
          {'key': 'FSC Marks', 'value': formatValue(widget.studentData['fsc_marks'])},
      ],
    ];

    final hasValidAcademicMarks = academicMarks.any((entry) => entry['value'] != 'N/A');

    final universityData = <Map<String, String>>[
      if (uetData.isNotEmpty)
        ...uetData.entries.map((entry) => {
              'key': _formatKey(entry.key),
              'value': formatValue(entry.value),
            }),
    ];

    final personalDetails = <Map<String, String>>[
      {'key': 'Name', 'value': formatValue(widget.studentData['student_name'] ?? widget.studentData['name'])},
      {'key': 'Father Name', 'value': formatValue(widget.studentData['father_name'])},
      {'key': 'Email', 'value': formatValue(widget.studentData['email'])},
      {'key': 'Program Name', 'value': _getProgramDisplay()},
      {'key': 'Fields', 'value': _getFieldsDisplay()},
    ];

    Widget buildSectionContent(List<Map<String, String>> data) {
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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'UET Merit Check',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Admission and Fee Details ($educationSystem)',
                style: const TextStyle(
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
                          'UET Match: ${hasUetMatch ? 'Yes' : 'No'}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: hasUetMatch ? Colors.green.shade700 : Colors.red.shade600,
                          ),
                        ),
                        if (hasUetMatch) ...[
                          Text(
                            'Matched Field: $matchedField',
                            style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                          ),
                          Text(
                            'Value: $matchedValue',
                            style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                          ),
                        ],
                        if (!hasUetMatch)
                          Text(
                            'No matching UET data found.',
                            style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                          ),
                      ],
                    ),
                  ),
                  if (hasUetMatch && !hasCGPA) ...[
                    ExpansionTile(
                      leading: const Icon(Icons.school, color: Colors.indigo),
                      title: const Text(
                        'UET University Data',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo),
                      ),
                      initiallyExpanded: true,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: buildSectionContent(universityData),
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
                      title: Text(
                        '$educationSystem Marks',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo),
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
                          'Full Program: ${_getProgramDisplay()}',
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
                          'Fields: ${_getFieldsDisplay()}',
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

  Widget _buildFeeCard(Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item["UET BSCS 4-Year Program"] ?? "",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildFeeDetail(
                    "Partially Subsidized",
                    item["Partially Subsidized"],
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFeeDetail(
                    "Subsidized",
                    item["Subsidized"],
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeDetail(String label, String? value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? "N/A",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UET University',
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
          ElevatedButton(
            onPressed: () => _showMeritCheck(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Merit Check',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.school),
            tooltip: 'Scholarship',
            onPressed: () {
              context.push(
                '/uet-scholarships',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: feeData.length,
                  itemBuilder: (context, index) {
                    return _buildFeeCard(feeData[index]);
                  },
                ),
    );
  }
}