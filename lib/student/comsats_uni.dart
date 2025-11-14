import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class ComsatsUni extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const ComsatsUni({super.key, required this.studentData});

  @override
  State<ComsatsUni> createState() => _ComsatsUniState();
}

class _ComsatsUniState extends State<ComsatsUni> {
  List<String> comsats = [
    'comsats',
    'Comsats',
    'comsat',
    'Comsat',
    'CUI',
  ];

  List<Map<String, dynamic>> feesList = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchFeeData();
  }

  Future<void> fetchFeeData() async {
    try {
      final uri = Uri.parse('http://192.168.100.121:5000/feescomsats');
      final response = await http.get(uri);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print('Raw API response: $decoded');

        if (decoded is Map && decoded.containsKey('fee_structure')) {
          final feeStructure = decoded['fee_structure'];

          if (feeStructure is Map) {
            final List<Map<String, dynamic>> convertedList = [];
            feeStructure.forEach((key, value) {
              if (value is Map) {
                final item = Map<String, dynamic>.from(value);
                item['Fee Structure'] = item['Fee Structure']?.toString().trim().isEmpty ?? true
                    ? 'No fee information available'
                    : item['Fee Structure']?.toString() ?? 'No fee information available';
                convertedList.add(item);
              }
            });

            setState(() {
              feesList = convertedList;
              isLoading = false;
            });
          } else if (feeStructure is List) {
            final List<Map<String, dynamic>> convertedList = feeStructure
                .whereType<Map>()
                .map((e) {
                  final item = Map<String, dynamic>.from(e);
                  item['Fee Structure'] = item['Fee Structure']?.toString().trim().isEmpty ?? true
                      ? 'No fee information available'
                      : item['Fee Structure']?.toString() ?? 'No fee information available';
                  return item;
                })
                .toList();

            setState(() {
              feesList = convertedList;
              isLoading = false;
            });
          } else {
            setState(() {
              error = 'Unexpected fee_structure format: ${feeStructure.runtimeType}';
              isLoading = false;
            });
            print('Error: Unexpected fee_structure format - ${feeStructure.runtimeType}');
          }
        } else {
          setState(() {
            error = 'Unexpected JSON format: Missing fee_structure field';
            isLoading = false;
          });
          print('Error: Missing fee_structure field in response');
        }
      } else {
        setState(() {
          error = 'Error loading data: ${response.statusCode}';
          isLoading = false;
        });
        print('Error: HTTP ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Failed to load data: ${e.toString()}';
        isLoading = false;
      });
      print('Exception: $e');
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

  String getProgramName(Map<String, dynamic> item) {
    return item["Course/Program Name"]?.toString() ??
           item["Program Name"]?.toString() ?? "N/A";
  }

  String getFeeDisplay(Map<String, dynamic> item) {
    if (item.containsKey('Total BSCS fee for 1st Semester')) {
      return item['Total BSCS fee for 1st Semester'].toString();
    } else if (item.containsKey('Total BBA fee for 1st Semester')) {
      return item['Total BBA fee for 1st Semester'].toString();
    } else if (item.containsKey('Fee Structure')) {
      return item['Fee Structure'].toString();
    } else if (item.containsKey('Total 1st Semester Fee')) {
      return item['Total 1st Semester Fee'].toString();
    }
    return 'No fee information available';
  }

  String formatValue(dynamic value) {
    if (value is double) {
      return value.toStringAsFixed(1);
    }
    return value?.toString() ?? 'N/A';
  }

  void _showStudentInfo(BuildContext context) {
    final hasCGPA = widget.studentData.containsKey('cgpa') || widget.studentData.containsKey('bachelors_cgpa');
    final cgpaValue = widget.studentData['cgpa'] ?? widget.studentData['bachelors_cgpa'];
    final isOA = widget.studentData['is_o_a_level'] ?? false;

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
            _infoTile("Name", widget.studentData['student_name'] ?? widget.studentData['name'] ?? 'N/A'),
            _infoTile("Email", widget.studentData['email'] ?? 'N/A'),
            _infoTile("Program", widget.studentData['program'] ?? 'N/A'),
            if (hasCGPA) _infoTile("CGPA", formatValue(cgpaValue)),
            if (isOA) ...[
              _infoTile("O-Level Marks", formatValue(widget.studentData['o_level_marks'])),
              _infoTile("A-Level Marks", formatValue(widget.studentData['a_level_marks'])),
            ] else ...[
              _infoTile("Matric Marks", formatValue(widget.studentData['matric_marks'])),
              _infoTile("FSC Marks", formatValue(widget.studentData['fsc_marks'])),
            ],
            _infoTile("Fields", (widget.studentData['selected_fields'] is List && (widget.studentData['selected_fields'] as List).isNotEmpty)
                ? (widget.studentData['selected_fields'] as List).join(', ')
                : (widget.studentData['fields'] is List && (widget.studentData['fields'] as List).isNotEmpty)
                    ? (widget.studentData['fields'] as List).join(', ')
                    : 'N/A'),
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

  void _showMeritCheck(BuildContext context) {
    print('=== Merit Check Start ===');
    print('studentData: ${widget.studentData}');
    print('comsats list: $comsats');
    print('=========================');

    bool hasComsatsMatch = false;
    String matchedField = '';
    String matchedValue = '';

    widget.studentData.forEach((key, value) {
      if (value != null) {
        final keyLower = key.toLowerCase();
        final valueLower = value.toString().toLowerCase();
        for (var comsatsName in comsats) {
          final comsatsLower = comsatsName.toLowerCase();
          if (keyLower.contains(comsatsLower) || valueLower.contains(comsatsLower)) {
            hasComsatsMatch = true;
            matchedField = key;
            matchedValue = value.toString();
            break;
          }
        }
      }
      if (hasComsatsMatch) return;
    });

    if (!hasComsatsMatch && widget.studentData['full_api_response'] != null) {
      final universities = widget.studentData['full_api_response']['universities'];
      if (universities is List && universities.isNotEmpty) {
        for (var uni in universities) {
          if (uni is Map && uni.containsKey('name')) {
            final uniName = uni['name']?.toString().toLowerCase() ?? '';
            for (var comsatsName in comsats) {
              if (uniName.contains(comsatsName.toLowerCase())) {
                hasComsatsMatch = true;
                matchedField = 'full_api_response.universities.name';
                matchedValue = uni['name'].toString();
                break;
              }
            }
            if (hasComsatsMatch) break;
          }
        }
      }
    }

    print('COMSATS Match: $hasComsatsMatch, Matched Field: $matchedField, Value: $matchedValue');

    final comsatsData = <String, dynamic>{};
    widget.studentData.forEach((key, value) {
      if (key.toLowerCase().contains('comsats')) {
        comsatsData[key] = value;
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

    final programFee = feesList.firstWhere(
      (item) => getProgramName(item) == normalizedStudentProgram,
      orElse: () => {'Fee Structure': 'No fee information available'},
    );

    print('Program Fee Match: $programFee');

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
      {'key': 'COMSATS University Name', 'value': formatValue(comsatsData['comsats_university_name'])},
      {'key': 'COMSATS Admitted', 'value': formatValue(comsatsData['comsats_admitted'])},
      {'key': 'COMSATS Last Actual Cutoff', 'value': formatValue(comsatsData['comsats_last_actual_cutoff'])},
      {'key': 'COMSATS Student Aggregate', 'value': formatValue(comsatsData['comsats_student_aggregate'])},
      {'key': 'COMSATS Aggregate', 'value': formatValue(comsatsData['comsats_aggregate'])},
      if (!hasCGPA) ...[
        {'key': 'COMSATS Admission Chance', 'value': formatValue(comsatsData['comsats_admission_chance'])},
        {'key': 'COMSATS Predicted 2026 Aggregate', 'value': formatValue(comsatsData['comsats_predicted_2026_aggregate'])},
      ],
      {'key': 'Program Fee Structure', 'value': formatValue(programFee['Fee Structure'])},
      {'key': 'Admission Fee (one time)', 'value': formatValue(programFee['Admission Fee (one time)'])},
      {'key': 'Registration Fee (per semester)', 'value': formatValue(programFee['Registration Fee (per semester)'])},
      {'key': 'Tuition Fee (per semester)', 'value': formatValue(programFee['Tuition fee (Per semester)'])},
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
                'COMSATS Merit Check',
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
                          'COMSATS Match: ${hasComsatsMatch ? 'Yes' : 'No'}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: hasComsatsMatch ? Colors.green.shade700 : Colors.red.shade600,
                          ),
                        ),
                        if (hasComsatsMatch) ...[
                          Text(
                            'Matched Field: $matchedField',
                            style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                          ),
                          Text(
                            'Value: $matchedValue',
                            style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                          ),
                        ],
                        if (!hasComsatsMatch)
                          Text(
                            'No matching COMSATS data found.',
                            style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                          ),
                      ],
                    ),
                  ),
                  if (hasComsatsMatch) ...[
                    if (programFee['Fee Structure'] == 'No fee information available')
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          'No fee information available for your program.',
                          style: TextStyle(color: Colors.red.shade600, fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ExpansionTile(
                      leading: const Icon(Icons.school, color: Colors.indigo),
                      title: const Text(
                        'COMSATS University Data',
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }

  Widget _buildFeeCard(Map<String, dynamic> item) {
    final program = getProgramName(item);
    final duration = item["Duration"]?.toString() ?? "N/A";
    final fee = getFeeDisplay(item);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              program,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (duration.isNotEmpty && duration != '') Text("Duration: $duration"),
            const SizedBox(height: 4),
            if (item.containsKey('Admission Fee (one time)'))
              Text("Admission Fee: ${item['Admission Fee (one time)']}"),
            if (item.containsKey('Registration Fee (per semester)'))
              Text("Registration Fee: ${item['Registration Fee (per semester)']}"),
            if (item.containsKey('Tuition fee (Per semester)'))
              Text("Tuition Fee: ${item['Tuition fee (Per semester)']}"),
            const SizedBox(height: 4),
            Text(
              fee,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'COMSATS',
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
            icon: const Icon(Icons.dashboard),
            tooltip: 'Dashboard',
            onPressed: () => context.go('/student_dashboard', extra: widget.studentData),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Student Info',
            onPressed: () {
              print('Student Data: ${widget.studentData}');
              _showStudentInfo(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.school),
            tooltip: 'Scholarships',
            onPressed: () => context.go('/scholarships', extra: widget.studentData),
          ),
          IconButton(
            icon: const Icon(Icons.connect_without_contact),
            tooltip: 'Connect with Alumni',
            onPressed: () => context.go('/connect-alumni', extra: widget.studentData),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionTitle("Fee Structure (All Programs)"),
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
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: feesList.isEmpty
                            ? const Center(
                                child: Text(
                                  'No fee data available',
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                itemCount: feesList.length,
                                itemBuilder: (context, index) => _buildFeeCard(feesList[index]),
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}