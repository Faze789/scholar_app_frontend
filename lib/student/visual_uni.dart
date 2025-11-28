import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VisualUni extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const VisualUni({super.key, required this.studentData});

  @override
  State<VisualUni> createState() => _VisualUniState();
}

class _VisualUniState extends State<VisualUni> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Compute admission chance based on score vs last year aggregate
  String computeChance(double student, double required) {
    final diff = student - required;
    if (diff >= 5) return 'High (90%+)';
    if (diff >= 2) return 'Good (70-90%)';
    if (diff >= 0) return 'Possible (30-70%)';
    if (diff >= -2) return 'Low (20-30%)';
    return 'Very Low (0-20%)';
  }

  List<UniversityData> _getUniversityData() {
    final List<dynamic> universities = widget.studentData['universities_list'] ?? [];
    final List<UniversityData> uniList = universities.map((uni) {
      final String id = uni['id'] ?? '';
      final String name = uni['name'] ?? '';
      final bool admitted = uni['admitted'] ?? false;

      final double studentAggregate = (widget.studentData['${id}_student_aggregate'] ?? 0.0).toDouble();
      final double lastYearAggregate = (widget.studentData['${id}_last_year_aggregate'] ?? 0.0).toDouble();
      final double predicted2026 = (widget.studentData['${id}_predicted_2026_aggregate'] ?? 0.0).toDouble();

      // Use our computed chance instead of backend string
      final String admissionChance = computeChance(studentAggregate, lastYearAggregate);

      return UniversityData(
        id: id,
        name: name,
        admitted: admitted,
        admissionChance: admissionChance,
        studentAggregate: studentAggregate,
        lastYearAggregate: lastYearAggregate,
        predicted2026: predicted2026,
      );
    }).toList();

    uniList.sort((a, b) {
      final aPercentage = _getChancePercentage(a.admissionChance);
      final bPercentage = _getChancePercentage(b.admissionChance);
      return bPercentage.compareTo(aPercentage);
    });

    return uniList;
  }

  Color _getChanceColor(String chance) {
    if (chance.contains('High (90%+)')) return const Color(0xFF10B981);
    if (chance.contains('Good (70-90%)')) return const Color(0xFF3B82F6);
    if (chance.contains('Possible (30-70%)')) return const Color(0xFFF59E0B);
    if (chance.contains('Low (20-30%)')) return const Color(0xFFF87171);
    return const Color(0xFF6B7280);
  }

  double _getChancePercentage(String chance) {
    if (chance.contains('High (90%+)')) return 95.0;
    if (chance.contains('Good (70-90%)')) return 80.0;
    if (chance.contains('Possible (30-70%)')) return 50.0;
    if (chance.contains('Low (20-30%)')) return 25.0;
    return 10.0;
  }

  /// Full Firestore conversion for printing
  dynamic _convert(value) {
    if (value is Timestamp) return value.toDate().toString();
    if (value is GeoPoint) return {"latitude": value.latitude, "longitude": value.longitude};
    if (value is DocumentReference) return value.path;
    if (value is Map) return value.map((k, v) => MapEntry(k, _convert(v)));
    if (value is List) return value.map(_convert).toList();
    return value;
  }

  void printFull(String text) {
    const int chunkSize = 800;
    for (int i = 0; i < text.length; i += chunkSize) {
      print(text.substring(i, i + chunkSize > text.length ? text.length : i + chunkSize));
    }
  }

  @override
  Widget build(BuildContext context) {
    final universityData = _getUniversityData();
    final admittedCount = universityData.where((u) => u.admitted == true).length;
    final totalCount = universityData.where((u) => u.admitted != null).length;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              final converted = _convert(widget.studentData);
              final jsonText = jsonEncode(converted);
              printFull(jsonText);
            },
            icon: const Icon(Icons.check),
          )
        ],
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'University Admission Analysis',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () {
            context.go('/student_dashboard', extra: widget.studentData);
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Admitted',
                  '$admittedCount/$totalCount',
                  Icons.check_circle,
                  const Color(0xFF10B981),
                ),
                _buildStatCard(
                  'Avg Score',
                  '${widget.studentData['matric_marks'] != null ? ((widget.studentData['matric_marks'] as num) / 11).toStringAsFixed(1) : 'N/A'}%',
                  Icons.school,
                  const Color(0xFF3B82F6),
                ),
                _buildStatCard(
                  'Top Match',
                  _getTopMatch(universityData),
                  Icons.star,
                  const Color(0xFFF59E0B),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildBarView(universityData),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBarView(List<UniversityData> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aggregate Comparison',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...data.map((uni) => _buildBarItem(uni)),
        ],
      ),
    );
  }

  Widget _buildBarItem(UniversityData uni) {
    final percentage = _getChancePercentage(uni.admissionChance);
    final color = _getChanceColor(uni.admissionChance);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  uni.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${percentage.toInt()}%',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Stack(
                children: [
                  Container(
                    height: 40,
                    decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(20)),
                  ),
                  Container(
                    height: 40,
                    width: (MediaQuery.of(context).size.width - 40) * (percentage / 100) * _animation.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Center(
                      child: Text(
                        uni.admissionChance,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildScorePill('Your Score', uni.studentAggregate),
              const SizedBox(width: 8),
              _buildScorePill('Required', uni.lastYearAggregate),
              if (uni.admitted == true)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScorePill(String label, double score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Text(
        '$label: ${score.toStringAsFixed(1)}',
        style: const TextStyle(color: Colors.white70, fontSize: 11),
      ),
    );
  }

  String _getTopMatch(List<UniversityData> data) {
    final admitted = data.where((u) => u.admitted == true).toList();
    if (admitted.isEmpty) return 'None';
    admitted.sort((a, b) => b.studentAggregate.compareTo(a.studentAggregate));
    final name = admitted.first.name;
    return name.length > 8 ? '${name.substring(0, 8)}...' : name;
  }
}

class UniversityData {
  final String id;
  final String name;
  final bool? admitted;
  final String admissionChance;
  final double studentAggregate;
  final double lastYearAggregate;
  final double predicted2026;

  UniversityData({
    required this.id,
    required this.name,
    required this.admitted,
    required this.admissionChance,
    required this.studentAggregate,
    required this.lastYearAggregate,
    required this.predicted2026,
  });
}
