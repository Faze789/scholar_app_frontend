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
  List<String> fastVariations = ["FAST", "fast", "Fast", "FAST University", "fast university"];
  Map<String, dynamic> fastFeeData = {};
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchFastFeeData();
  }

  Future<void> fetchFastFeeData() async {
    try {
      final response = await http.get(Uri.parse('http://35.174.6.20:5000/feesfast'));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        setState(() {
          fastFeeData = jsonBody is Map<String, dynamic> ? jsonBody : {};
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
    }
  }

  String formatValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is double) return value.toStringAsFixed(1);
    return value.toString();
  }

  String getProgramDisplay() {
    final program = widget.studentData['program']?.toString() ?? 'N/A';
    final fields = widget.studentData['selected_fields'] ?? widget.studentData['fields'];
    if (fields is List && fields.isNotEmpty) {
      return '$program (${fields.join(", ")})';
    }
    return program;
  }

  String getFastBestModel() {
    final data = widget.studentData;
    if (data['fast_best_model'] != null) {
      return data['fast_best_model'].toString().toLowerCase();
    }
    return 'linear';
  }

  String getFastMaeScore() {
    final data = widget.studentData;
    final bestModel = getFastBestModel();
    if (bestModel == 'polynomial' && data['fast_poly_mae'] != null) {
      return formatValue(data['fast_poly_mae']);
    } else if (data['fast_linear_mae'] != null) {
      return formatValue(data['fast_linear_mae']);
    }
    return 'N/A';
  }

  void showFastMeritCheck(BuildContext context) {
    final student = widget.studentData;
    final isGraduate = student.containsKey('bachelors_cgpa') && student['bachelors_cgpa'] != null;
    final isOA = student['is_o_a_level'] ?? false;
   
    final personalData = [
      {'key': 'Name', 'value': formatValue(student['student_name'] ?? student['name'])},
      {'key': 'Father Name', 'value': formatValue(student['father_name'])},
      {'key': 'Email', 'value': formatValue(student['email'])},
      {'key': 'Program', 'value': getProgramDisplay()},
      {'key': 'Fields', 'value': student['selected_fields'] is List ? (student['selected_fields'] as List).join(', ') : (student['fields']?.toString() ?? 'N/A')},
    ];
   
    final academicMarks = <Map<String, String>>[
      if (isGraduate) {'key': 'Bachelors CGPA', 'value': formatValue(student['bachelors_cgpa'])},
      if (!isGraduate && isOA) ...[
        {'key': 'O-Level Marks', 'value': formatValue(student['o_level_marks'])},
        {'key': 'A-Level Marks', 'value': formatValue(student['a_level_marks'])},
      ] else if (!isGraduate) ...[
        {'key': 'Matric Marks', 'value': formatValue(student['matric_marks'])},
        {'key': 'FSC Marks', 'value': formatValue(student['fsc_marks'])},
      ],
      {'key': 'ECAT Marks', 'value': formatValue(student['ecat_marks'])},
      {'key': 'NET Marks', 'value': formatValue(student['net_marks'])},
    ];

    final bestModel = getFastBestModel();
    final bestModelCapitalized = bestModel[0].toUpperCase() + bestModel.substring(1);
    final maeScore = getFastMaeScore();
   
    final meritData = [
      {'key': 'Program Name', 'value': getProgramDisplay()},
      {'key': 'FAST Admitted', 'value': formatValue(student['fast_admitted'] ?? 'false')},
      {'key': 'FAST Student Aggregate', 'value': formatValue(student['fast_student_aggregate'] ?? 'N/A')},
      {'key': 'FAST Admission Chance', 'value': formatValue(student['fast_admission_chance'] ?? 'N/A')},
      {'key': 'FAST Predicted 2026 Aggregate', 'value': formatValue(student['fast_predicted_2026_aggregate'] ?? 'N/A')},
      {'key': '$bestModelCapitalized MAE Score', 'value': maeScore},
    ];
   
    Widget buildSection(List<Map<String, String>> data, {Color? keyColor, Color? valueColor}) {
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
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: keyColor ?? Colors.deepPurple),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    entry['value']!,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: valueColor ?? Colors.black87),
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
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey.shade50],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.school, color: Colors.deepPurple.shade700),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'FAST Merit Check',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.deepPurple),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const Divider(color: Colors.deepPurple),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(
                          title: 'FAST University Data',
                          icon: Icons.school,
                          content: buildSection(meritData),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          title: 'Personal Details',
                          icon: Icons.person,
                          content: buildSection(personalData),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          title: 'Academic Marks',
                          icon: Icons.book,
                          content: buildSection(academicMarks),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, required Widget content}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.deepPurple.shade700, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            height: 24,
            width: 4,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      )
    );
  }

  Widget _buildFeeCard(String title, dynamic content) {
    if (content is Map) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 12),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.monetization_on, color: Colors.deepPurple.shade700),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...content.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            _formatKey(e.key),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              e.value.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.deepPurple.shade700,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      );
    } else if (content is List) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 12),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.monetization_on, color: Colors.deepPurple.shade700),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...content.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.deepPurple.shade400,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      );
    } else {
      return _buildRefundPolicyCard(title, content.toString());
    }
  }

  Widget _buildRefundPolicyCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.assignment_return, color: Colors.deepPurple.shade700, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.deepPurple.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Refund Policy Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple.shade700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      content,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                        fontSize: 16,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    _buildPolicyFeature(Icons.access_time, 'Processing Time', '7-14 days'),
                    const SizedBox(width: 16),
                    _buildPolicyFeature(Icons.attach_money, 'Deductions', 'As per policy'),
                    const SizedBox(width: 16),
                    _buildPolicyFeature(Icons.help_center, 'Support', 'Contact admin'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyFeature(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.deepPurple.shade700, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final feeStructure = fastFeeData['fee_structure'] ?? fastFeeData;
    final bestModel = getFastBestModel();
    final bestModelCapitalized = bestModel[0].toUpperCase() + bestModel.substring(1);
    final maeScore = getFastMaeScore();
    final predictedAggregate = widget.studentData['fast_predicted_2026_aggregate'] ?? 'N/A';
   
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'FAST University',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.school),
            onPressed: () => context.go('/fast_scholarship', extra: widget.studentData),
          ),
          IconButton(
            icon: const Icon(Icons.dashboard_customize),
            onPressed: () => context.go('/student_dashboard', extra: widget.studentData),
          ),
          IconButton(
            icon: const Icon(Icons.people_alt_rounded),
            onPressed: () => context.go('/connect-alumni', extra: widget.studentData),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade500],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.3),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => showFastMeritCheck(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.analytics,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Check Merit & Details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  color: Colors.deepPurple.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'FAST Predicted 2026 Aggregate:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatValue(predictedAggregate),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  bestModel == 'polynomial' ? Icons.polyline : Icons.show_chart,
                                  color: Colors.deepPurple.shade600,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$bestModelCapitalized MAE Score:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              maeScore,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple.shade600,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _sectionTitle('FAST University Fee Structure'),
                      if (feeStructure['tuition_fees'] != null)
                        _buildFeeCard('Tuition Fees', feeStructure['tuition_fees']),
                      if (feeStructure['student_activities_fund'] != null)
                        _buildFeeCard('Student Activities Fund', feeStructure['student_activities_fund']),
                      if (feeStructure['miscellaneous_fees'] != null)
                        _buildFeeCard('Miscellaneous Fees', feeStructure['miscellaneous_fees']),
                      if (feeStructure['refund_policy'] != null)
                        _buildFeeCard('Refund Policy', feeStructure['refund_policy']),
                    ],
                  ),
                ),
    );
  }
}