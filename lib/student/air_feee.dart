import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

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

  List<String> airVariations = [
    'air',
    'Air',
    'AIR',
    'air university',
    'Air University',
    'AIR University'
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final response = await http.get(Uri.parse("http://35.174.6.20:5000/feesair"));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        
        if (decoded is Map<String, dynamic> && decoded.containsKey("fee_structure")) {
          setState(() {
            feeData = decoded["fee_structure"];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "Invalid API response structure";
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
        errorMessage = "Error fetching data: $e";
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

  void _showMeritCheck(BuildContext context) {
    print('=== Air University Merit Check Start ===');
    print('studentData: ${widget.studentData}');
    print('air variations: $airVariations');
    print('=========================');

    bool hasAirMatch = false;
    String matchedField = '';
    String matchedValue = '';

    widget.studentData.forEach((key, value) {
      if (value != null) {
        final keyLower = key.toLowerCase();
        final valueLower = value.toString().toLowerCase();
        for (var airName in airVariations) {
          final airLower = airName.toLowerCase();
          if (keyLower.contains(airLower) || valueLower.contains(airLower)) {
            hasAirMatch = true;
            matchedField = key;
            matchedValue = value.toString();
            break;
          }
        }
      }
      if (hasAirMatch) return;
    });

    if (!hasAirMatch && widget.studentData['full_api_response'] != null) {
      final universities = widget.studentData['full_api_response']['universities'];
      if (universities is List && universities.isNotEmpty) {
        for (var uni in universities) {
          if (uni is Map && uni.containsKey('name')) {
            final uniName = uni['name']?.toString().toLowerCase() ?? '';
            for (var airName in airVariations) {
              if (uniName.contains(airName.toLowerCase())) {
                hasAirMatch = true;
                matchedField = 'full_api_response.universities.name';
                matchedValue = uni['name'].toString();
                break;
              }
            }
            if (hasAirMatch) break;
          }
        }
      }
    }

    print('Air University Match: $hasAirMatch, Matched Field: $matchedField, Value: $matchedValue');

    final airData = <String, dynamic>{};
    widget.studentData.forEach((key, value) {
      if (key.toLowerCase().contains('air')) {
        airData[key] = value;
      }
    });

    final studentProgram = widget.studentData['program']?.toString() ?? 'N/A';
    final normalizedStudentProgram = studentProgram == 'BS' && (widget.studentData['selected_fields']?.contains('Computer Science') ?? false)
        ? 'Bachelor of Science in Computer Science'
        : studentProgram == 'BS' && (widget.studentData['selected_fields']?.contains('Business Administration') ?? false)
            ? 'Bachelor of Science in Business Administration'
            : studentProgram == 'BS' && (widget.studentData['selected_fields']?.contains('Psychology') ?? false)
                ? 'Bachelor of Science in Psychology'
                : studentProgram
                    .replaceAll('BSCS', 'Bachelor of Science in Computer Science')
                    .replaceAll('BBA', 'Bachelor of Science in Business Administration')
                    .replaceAll('BS Psychology', 'Bachelor of Science in Psychology');

    final hasCGPA = widget.studentData.containsKey('cgpa') || widget.studentData.containsKey('bachelors_cgpa');
    final cgpaValue = widget.studentData['cgpa'] ?? widget.studentData['bachelors_cgpa'];
    final isOA = widget.studentData['is_o_a_level'] ?? false;

    final academicMarks = [
      if (hasCGPA) {'key': 'CGPA', 'value': formatValue(cgpaValue)},
      if (isOA) ...[
        {'key': 'O-Level Marks', 'value': formatValue(widget.studentData['o_level_marks'])},
        {'key': 'A-Level Marks', 'value': formatValue(widget.studentData['a_level_marks'])},
      ] else ...[
        {'key': 'Matric Marks', 'value': formatValue(widget.studentData['matric_marks'])},
        {'key': 'FSC Marks', 'value': formatValue(widget.studentData['fsc_marks'])},
      ],
      {'key': 'NTS Marks', 'value': formatValue(widget.studentData['nts_marks'])},
      {'key': 'NET Marks', 'value': formatValue(widget.studentData['net_marks'])},
    ];

    final hasValidAcademicMarks = academicMarks.any((entry) => entry['value'] != 'N/A');

    final universityData = [
      {'key': 'Program Name', 'value': getProgramDisplay()},
      {'key': 'Air University Name', 'value': formatValue(airData['air_university_name'])},
      {'key': 'Air University Admitted', 'value': formatValue(airData['air_admitted'])},
      {'key': 'Air University Last Actual Cutoff', 'value': formatValue(airData['air_last_actual_cutoff'])},
      {'key': 'Air University Student Aggregate', 'value': formatValue(airData['air_student_aggregate'])},
      {'key': 'Air University Aggregate', 'value': formatValue(airData['air_aggregate'])},
      if (!hasCGPA) ...[
        {'key': 'Air University Admission Chance', 'value': formatValue(airData['air_admission_chance'])},
        {'key': 'Air University Predicted 2026 Aggregate', 'value': formatValue(airData['air_predicted_2026_aggregate'])},
      ],
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
                'Air University Merit Check',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Admission and Fee Details',
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
           
                  if (hasAirMatch) ...[
                    
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
                          child: buildSectionContent(universityData),
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
                    const Divider(height: 30, thickness: 1, color: Colors.indigo),
                    if (hasValidAcademicMarks)
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
                    if (hasValidAcademicMarks) const Divider(height: 30, thickness: 1, color: Colors.indigo),
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
                            'Program: ${widget.studentData['program'] ?? 'N/A'}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                          ),
                          Text(
                            'Fields: ${(widget.studentData['selected_fields'] is List && (widget.studentData['selected_fields'] as List).isNotEmpty) ? (widget.studentData['selected_fields'] as List).join(', ') : (widget.studentData['fields'] is List && (widget.studentData['fields'] as List).isNotEmpty) ? (widget.studentData['fields'] as List).join(', ') : 'N/A'}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                          ),
                        ],
                      ),
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

  Widget _buildFeeCard(String programName, dynamic programData) {
    if (programData is String) {
      return Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "$programName: $programData",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo),
          ),
        ),
      );
    } else if (programData is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            programName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo),
          ),
          const SizedBox(height: 8),
          ...programData.map((item) {
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(item["Course/Program Name"] ?? "N/A"),
                subtitle: Text(item["Fee Structure"] ?? "N/A"),
                trailing: Text(item["Duration"] ?? ""),
              ),
            );
          }),
        ],
      );
    } else if (programData is Map<String, dynamic>) {
      return _buildFeeCard(programName, programData.values.toList());
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
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
              context.go('/air-scholarship', extra: widget.studentData); 
            },
          ),
          IconButton(
            icon: const Icon(Icons.dashboard_customize, color: Colors.white),
            tooltip: 'Student Dashboard',
            onPressed: () {
              context.go('/student_dashboard', extra: widget.studentData); 
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
                
                      if (feeData != null)
                        ...feeData!.entries.map((entry) => _buildFeeCard(entry.key, entry.value)),

                      const SizedBox(height: 24),
                     
                      buildScholarshipSection(),
                      const SizedBox(height: 24),
                      buildContactSection(),
                    ],
                  ),
                ),
    );
  }

  Widget buildScholarshipSection() => Container(); 
  Widget buildContactSection() => Container(); 
}