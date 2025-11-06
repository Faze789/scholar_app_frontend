import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class uni_of_education_fees extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const uni_of_education_fees({super.key, required this.studentData});

  @override
  State<uni_of_education_fees> createState() => _uni_of_education_feesState();
}

class _uni_of_education_feesState extends State<uni_of_education_fees> {


  List<dynamic> feeList = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchFeeData();
  }

  Future<void> fetchFeeData() async {
    try {
      final uri = Uri.parse('http://192.168.100.121:5000/fees_uni_of_education');
      final response = await http.get(uri);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('API Response Body: ${response.body}');
        print('Decoded Data: $jsonData'); 

        final feeStructure = jsonData['fee_structure'];
        if (feeStructure is List) {
          final mappedFeeList = feeStructure.map((item) {
            return {
              'program': item['Course/Program Name'] ?? 'Unknown Program',
              'duration': item['Duration'] ?? '',
              'fee_structure': item['Fee Structure'] ?? 'Not available',
            };
          }).toList();

          setState(() {
            feeList = mappedFeeList;
            isLoading = false;
          });
        } else {
          setState(() {
            error = 'Error: fee_structure is not a list';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Exception: $e';
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }
String formatValue(dynamic value) {
  if (value is double) {
    return value.toStringAsFixed(1);
  }
  return value?.toString() ?? 'N/A';
}

void _showMeritCheck(BuildContext context) {
  print('=== University of Education Merit Check Start ===');
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

  final universityData = <String, dynamic>{};
  widget.studentData.forEach((key, value) {
    final keyLower = key.toLowerCase();
    if (keyLower.contains('uni_of_education') || 
        keyLower.contains('uni of education') ||
        keyLower.contains('uoe')) {
      universityData[key] = value;
    }
  });

  bool hasUniversityMatch = universityData.isNotEmpty;
  String matchedField = '';
  String matchedValue = '';

  if (hasUniversityMatch) {
    var firstEntry = universityData.entries.first;
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'University of Education Merit Check',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Admission and Fee Details',
              style: TextStyle(
                fontSize: 16,
                color: Colors.teal,
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
                        color: Colors.teal,
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
                    color: Colors.teal.shade50,
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
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'University Match: ${hasUniversityMatch ? 'Yes' : 'No'}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: hasUniversityMatch ? Colors.green.shade700 : Colors.red.shade600,
                        ),
                      ),
                      if (hasUniversityMatch) ...[
                        Text(
                          'Matched Field: $matchedField',
                          style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                        ),
                        Text(
                          'Value: $matchedValue',
                          style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                        ),
                      ],
                      if (!hasUniversityMatch)
                        Text(
                          'No matching University of Education data found.',
                          style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                        ),
                    ],
                  ),
                ),
                if (hasUniversityMatch && !hasCGPA) ...[
                  ExpansionTile(
                    leading: const Icon(Icons.school, color: Colors.teal),
                    title: const Text(
                      'University of Education Data',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal),
                    ),
                    initiallyExpanded: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        child: buildSectionContent(universityData),
                      ),
                    ],
                  ),
                  const Divider(height: 30, thickness: 1, color: Colors.teal),
                ],
                ExpansionTile(
                  leading: const Icon(Icons.person, color: Colors.teal),
                  title: const Text(
                    'Personal Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal),
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
                  const Divider(height: 30, thickness: 1, color: Colors.teal),
                  ExpansionTile(
                    leading: const Icon(Icons.book, color: Colors.teal),
                    title: const Text(
                      'Academic Marks',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal),
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
                const Divider(height: 30, thickness: 1, color: Colors.teal),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
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
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Full Program: ${_getProgramDisplay()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.teal,
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
              style: TextStyle(color: Colors.teal, fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildSectionContent(Map<String, dynamic> data) {
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
                  ),
                ),
              ),
              const Text(': ', style: TextStyle(fontWeight: FontWeight.w600)),
              Expanded(
                flex: 3,
                child: Text(
                  entry.value?.toString() ?? 'N/A',
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

  Widget _buildSectionContentList(List<Map<String, String>> data) {
    if (data.isEmpty) {
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
    List<dynamic> selectedFields = widget.studentData['selected_fields'] ?? [];
    List<dynamic> fields = widget.studentData['fields'] ?? [];

    List<dynamic> fieldsToUse = selectedFields.isNotEmpty ? selectedFields : fields;

    if (fieldsToUse.isNotEmpty) {
      return '$program ${fieldsToUse.join(', ')}';
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

  void _showStudentInfo(BuildContext context) {
    final hasBachelorsCgpa = widget.studentData.containsKey('bachelors_cgpa');
    final cgpaValue = widget.studentData['cgpa'] ?? widget.studentData['bachelors_cgpa'];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text(
              "Your Info",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _infoTile("Name", widget.studentData['name'] ?? widget.studentData['student_name'] ?? 'N/A'),
            _infoTile("Email", widget.studentData['email'] ?? 'N/A'),
            _infoTile("Program", widget.studentData['program'] ?? 'N/A'),
            if (hasBachelorsCgpa || widget.studentData.containsKey('cgpa')) 
              _infoTile(hasBachelorsCgpa ? "Bachelors CGPA" : "CGPA", cgpaValue?.toString() ?? 'N/A'),
            _infoTile("Fields", _getFieldsDisplay()),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Card(
      color: Colors.grey.shade100,
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildFeeCard(Map<String, dynamic> item) {
    final String program = item['program'] ?? 'Unknown Program';
    final String duration = item['duration']?.toString().trim() ?? '';
    final String feeStructure = item['fee_structure'] ?? 'Not available';

    final bool isNoFeeInfo = feeStructure.toLowerCase().contains("no fee");

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: isNoFeeInfo ? Colors.grey.shade200 : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        title: Text(program, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (duration.isNotEmpty) Text("Duration: $duration"),
            const SizedBox(height: 4),
            Text("Fee: $feeStructure"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'University of Education',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 5,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.school),
            tooltip: 'Scholarships',
            onPressed: () {
              context.go('/uoe_scholarship', extra: widget.studentData);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Student Info',
            onPressed: () => _showStudentInfo(context),
          ),
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Return to Dashboard',
            onPressed: () {
              context.go('/student_dashboard', extra: widget.studentData);
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
          : error.isNotEmpty
              ? Center(child: Text(error))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showMeritCheck(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
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
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: feeList.length,
                        itemBuilder: (context, index) {
                          final item = feeList[index] as Map<String, dynamic>;
                          return _buildFeeCard(item);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}