import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class NustUniScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const NustUniScreen({super.key, required this.studentData});

  @override
  State<NustUniScreen> createState() => _NustUniScreenState();
}

class _NustUniScreenState extends State<NustUniScreen> {
  List<String> nust_uni = [
    "nust",
    "NUST",
    "Nust",
    "nust university",
    "national university of sciences and technology",
    "national university of sciences and technology (nust)",
  ];
  List<dynamic> undergradFees = [];
  List<dynamic> msPrograms = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchFeeData();
  }

  Future<void> fetchFeeData() async {
    try {
      final response = await http.get(Uri.parse('http://35.174.6.20:5000/feesnust'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map && data.containsKey('fee_structure') && data['fee_structure'] is List) {
          final feeStructure = data['fee_structure'] as List<dynamic>;

          final undergrad = <Map<String, dynamic>>[];
          final ms = <Map<String, dynamic>>[];
          for (var item in feeStructure) {
            if (item.containsKey('Architecture, Social Science, Business Studies') ||
                item.containsKey('Engineering/Computing/Natural Sciences/Applied Sciences')) {
              undergrad.add({
                'architecture_social_business': item['Architecture, Social Science, Business Studies'] ?? 'N/A',
                'engineering_computing_sciences': item['Engineering/Computing/Natural Sciences/Applied Sciences'] ?? 'N/A',
              });
            } else if (item.containsKey('Course/Program Name')) {
              ms.add({
                'program': item['Course/Program Name'] ?? 'Unknown Program',
                'duration': item['Duration'] ?? 'N/A',
                'fee': item['Fee Structure'] ?? 'No fee information available',
              });
            }
          }
          setState(() {
            undergradFees = undergrad;
            msPrograms = ms;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Invalid data format: fee_structure missing or not a list';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: ${e.toString()}';
        isLoading = false;
      });
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

  void _showNustMeritCheck(BuildContext context) async {
    try {
      final hasCGPA = widget.studentData.containsKey('bachelors_cgpa') || widget.studentData.containsKey('cgpa');
      final isOALevel = widget.studentData['is_o_a_level'] == true;

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
        ] else ...[
          if (widget.studentData.containsKey('matric_marks'))
            {'key': 'Matric Marks', 'value': formatValue(widget.studentData['matric_marks'])},
          if (widget.studentData.containsKey('fsc_marks'))
            {'key': 'FSC Marks', 'value': formatValue(widget.studentData['fsc_marks'])},
        ],
      ];

      final hasValidAcademicMarks = academicMarks.any((entry) => entry['value'] != 'N/A');

      final List<Map<String, String>> nustData = hasCGPA
          ? <Map<String, String>>[]
          : [
              {'key': 'NUST Name', 'value': formatValue(widget.studentData['nust_name'])},
              {'key': 'NUST Admitted', 'value': formatValue(widget.studentData['nust_admitted'])},
              {'key': 'NUST Last Year Aggregate', 'value': formatValue(widget.studentData['nust_last_year_aggregate'])},
              {'key': 'NUST Student Aggregate', 'value': formatValue(widget.studentData['nust_student_aggregate'])},
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
                  'NUST Merit Check',
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
                          child: buildSectionContent(personalDetails),
                        ),
                      ],
                    ),
                    if (hasValidAcademicMarks) ...[
                      const Divider(height: 30, thickness: 1, color: Colors.deepPurple),
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
                    ],
                    if (!hasCGPA) ...[
                      const Divider(height: 30, thickness: 1, color: Colors.deepPurple),
                      ExpansionTile(
                        leading: const Icon(Icons.school, color: Colors.deepPurple),
                        title: const Text(
                          'NUST Predictions',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple),
                        ),
                        initiallyExpanded: true,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: buildSectionContent(nustData),
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
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to show merit data: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget buildHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple.shade700),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple.shade700),
          ),
        ],
      ),
    );
  }

  Widget buildUndergradFees(List<dynamic> fees) {
    if (fees.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'No undergraduate fee data available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader('Undergraduate Fees', Icons.school),
        ...fees.map((item) {
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
                    'Architecture, Social Science, Business Studies',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(item['architecture_social_business'] ?? 'N/A'),
                  const SizedBox(height: 8),
                  Text(
                    'Engineering, Computing, Natural & Applied Sciences',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(item['engineering_computing_sciences'] ?? 'N/A'),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget buildMSPrograms(List<dynamic> programs) {
    if (programs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'No MS programs available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildHeader('MS Programs', Icons.menu_book),
        ...programs.map((item) {
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                item['program'] ?? 'No Program Name',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('Duration: ${item['duration'] ?? 'N/A'} years'),
                  const SizedBox(height: 4),
                  Text('Fee: ${item['fee'] ?? 'N/A'} PKR'),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NUST uni',
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
            icon: const Icon(Icons.school),
            tooltip: 'Scholarship',
            onPressed: () {
              context.push(
                '/nust-scholarships',
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
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showNustMeritCheck(context),
                  icon: const Icon(Icons.assessment, color: Colors.white),
                  label: const Text(
                    'Merit Check',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(child: Text('Error: $errorMessage'))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildUndergradFees(undergradFees),
                            const SizedBox(height: 24),
                            buildMSPrograms(msPrograms),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
