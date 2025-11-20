import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class LumsPage extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const LumsPage({super.key, required this.studentData});

  @override
  State<LumsPage> createState() => _LumsPageState();
}

class _LumsPageState extends State<LumsPage> {
  Map<String, dynamic> feeData = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchFees();
  }

  Future<void> fetchFees() async {
    try {
      final response = await http.get(Uri.parse("http://35.174.6.20:5000/feeslums"));
      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        print('Decoded Data: $decodedData');

        final feeStructure = (decodedData is Map && decodedData.containsKey('fee_structure'))
            ? decodedData['fee_structure']
            : decodedData;

        if (feeStructure is Map) {
          setState(() {
            feeData = Map<String, dynamic>.from(feeStructure);
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "Invalid data format: fee_structure is not a map";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Failed to load data: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: ${e.toString()}";
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  void _showUserInfo() {
    final studentData = widget.studentData;
    final hasCGPA = studentData.containsKey('bachelors_cgpa');
    final isOA = studentData['is_o_a_level'] ?? false;
    
    List<String> orderedKeys;
    
    if (hasCGPA) {
      orderedKeys = [
        'student_name',
        'father_name',
        'email',
        if (isOA) ...['o_level_marks', 'a_level_marks'] else ...['matric_marks', 'fsc_marks'],
        'bachelors_cgpa',
      ];
    } else {
      orderedKeys = [
        'student_name',
        'father_name',
        'email',
        if (isOA) ...['o_level_marks', 'a_level_marks'] else ...['matric_marks', 'fsc_marks'],
        'gpa',
        'lums_student_aggregate',
        'lums_predicted_2026_aggregate',
        'lums_admission_chance',
        'lums_admitted',
      ];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("User Info", style: TextStyle(color: Colors.indigo)),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Personal Information:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ...orderedKeys.where((key) => key.contains('student_name') || key.contains('father_name') || key.contains('email')).map((key) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          "${_formatKey(key, isOA: isOA)}: ${_getDisplayValue(studentData[key])}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }),
                    const SizedBox(height: 8),
                    const Text(
                      "Academic Information:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ...orderedKeys.where((key) => key.contains('matric_marks') || key.contains('fsc_marks') || key.contains('o_level_marks') || key.contains('a_level_marks') || key.contains('gpa') || key.contains('bachelors_cgpa')).map((key) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          "${_formatKey(key, isOA: isOA)}: ${_getDisplayValue(studentData[key])}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }),
                    if (!hasCGPA) ...[
                      const SizedBox(height: 8),
                      const Text(
                        "LUMS Admission Details:",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo),
                      ),
                      const SizedBox(height: 8),
                      ...orderedKeys.where((key) => key.contains('lums')).map((key) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            "${_formatKey(key, isOA: isOA)}: ${_getDisplayValue(studentData[key])}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Close", style: TextStyle(color: Colors.indigo)),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  String _getDisplayValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is double) {
      return value.toStringAsFixed(1);
    }
    return value.toString();
  }

  String _formatKey(String key, {required bool isOA}) {
    final keyMap = {
      'matric_marks': isOA ? 'O-Level Marks' : 'Matric Marks',
      'fsc_marks': isOA ? 'A-Level Marks' : 'FSC Marks',
      'o_level_marks': 'O-Level Marks',
      'a_level_marks': 'A-Level Marks',
      'student_name': 'Student Name',
      'father_name': 'Father Name',
      'email': 'Email',
      'gpa': 'GPA',
      'bachelors_cgpa': 'Bachelor\'s CGPA',
      'lums_student_aggregate': 'LUMS Student Aggregate',
      'lums_predicted_2026_aggregate': 'LUMS Predicted 2026 Aggregate',
      'lums_admission_chance': 'LUMS Admission Chance',
      'lums_admitted': 'LUMS Admitted',
    };
    if (keyMap.containsKey(key)) return keyMap[key]!;
    return key
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) => '${match[1]} ${match[2]}')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Widget _buildFeeItem(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isAmount ? Colors.green[700] : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCard(Map<String, dynamic> program, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              program['program'] ?? "Program $index",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
            _buildFeeItem("Duration / Amount:", program['duration_years']?.toString() ?? "-",
                isAmount: program['duration_years']?.toString().contains("Rs.") ?? false),
            _buildFeeItem("Fee:", program['fee']?.toString() ?? "-",
                isAmount: program['fee']?.toString().contains("Rs.") ?? false),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramSection(String title, List<dynamic>? programs) {
    if (programs == null || programs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'No $title available',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
        ),
        ...programs.asMap().entries.map((entry) {
          return _buildProgramCard(Map<String, dynamic>.from(entry.value), entry.key);
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCGPA = widget.studentData.containsKey('bachelors_cgpa');
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
          title: const Text(
        'LUMS Uni',
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
            icon: const Icon(Icons.home),
            tooltip: 'Home',
            onPressed: () {
              context.go(
                '/student_dashboard',
                extra: widget.studentData,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.school),
            tooltip: 'Scholarships',
            onPressed: () {
              context.go(
                '/lums-scholarships',
                extra: widget.studentData,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: _showUserInfo,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : feeData.isEmpty
                  ? const Center(
                      child: Text(
                        "No fee data available",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          if (feeData['bachelors_programs'] != null)
                            _buildProgramSection("Bachelor's Programs",
                                List<dynamic>.from(feeData['bachelors_programs'])),
                          if (feeData['masters_programs'] != null)
                            _buildProgramSection("Master's Programs",
                                List<dynamic>.from(feeData['masters_programs'])),
                          if (feeData['m._phil_programs'] != null)
                            _buildProgramSection("M.Phil Programs",
                                List<dynamic>.from(feeData['m._phil_programs'])),
                          if (feeData['ph._d_programs'] != null)
                            _buildProgramSection("Ph.D Programs",
                                List<dynamic>.from(feeData['ph._d_programs'])),
                          if (feeData['others_programs'] != null)
                            _buildProgramSection("Other Programs",
                                List<dynamic>.from(feeData['others_programs'])),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
    );
  }
}