import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudentChooseUni extends StatelessWidget {
  final Map<String, dynamic> studentData;

  const StudentChooseUni({super.key, required this.studentData});

  
  String getProgramDisplay() {
    String program = studentData['program']?.toString() ?? '';
    List<String> selectedFields = [];
    
    if (studentData['selected_fields'] != null) {
      if (studentData['selected_fields'] is List) {
        selectedFields = List<String>.from(studentData['selected_fields']);
      } else if (studentData['selected_fields'] is String) {
        selectedFields = [studentData['selected_fields'].toString()];
      }
    }
    
    if (program.isNotEmpty && selectedFields.isNotEmpty) {
      return '$program ${selectedFields[0]}';
    } else if (program.isNotEmpty) {
      return program;
    }
    
    return studentData['program_display']?.toString() ?? 'N/A';
  }

  
  Widget _buildDialogContent(BuildContext context) {
  
    String formatValue(dynamic value) {
      if (value is double) {
        return value.toStringAsFixed(1);
      }
      return value?.toString() ?? 'N/A';
    }

   
    final List<Map<String, String>> personalDetails = [
      {'key': 'Student Name', 'value': formatValue(studentData['student_name'])},
      {'key': 'Father Name', 'value': formatValue(studentData['father_name'])},
      {'key': 'Email', 'value': formatValue(studentData['email'])},
      {'key': 'Program', 'value': getProgramDisplay()},
      {'key': 'Program Code', 'value': formatValue(studentData['program'])},
      {
        'key': 'Selected Field',
        'value': (studentData['selected_fields'] is List &&
                (studentData['selected_fields'] as List).isNotEmpty)
            ? (studentData['selected_fields'] as List)[0].toString()
            : 'N/A'
      },
    ];

    final List<Map<String, String>> academicMarks = [
      {'key': 'Matric Marks', 'value': formatValue(studentData['matric_marks'])},
      {'key': 'FSC Marks', 'value': formatValue(studentData['fsc_marks'])},
      {'key': 'NTS Marks', 'value': formatValue(studentData['nts_marks'])},
      {'key': 'NET Marks', 'value': formatValue(studentData['net_marks'])},
      {
        'key': 'API Matric Marks',
        'value': formatValue(
            studentData['full_api_response']?['universities']?[0]?['criteria']
                ?['totals']?['matric'])
      },
      {
        'key': 'API NTS/NET Marks',
        'value': formatValue(
            studentData['full_api_response']?['universities']?[0]?['criteria']
                ?['totals']?['test'])
      },
    ];

    final List<Map<String, String>> universityData = [
      {
        'key': 'COMSATS University Name',
        'value': formatValue(studentData['comsats_university_name'])
      },
      {
        'key': 'COMSATS Admitted',
        'value': formatValue(studentData['comsats_admitted'])
      },
      {
        'key': 'COMSATS Last Actual Cutoff',
        'value': formatValue(studentData['comsats_last_actual_cutoff'])
      },
      {
        'key': 'COMSATS Student Aggregate',
        'value': formatValue(studentData['comsats_student_aggregate'])
      },
      {
        'key': 'COMSATS Admission Chance',
        'value': formatValue(studentData['comsats_admission_chance'])
      },
      {
        'key': 'COMSATS Aggregate',
        'value': formatValue(studentData['aggregate_comsats'])
      },
      {
        'key': 'NUST Admitted',
        'value': formatValue(studentData['nust_admitted'])
      },
      {
        'key': 'NUST Student Aggregate',
        'value': formatValue(studentData['nust_student_aggregate'])
      },
      {
        'key': 'NUST Admission Chance',
        'value': formatValue(studentData['nust_admission_chance'])
      },
      {
        'key': 'Iqra University Name',
        'value': formatValue(studentData['iqra_university_name'])
      },
      {
        'key': 'Iqra Last Actual Cutoff',
        'value': formatValue(studentData['iqra_last_actual_cutoff'])
      },
      {
        'key': 'Iqra Student Aggregate',
        'value': formatValue(studentData['iqra_student_aggregate'])
      },
    ];

   
    Widget buildSectionContent(List<Map<String, String>> data) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.map((entry) {
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
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    entry['value']!,
                    style: TextStyle(
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

    return Container(
      width: double.maxFinite,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
           
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/placeholder_student.jpg',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.indigo,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
           
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Program Information',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.indigo.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Full Program: ${getProgramDisplay()}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                  Text(
                    'Program Code: ${studentData['program'] ?? 'N/A'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Specialization: ${(studentData['selected_fields'] is List &&
                            (studentData['selected_fields'] as List).isNotEmpty)
                        ? (studentData['selected_fields'] as List)[0].toString()
                        : 'N/A'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          
            ExpansionTile(
              title: Text(
                'Personal Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.indigo.shade800,
                ),
              ),
              initiallyExpanded: true,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: buildSectionContent(personalDetails),
                ),
              ],
            ),
            
            ExpansionTile(
              title: Text(
                'Academic Marks',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.indigo.shade800,
                ),
              ),
              initiallyExpanded: true,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: buildSectionContent(academicMarks),
                ),
              ],
            ),
         
            ExpansionTile(
              title: Text(
                'University Data',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.indigo.shade800,
                ),
              ),
              initiallyExpanded: true,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: buildSectionContent(universityData),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _uniButton(String name, String imagePath, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      splashColor: Colors.indigo.withOpacity(0.3),
      highlightColor: Colors.indigo.withOpacity(0.1),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.indigo.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
          ],
          gradient: LinearGradient(
            colors: [Colors.indigo.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.indigo.shade900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> universities = [
       {"name": "COMSATS", "image": "assets/comsats.jpg"},
       {"name": "fast", "image": "assets/fast.png"},
         {"name": "NED", "image": "assets/ned.png"},
          {"name": "UET Lahore", "image": "assets/uet.jpg"},
          {"name": "AIR UNIVERSITY", "image": "assets/air.png"},
          {"name": "NUST", "image": "assets/nust.jpg"},
          {"name": "uni_of_education", "image": "assets/ue.png"},
      {"name": "IIUI", "image": "assets/iiui.jpg"},
      {"name": "LUMS", "image": "assets/lums.png"},
  
    
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Choose Your University",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              print('=== RECEIVING CLASS DATA CHECK ===');
              print('Received studentData keys: ${studentData.keys.toList()}');
              print('Program: "${studentData['program']}" (${studentData['program']?.runtimeType})');
              print('Selected fields: ${studentData['selected_fields']} (${studentData['selected_fields']?.runtimeType})');
              print('Program display: "${studentData['program_display']}"');
              print('Computed program display: "${getProgramDisplay()}"');
              print('Student name: "${studentData['student_name']}"');
              print('Email: "${studentData['email']}"');
              print('Full received data: $studentData');
              print('================================');
              
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      'Student Data - ${getProgramDisplay()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    content: _buildDialogContent(context),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Close',
                          style: TextStyle(color: Colors.indigo),
                        ),
                      ),
                    ],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    backgroundColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                  );
                },
              );
            },
          ),
        ],
        backgroundColor: Colors.indigo.shade800,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade700, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 1.0],
          ),
        ),
        child: Column(
          children: [
            
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Your Program',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    getProgramDisplay(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo.shade900,
                    ),
                  ),
                  Text(
                    'Choose universities that offer this program',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
        
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: universities.map((uni) {
                    return _uniButton(
                      uni['name']!,
                      uni['image']!,
                      () {
                        final name = uni['name']!;
                        if (name == 'IIUI') {
                          context.go('/iiui-uniDashboard', extra: studentData);
                        } else if (name == 'LUMS') {
                          context.go('/lums-uniDashboard', extra: studentData);
                        } else if (name == 'COMSATS') {
                          context.go('/comsats-uni-dashboard', extra: studentData);
                        } else if (name == 'uni_of_education') {
                          context.go('/uni_of_education_Dashboard', extra: studentData);
                        } else if (name == 'fast') {
                          context.go('/fast-uni-Dashboard', extra: studentData);
                        } else if (name == 'NED') {
                          context.go('/nedfeesDashboard', extra: studentData);
                        } else if (name == 'AIR UNIVERSITY') {
                          context.go('/air-uniDashboard', extra: studentData);
                        } else if (name == 'NUST') {
                          context.go('/nust-uniDashboard', extra: studentData);
                        } else if (name == 'UET Lahore') {
                          context.go('/uetDashboard', extra: studentData);
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}