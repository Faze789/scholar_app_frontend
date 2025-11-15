import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const StudentDashboardScreen({super.key, required this.studentData});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  late Map<String, dynamic> studentData;
  final Map<String, TextEditingController> _controllers = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    studentData = Map<String, dynamic>.from(widget.studentData);
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers.clear();
    final fieldsToInit = [
      'program_display',
      'nts_marks',
      'net_marks',
      'ecat_marks',
      'ned_marks',
      if (studentData['is_o_a_level'] ?? false) ...['o_level_marks', 'a_level_marks']
      else ...['matric_marks', 'fsc_marks'],
    ];

    for (var key in fieldsToInit) {
      _controllers[key] = TextEditingController(text: _getFieldValue(studentData, key));
    }
    _controllers['program_display']!.text = _getProgramDisplay();
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  String _getProgramDisplay() {
    String program = studentData['program']?.toString() ?? '';
    if (studentData['selected_fields']?.isNotEmpty ?? false) {
      program += ' ${studentData['selected_fields'][0]}';
    }
    return program.trim();
  }

  Future<void> _fetchStudentData() async {
    try {
      final querySnapshot = await _firestore
          .collection('students_data')
          .where('email', isEqualTo: studentData['email'])
          .where('password', isEqualTo: studentData['password'])
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _showErrorDialog("Student document not found for email: ${studentData['email']}");
        return;
      }

      final fetchedData = querySnapshot.docs.first.data();
      setState(() {
        studentData = Map<String, dynamic>.from(fetchedData);
        studentData['program'] = fetchedData['program'] ?? '';
        studentData['selected_fields'] = fetchedData['selected_fields'] ?? [];
        studentData['is_o_a_level'] = fetchedData['is_o_a_level'] ?? false;

        if (studentData['selected_fields'] is String) {
          studentData['selected_fields'] = [studentData['selected_fields']];
        }

        _initializeControllers();
      });
    } catch (e) {
      _showErrorDialog("Failed to fetch data from Firebase: $e");
    }
  }

  Future<void> _callPredictionAPI() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Processing..."),
            ],
          ),
        ),
      );

      
      if (!_validateMarks()) {
        Navigator.of(context).pop();
        _showErrorDialog("Please enter valid marks for all required fields.");
        return;
      }

      final url = Uri.parse("http://192.168.100.149:5000/predict");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "matric_marks": studentData['is_o_a_level']
              ? (double.tryParse(_controllers['o_level_marks']?.text ?? '0') ?? 0) / 900 * 1100
              : double.tryParse(_controllers['matric_marks']?.text ?? '0') ?? 0,
          "fsc_marks": studentData['is_o_a_level']
              ? (double.tryParse(_controllers['a_level_marks']?.text ?? '0') ?? 0) / 1200 * 1100
              : double.tryParse(_controllers['fsc_marks']?.text ?? '0') ?? 0,
          "nts_marks": double.tryParse(_controllers['nts_marks']?.text ?? '0') ?? 0,
          "net_marks": double.tryParse(_controllers['net_marks']?.text ?? '0') ?? 0,
          "ecat_marks": double.tryParse(_controllers['ecat_marks']?.text ?? '0') ?? 0,
          "ned_test_marks": double.tryParse(_controllers['ned_marks']?.text ?? '0') ?? 0,
          "program": _getProgramDisplay(),
          "is_o_a_level": studentData['is_o_a_level'] ?? false,
        }),
      );

      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        await _updateFirebaseData(responseData);
        _showAPIResponse(responseData);
      } else {
        _showErrorDialog("API Error: ${response.statusCode}\n${response.body}");
      }
    } catch (e) {
      Navigator.of(context).pop();
      _showErrorDialog("Network Error: $e");
    }
  }

  bool _validateMarks() {
    if (studentData['is_o_a_level'] ?? false) {
      final oLevel = double.tryParse(_controllers['o_level_marks']?.text ?? '');
      final aLevel = double.tryParse(_controllers['a_level_marks']?.text ?? '');
      if (oLevel == null || oLevel < 0 || oLevel > 900) return false;
      if (aLevel == null || aLevel < 0 || aLevel > 1200) return false;
    } else {
      final matric = double.tryParse(_controllers['matric_marks']?.text ?? '');
      final fsc = double.tryParse(_controllers['fsc_marks']?.text ?? '');
      if (matric == null || matric < 0 || matric > 1100) return false;
      if (fsc == null || fsc < 0 || fsc > 1100) return false;
    }

    for (var key in ['nts_marks', 'net_marks', 'ecat_marks', 'ned_marks']) {
      final value = double.tryParse(_controllers[key]?.text ?? '');
      if (value != null) {
        if (key == 'nts_marks' && (value < 0 || value > 100)) return false;
        if (key == 'net_marks' && (value < 0 || value > 200)) return false;
        if (key == 'ecat_marks' && (value < 0 || value > 400)) return false;
        if (key == 'ned_marks' && (value < 0 || value > 100)) return false;
      }
    }
    return true;
  }

  Future<void> _updateFirebaseData(Map<String, dynamic> apiResponse) async {
    try {
      final querySnapshot = await _firestore
          .collection('students_data')
          .where('email', isEqualTo: studentData['email'])
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("Student document not found for email: ${studentData['email']}");
      }

      final docId = querySnapshot.docs.first.id;
      final updateData = <String, dynamic>{
        'matric_marks': studentData['is_o_a_level'] ? null : double.tryParse(_controllers['matric_marks']?.text ?? ''),
        'fsc_marks': studentData['is_o_a_level'] ? null : double.tryParse(_controllers['fsc_marks']?.text ?? ''),
        'o_level_marks': studentData['is_o_a_level'] ? double.tryParse(_controllers['o_level_marks']?.text ?? '') : null,
        'a_level_marks': studentData['is_o_a_level'] ? double.tryParse(_controllers['a_level_marks']?.text ?? '') : null,
        'nts_marks': double.tryParse(_controllers['nts_marks']?.text ?? ''),
        'net_marks': double.tryParse(_controllers['net_marks']?.text ?? ''),
        'ecat_marks': double.tryParse(_controllers['ecat_marks']?.text ?? ''),
        'ned_marks': double.tryParse(_controllers['ned_marks']?.text ?? ''),
        'program': studentData['program'],
        'selected_fields': studentData['selected_fields'] ?? [],
        'is_o_a_level': studentData['is_o_a_level'] ?? false,
        'full_api_response': apiResponse,
        'last_updated': FieldValue.serverTimestamp(),
      };

      if (apiResponse['universities'] is List) {
        for (var university in apiResponse['universities'] as List) {
          if (university is Map<String, dynamic>) {
            final universityId = university['id']?.toString().toLowerCase();
            if (universityId != null) {
              _updateUniversityData(updateData, university, universityId);
            }
          }
        }
      }

      await _firestore.collection('students_data').doc(docId).update(updateData);
      await _fetchStudentData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data updated successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update data: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      _showErrorDialog("Failed to update data in Firebase: $e");
    }
  }

  void _updateUniversityData(Map<String, dynamic> updateData, Map<String, dynamic> universityData, String universityPrefix) {
    updateData.addAll({
      '${universityPrefix}_student_aggregate': universityData['user_aggregate'],
      '${universityPrefix}_predicted_2026_aggregate': universityData['predicted_2026_cutoff'],
      '${universityPrefix}_admission_chance': universityData['admission_chance'],
      '${universityPrefix}_admitted': universityData['admitted'],
      '${universityPrefix}_name': universityData['name'],
      '${universityPrefix}_last_year_aggregate': universityData['last_actual_cutoff'],
      if (universityData['criteria']?['test_used'] != null) '${universityPrefix}_test_used': universityData['criteria']['test_used'],
      if (universityData['criteria']?['weights'] != null) '${universityPrefix}_criteria_weights': universityData['criteria']['weights'],
      if (universityData['criteria']?['totals'] != null) '${universityPrefix}_criteria_totals': universityData['criteria']['totals'],
      if (universityData['last_actual_year'] != null) '${universityPrefix}_last_actual_year': universityData['last_actual_year'],
    });
  }

  void _showAPIResponse(Map<String, dynamic> responseData) {
    final isOA = studentData['is_o_a_level'] ?? false;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Prediction Results",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
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
                    const Text("Input Data Sent:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text("Program: ${_controllers['program_display']?.text ?? 'N/A'}", style: const TextStyle(fontSize: 14)),
                    if (isOA) ...[
                      Text("O-Level Marks: ${_controllers['o_level_marks']?.text ?? 'N/A'}", style: const TextStyle(fontSize: 14)),
                      Text("A-Level Marks: ${_controllers['a_level_marks']?.text ?? 'N/A'}", style: const TextStyle(fontSize: 14)),
                    ] else ...[
                      Text("Matric Marks: ${_controllers['matric_marks']?.text ?? 'N/A'}", style: const TextStyle(fontSize: 14)),
                      Text("FSC Marks: ${_controllers['fsc_marks']?.text ?? 'N/A'}", style: const TextStyle(fontSize: 14)),
                    ],
                    Text("NTS Marks: ${_controllers['nts_marks']?.text ?? 'N/A'}", style: const TextStyle(fontSize: 14)),
                    Text("NET Marks: ${_controllers['net_marks']?.text ?? 'N/A'}", style: const TextStyle(fontSize: 14)),
                    Text("ECAT Marks: ${_controllers['ecat_marks']?.text ?? 'N/A'}", style: const TextStyle(fontSize: 14)),
                    Text("NED Marks: ${_controllers['ned_marks']?.text ?? 'N/A'}", style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.deepPurple.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "University Predictions:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepPurple),
                    ),
                    const SizedBox(height: 8),
                    if (responseData['universities'] is List)
                      ...(responseData['universities'] as List).map((university) {
                        if (university is Map<String, dynamic>) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${university['name'] ?? 'Unknown University'}:",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text("  Aggregate: ${university['user_aggregate']?.toStringAsFixed(1) ?? 'N/A'}", style: const TextStyle(fontSize: 12)),
                                Text("  Predicted 2026 Cutoff: ${university['predicted_2026_cutoff']?.toStringAsFixed(1) ?? 'N/A'}", style: const TextStyle(fontSize: 12)),
                                Text("  Admission Chance: ${university['admission_chance'] ?? 'N/A'}", style: const TextStyle(fontSize: 12)),
                                Text("  Admitted: ${university['admitted']?.toString() ?? 'N/A'}", style: const TextStyle(fontSize: 12)),
                                const SizedBox(height: 4),
                              ],
                            ),
                          );
                        }
                        return Container();
                      }),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Error", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showStudentInfo(BuildContext context) async {
  await _fetchStudentData();

  final isOA = studentData['is_o_a_level'] ?? false;

  
  final orderedKeys = [
    'student_name',
    'program_display',
    'father_name',
    'email',
    if (isOA) ...['o_level_marks', 'a_level_marks'] else ...['matric_marks', 'fsc_marks'],
    'nts_marks',
    'net_marks',
    'ecat_marks',
    'ned_marks',
    'comsats_student_aggregate',
    'comsats_predicted_2026_aggregate',
    'comsats_admission_chance',
    'nust_student_aggregate',
    'nust_predicted_2026_aggregate',
    'nust_admission_chance',
    'iqra_student_aggregate',
    'iqra_predicted_2026_aggregate',
    'iqra_admission_chance',
    'fast_student_aggregate',
    'fast_predicted_2026_aggregate',
    'fast_admission_chance',
    'uet_student_aggregate',
    'uet_predicted_2026_aggregate',
    'uet_admission_chance',
    'bahria_student_aggregate',
    'bahria_predicted_2026_aggregate',
    'bahria_admission_chance',
    'ned_student_aggregate',
    'ned_predicted_2026_aggregate',
    'ned_admission_chance',
    'iiui_student_aggregate',
    'iiui_predicted_2026_aggregate',
    'iiui_admission_chance',
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
    isScrollControlled: true,
    builder: (_) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewPadding.bottom + 20,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text("Your Information",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

          
            for (var key in orderedKeys)
              if (studentData[key] != null &&
                  studentData[key].toString().isNotEmpty)
                _isEditableField(key)
                    ? _editableTile(
                        _formatKey(key, isOA: isOA),
                        _controllers[key]!,
                        (newValue) {
                          studentData[key] = newValue;
                        },
                        isOA: isOA,
                      )
                    : _infoTile(_formatKey(key, isOA: isOA),
                        _getDisplayValue(studentData[key])),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (!_validateMarks()) {
                  _showErrorDialog(
                      "Please enter valid marks for all required fields.");
                  return;
                }
                Navigator.pop(context);
                await _callPredictionAPI();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Save Changes & Get Prediction"),
            ),
          ],
        ),
      );
    },
  );
}


  String _getFieldValue(Map<String, dynamic> data, String key) {
    final value = data[key];
    return value?.toString() ?? '';
  }

  String _getDisplayValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is double) return value.toStringAsFixed(1);
    return value.toString();
  }

  bool _isEditableField(String key) {
    return {
      'program_display',
      'matric_marks',
      'fsc_marks',
      'o_level_marks',
      'a_level_marks',
      'nts_marks',
      'net_marks',
      'ecat_marks',
      'ned_marks',
    }.contains(key);
  }

  String _formatKey(String key, {required bool isOA}) {
    final keyMap = {
      'program_display': 'Program',
      'ecat_marks': 'ECAT Marks',
      'ned_marks': 'NED Entry Test Marks',
      'nts_marks': 'NTS Marks',
      'net_marks': 'NET Marks',
      'matric_marks': isOA ? 'O-Level Marks' : 'Matric Marks',
      'fsc_marks': isOA ? 'A-Level Marks' : 'FSC Marks',
      'o_level_marks': 'O-Level Marks',
      'a_level_marks': 'A-Level Marks',
    };
    if (keyMap.containsKey(key)) return keyMap[key]!;
    return key
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) => '${match[1]} ${match[2]}')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        tileColor: Colors.grey.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  Widget _editableTile(String title, TextEditingController controller, ValueChanged<String> onChanged, {required bool isOA}) {
    double? maxMarks;
    if (title.contains('O-Level Marks')) {
      maxMarks = 900;
    } else if (title.contains('A-Level Marks')) maxMarks = 1200; // As per provided data (a_level_marks: 950)
    else if (title.contains('Matric Marks') || title.contains('FSC Marks')) maxMarks = 1100;
    else if (title.contains('NTS Marks') || title.contains('NED Entry Test Marks')) maxMarks = 100;
    else if (title.contains('NET Marks')) maxMarks = 200;
    else if (title.contains('ECAT Marks')) maxMarks = 400;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade100,
          hintText: maxMarks != null ? '0 - $maxMarks' : null,
          errorText: maxMarks != null && controller.text.isNotEmpty
              ? (double.tryParse(controller.text) == null ||
                      double.parse(controller.text) < 0 ||
                      double.parse(controller.text) > maxMarks)
                  ? 'Enter a valid number between 0 and $maxMarks'
                  : null
              : null,
        ),
        keyboardType: maxMarks != null ? TextInputType.number : TextInputType.text,
        onChanged: onChanged,
      ),
    );
  }

  Widget _dashboardItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 4)),
          ],
        ),
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.deepPurple),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.deepPurple),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _prepareNavigationData() {
    final dataToPass = Map<String, dynamic>.from(studentData);
    dataToPass['program'] = studentData['program'] ?? '';
    dataToPass['selected_fields'] = studentData['selected_fields'] ?? [];
    if (dataToPass['selected_fields'] is String) {
      dataToPass['selected_fields'] = [dataToPass['selected_fields']];
    }
    dataToPass['program_display'] = _getProgramDisplay();
    return dataToPass;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.purple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundImage: studentData['profile_image_url'] != null &&
                        studentData['profile_image_url'] is String
                    ? NetworkImage(studentData['profile_image_url'])
                    : const AssetImage('assets/default_profile.png') as ImageProvider,
              ),
              const SizedBox(height: 10),
              Text(
                "Welcome, ${studentData['student_name'] ?? 'Student'}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    childAspectRatio: 1.1,
                    children: [
                      _dashboardItem(
                        icon: Icons.school,
                        label: "University Info",
                        onTap: () async {
                          await _fetchStudentData();
                          context.go('/student-choose-uni', extra: _prepareNavigationData());
                        },
                      ),
                      _dashboardItem(
                        icon: Icons.event,
                        label: "Events",
                        onTap: () async {
                          await _fetchStudentData();
                          context.go('/uni-events', extra: _prepareNavigationData());
                        },
                      ),
                      _dashboardItem(
                        icon: Icons.card_giftcard,
                        label: "Scholarships",
                        onTap: () async {
                          await _fetchStudentData();
                          context.go('/all_scholarships', extra: _prepareNavigationData());
                        },
                      ),
                      _dashboardItem(
                        icon: Icons.person,
                        label: "View Your Info",
                        onTap: () => _showStudentInfo(context),
                      ),
                      _dashboardItem(
                        icon: Icons.chat,
                        label: "All chats",
                        onTap: () async {
                          await _fetchStudentData();
                          context.go('/all_chats', extra: _prepareNavigationData());
                        },

                      ),
                      _dashboardItem(
                      icon: Icons.school_sharp,
                      label: "Abroad Scholarships",
                      onTap: () async {
                        await _fetchStudentData();
                        context.go('/abroad_scholarships', extra: _prepareNavigationData());
                      },
                    ),
                    _dashboardItem(
                      icon: Icons.feedback,
                      label: "Feedback",
                      onTap: ()  {
                       context.go('/feedback', extra: _prepareNavigationData());
                      },
                    ),

                    _dashboardItem(
                      icon: Icons.feedback,
                      label: "visual Chart",
                      onTap: ()  {
                       context.go('/visual_uni', extra: _prepareNavigationData());
                      },
                    ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}