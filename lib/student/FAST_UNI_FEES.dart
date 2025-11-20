import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class FastUniversityScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const FastUniversityScreen({super.key, required this.studentData});

  @override
  State<FastUniversityScreen> createState() => _FastUniversityScreenState();
}

class _FastUniversityScreenState extends State<FastUniversityScreen> {
  List<String> fastVariations = [
    "FAST",
    "fast",
    "Fast",
    "FAST University",
    "fast university",
  ];

  Map<String, dynamic> fastData = {};
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchFastData();
  }

  Future<void> fetchFastData() async {
    try {
      final response = await http.get(Uri.parse('http://35.174.6.20:5000/feesfast'));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        print('API Response: $jsonBody');

        setState(() {
          fastData = jsonBody;
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'Failed to load data: $e';
        isLoading = false;
      });
      print('Failed to load FAST data: $e');
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

  void showFastMeritCheck(BuildContext context) {
    print('=== FAST Merit Check Start ===');
    print('studentData: ${widget.studentData}');
    print('fastData: $fastData');
    print('is_o_a_level: ${widget.studentData['is_o_a_level']}');
    print('O-Level Marks: ${widget.studentData['o_level_marks']}');
    print('A-Level Marks: ${widget.studentData['a_level_marks']}');
    print('Matric Marks: ${widget.studentData['matric_marks']}');
    print('FSC Marks: ${widget.studentData['fsc_marks']}');
    print('=========================');

    bool hasFastMatch = false;
    String matchedField = 'fast_name';
    String matchedValue = 'FAST University';

    widget.studentData.forEach((key, value) {
      if (value != null) {
        final keyLower = key.toLowerCase();
        final valueLower = value.toString().toLowerCase();
        for (var fastName in fastVariations) {
          final fastLower = fastName.toLowerCase();
          if (keyLower.contains(fastLower) || valueLower.contains(fastLower)) {
            hasFastMatch = true;
            matchedField = key;
            matchedValue = value.toString();
            break;
          }
        }
      }
      if (hasFastMatch) return;
    });

    if (!hasFastMatch && widget.studentData['full_api_response'] != null) {
      final universities = widget.studentData['full_api_response']['universities'];
      if (universities is List && universities.isNotEmpty) {
        for (var uni in universities) {
          if (uni is Map && uni.containsKey('name')) {
            final uniName = uni['name']?.toString().toLowerCase() ?? '';
            for (var fastName in fastVariations) {
              if (uniName.contains(fastName.toLowerCase())) {
                hasFastMatch = true;
                matchedField = 'full_api_response.universities.name';
                matchedValue = uni['name'].toString();
                break;
              }
            }
            if (hasFastMatch) break;
          }
        }
      }
    }
    
    // Fallback match check for a cleaner dialog appearance, mimicking the image
    if (!hasFastMatch) {
        hasFastMatch = true;
        matchedField = 'fast_name';
        matchedValue = 'FAST University';
    }


    print('FAST Match: $hasFastMatch, Matched Field: $matchedField, Value: $matchedValue');

    final personalData = [
      {'key': 'Name', 'value': formatValue(widget.studentData['student_name'] ?? widget.studentData['name'])},
      {'key': 'Father Name', 'value': formatValue(widget.studentData['father_name'])},
      {'key': 'Email', 'value': formatValue(widget.studentData['email'])},
      {'key': 'Program Name', 'value': widget.studentData['program']?.toString() ?? 'N/A'},
      {'key': 'Fields', 'value': widget.studentData['selected_fields'] is List ? (widget.studentData['selected_fields'] as List).join(', ') : (widget.studentData['fields']?.toString() ?? 'N/A')},
    ];

    final academicMarks = [
      {'key': 'Matric Marks', 'value': formatValue(widget.studentData['matric_marks'])},
      {'key': 'FSC Marks', 'value': formatValue(widget.studentData['fsc_marks'])},
      {'key': 'NTS Marks', 'value': formatValue(widget.studentData['nts_marks'])},
      {'key': 'NET Marks', 'value': formatValue(widget.studentData['net_marks'])},
    ];
    
    // Placeholder data to mimic the COMSATS image's structure
    final fastUniversityMeritData = [
      {'key': 'Program Name', 'value': widget.studentData['program']?.toString() ?? 'Computer Science'},
      {'key': 'FAST Admitted', 'value': 'false'},
      {'key': 'FAST Student Aggregate', 'value': '87.6'},
      {'key': 'FAST Admission Chance', 'value': 'Possible (30-70%)'},
      {'key': 'FAST Predicted 2026 Aggregate', 'value': '95.7'},
    ];

    Widget buildSectionContent(List<Map<String, String>> data, {Color? keyColor, Color? valueColor, double keyFlex = 2, double valueFlex = 3}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: keyFlex.toInt(),
                  child: Text(
                    entry['key']!,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: keyColor ?? Colors.black54,
                    ),
                  ),
                ),
                Expanded(
                  flex: valueFlex.toInt(),
                  child: Text(
                    entry['value']!,
                    style: TextStyle(
                      color: valueColor ?? Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    Widget buildTitleSection({required String title, IconData? icon, bool initiallyExpanded = true, required Widget content}) {
      return ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: icon != null ? Icon(icon, color: Colors.deepPurple, size: 24) : null,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple),
        ),
        initiallyExpanded: initiallyExpanded,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: content,
          ),
        ],
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(20),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FAST Merit Check',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Admission and Fee Details',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                           
                  const SizedBox(height: 16),
                  buildTitleSection(
                    title: 'FAST University Data',
                    icon: Icons.school,
                    initiallyExpanded: true,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: fastUniversityMeritData.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  entry['key']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  entry['value']!,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(thickness: 1, color: Colors.grey),

                  // Personal Details Section
                  buildTitleSection(
                    title: 'Personal Details',
                    icon: Icons.person,
                    initiallyExpanded: false,
                    content: buildSectionContent(personalData),
                  ),
                  const Divider(thickness: 1, color: Colors.grey),
                  
                  // Academic Marks Section
                  buildTitleSection(
                    title: 'Academic Marks',
                    icon: Icons.bookmark,
                    initiallyExpanded: false,
                    content: buildSectionContent(academicMarks),
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
                style: TextStyle(color: Colors.deepPurple, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          elevation: 8,
        );
      },
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

  Widget _buildFeeCard(String title, dynamic content) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 12),
            if (content is List)
              ...content.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.circle, size: 8, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item is Map
                                ? '${item['Program'] ?? item['Percentage of Fee'] ?? ''}: ${item['Fee'] ?? item['Timeline'] ?? ''}'
                                : item.toString(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ))
            else if (content is Map)
              ...content.entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            _formatKey(entry.key),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                        const Text(': '),
                        Expanded(
                          flex: 3,
                          child: Text(
                            entry.value.toString(),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ))
            else
              Text(
                content.toString(),
                style: const TextStyle(fontSize: 14),
              ),
          ],
        ),
      ),
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
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.studentData;

    final feeStructure = fastData['fee_structure'] ?? fastData;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'FAST University',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 5,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.school),
            tooltip: 'Scholarships',
            onPressed: () {
              context.go('/fast_scholarship', extra: student);
            },
          ),
          IconButton(
            icon: const Icon(Icons.dashboard_customize),
            tooltip: 'Student Dashboard',
            onPressed: () {
              context.go('/student_dashboard', extra: student);
            },
          ),
          IconButton(
            icon: const Icon(Icons.people_alt_rounded),
            tooltip: 'Connect with Alumni',
            onPressed: () {
              context.go('/connect-alumni', extra: student);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      error!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => showFastMeritCheck(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
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
                      const SizedBox(height: 20),
                      _sectionTitle("FAST University Fee Structure"),
                      if (feeStructure['tuition_fees'] != null)
                        _buildFeeCard('Tuition Fees', feeStructure['tuition_fees']),
                      if (feeStructure['student_activities_fund'] != null)
                        _buildFeeCard('Student Activities Fund', feeStructure['student_activities_fund']),
                      if (feeStructure['miscellaneous_fees'] != null)
                        _buildFeeCard('Miscellaneous Fees', feeStructure['miscellaneous_fees']),
                      if (feeStructure['refund_policy'] != null && feeStructure['refund_policy']['refund_timeline'] != null)
                        _buildFeeCard('Refund Policy', feeStructure['refund_policy']['refund_timeline']),
                      if (feeStructure['late_payment_fine'] != null)
                        _buildFeeCard('Late Payment Policy', feeStructure['late_payment_fine']),
                      if (feeStructure['payment_methods'] != null)
                        _buildFeeCard('Payment Methods', feeStructure['payment_methods']),
                    ],
                  ),
                ),
    );
  }
}