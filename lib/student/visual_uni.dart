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

  bool _hasGraduateMessage(Map<String, dynamic> data) {
    final List<dynamic> list = data['universities_list'] ?? [];
    return list.any((u) =>
        (u['admission_chance'] ?? '')
            .toString()
            .toLowerCase()
            .contains('graduate application'));
  }

  List<UniversityData> _getUniversityData() {
    final List<dynamic> universities = widget.studentData['universities_list'] ?? [];
    final List<UniversityData> uniList = universities.map((uni) {
      final String id = uni['id'] ?? '';
      final String name = uni['name'] ?? '';
      final bool admitted = uni['admitted'] ?? false;

      final double studentAggregate =
          (widget.studentData['${id}_student_aggregate'] ?? 0.0).toDouble();
      final double predicted2026 =
          (widget.studentData['${id}_predicted_2026_aggregate'] ?? 0.0).toDouble();

      return UniversityData(
        id: id,
        name: name,
        admitted: admitted,
        studentAggregate: studentAggregate,
        predicted2026: predicted2026,
      );
    }).toList();

    uniList.sort((a, b) {
      final aPerc = _getBarPercentage(a.studentAggregate, a.predicted2026);
      final bPerc = _getBarPercentage(b.studentAggregate, b.predicted2026);
      return bPerc.compareTo(aPerc);
    });

    return uniList;
  }

  Color _getBarColor(double student, double predicted) {
    if (student > predicted) return const Color(0xFF3B82F6);      
    if (student >= predicted - 2) return const Color(0xFF10B981); 
    if (student >= predicted - 5) return const Color(0xFFF87171); 
    return const Color(0xFF6B7280);                               
  }

  double _getBarPercentage(double student, double predicted) {
    if (predicted == 0) return 0.0;
    double perc = (student / predicted) * 100;
    if (perc > 100) perc = 100;
    if (perc < 0) perc = 0;
    return perc;
  }

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
    final isGraduate =
        (widget.studentData['program_level'] == 'masters') ||
        (widget.studentData['bachelors_cgpa'] != null) ||
        _hasGraduateMessage(widget.studentData);

    if (isGraduate) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          actions: [
            IconButton(onPressed: () {
              context.go('/student_dashboard', extra: widget.studentData);
            }, icon: Icon(Icons.home))
          ],
        ),
        backgroundColor: const Color(0xFF0F172A),
        body: Center(
          child: Text(
            'You are a graduated student',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      );
    }

    final universityData = _getUniversityData();
    final admittedCount = universityData.where((u) => u.admitted == true).length;
    final totalCount = universityData.length;

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
    final percentage = _getBarPercentage(uni.studentAggregate, uni.predicted2026);
    final color = _getBarColor(uni.studentAggregate, uni.predicted2026);

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
                '${percentage.toStringAsFixed(1)}%',
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
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  Container(
                    height: 40,
                    width: (MediaQuery.of(context).size.width - 40) *
                        (percentage / 100) *
                        _animation.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
              _buildScorePill('Predicted', uni.predicted2026),
              if (uni.admitted == true)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check_circle,
                      color: Color(0xFF10B981), size: 20),
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
  final double studentAggregate;
  final double predicted2026;

  UniversityData({
    required this.id,
    required this.name,
    required this.admitted,
    required this.studentAggregate,
    required this.predicted2026,
  });
}
