import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class IIUIUni extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const IIUIUni({super.key, required this.studentData});

  @override
  State<IIUIUni> createState() => _IIUIUniState();
}

class _IIUIUniState extends State<IIUIUni> {
  List<String> iiui = ["iiui", "Iiui", "Internation islamic university islamabad", "Internation islamic university islamabad (IIUI)"];
  late Future<List<dynamic>> feeDataFuture;

  @override
  void initState() {
    super.initState();
    feeDataFuture = fetchFeeStructure();
  }

  Future<List<dynamic>> fetchFeeStructure() async {
    final url = Uri.parse('http://35.174.6.20:5000/feesiiui');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      if (jsonBody['status'] == 'success' && jsonBody['fee_structure'] != null) {
        return jsonBody['fee_structure'] as List<dynamic>;
      } else {
        throw Exception('Invalid data format');
      }
    } else {
      throw Exception('Failed to load fee structure');
    }
  }

  void _showStudentInfoDialog() {
    final studentData = widget.studentData;
    final isOA = studentData['is_o_a_level'] ?? false;
    
    List<String> orderedKeys = [
      'student_name',
      'father_name',
      'email',
      if (isOA) ...['o_level_marks', 'a_level_marks'] else ...['matric_marks', 'fsc_marks'],
      if (studentData.containsKey('bachelors_cgpa')) 'bachelors_cgpa',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Student Information - IIUI",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
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
                      ...orderedKeys.where((key) => key.contains('matric_marks') || key.contains('fsc_marks') || key.contains('o_level_marks') || key.contains('a_level_marks') || key.contains('bachelors_cgpa')).map((key) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            "${_formatKey(key, isOA: isOA)}: ${_getDisplayValue(studentData[key])}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(foregroundColor: Colors.indigo),
              child: const Text("Close"),
            ),
          ],
        );
      },
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
      'bachelors_cgpa': 'Bachelors CGPA',
    };
    if (keyMap.containsKey(key)) return keyMap[key]!;
    return key
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) => '${match[1]} ${match[2]}')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'IIUI Uni',
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
                '/iiui-scholarships',
                extra: widget.studentData,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _showStudentInfoDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Student Info'),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<List<dynamic>>(
                future: feeDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final fees = snapshot.data!;
                  if (fees.isEmpty) {
                    return const Center(child: Text('No fee data found'));
                  }
                  return ListView.builder(
                    itemCount: fees.length,
                    itemBuilder: (context, index) {
                      final feeItem = fees[index] as Map<String, dynamic>;
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(feeItem['program'] ?? 'N/A'),
                          subtitle: Text('Duration: ${feeItem['duration'] ?? 'N/A'}'),
                          trailing: Text(
                            feeItem['total_fee'] ?? 'N/A',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}