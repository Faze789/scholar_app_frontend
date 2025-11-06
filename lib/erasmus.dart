import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class ErasmusScholarshipScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const ErasmusScholarshipScreen({super.key, required this.studentData});

  @override
  State<ErasmusScholarshipScreen> createState() => _ErasmusScholarshipScreenState();
}

class _ErasmusScholarshipScreenState extends State<ErasmusScholarshipScreen> {
  Map<String, dynamic>? scholarshipData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchScholarshipData();
  }

  Future<void> fetchScholarshipData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.100.149:5000/erasmus'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        setState(() {
          scholarshipData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching data: $e';
        isLoading = false;
      });
    }
  }

  Widget _buildDataDisplay() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading Erasmus scholarship data...'),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 64),
            SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchScholarshipData,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (scholarshipData == null) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return ListView(
      children: [
        // Title
        if (scholarshipData?['title'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              scholarshipData!['title'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
          ),

        // Headings and Paragraphs
        ..._buildContentSections(),

        // Facts section if available
        if (scholarshipData?['facts'] != null && scholarshipData!['facts'] is Map)
          ..._buildFactsSection(),

        const SizedBox(height: 20),
      ],
    );
  }

  List<Widget> _buildContentSections() {
    List<Widget> sections = [];
    
    final headings = scholarshipData?['headings'] as List?;
    final paragraphs = scholarshipData?['paragraphs'] as List?;

    if (headings != null && paragraphs != null) {
      for (int i = 0; i < headings.length; i++) {
        // Add heading
        sections.add(
          Padding(
            padding: EdgeInsets.only(
              top: i == 0 ? 0 : 16.0,
              bottom: 8.0,
            ),
            child: Text(
              headings[i],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ),
        );

        // Find corresponding paragraph
        if (i < paragraphs.length && paragraphs[i] != null) {
          sections.add(
            Text(
              paragraphs[i],
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.justify,
            ),
          );
        }

        // Add divider except for last item
        if (i < headings.length - 1) {
          sections.add(const Divider(height: 24));
        }
      }
    } else {
      // Fallback content if structure is different
      sections.addAll([
        ListTile(
          title: const Text(
            "Overview",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            scholarshipData?['overview'] ?? 
            "Erasmus+ supports student mobility and joint master's degrees across European universities.",
          ),
        ),
        const Divider(),
        ListTile(
          title: const Text(
            "Eligibility",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            scholarshipData?['eligibility'] ?? 
            "Open to students enrolled in a higher education institution. Requires good academic standing.",
          ),
        ),
        const Divider(),
        ListTile(
          title: const Text(
            "How to Apply",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            scholarshipData?['applicationProcess'] ?? 
            "Apply through your home university's Erasmus+ coordinator. Submit academic records and a study plan.",
          ),
        ),
      ]);
    }

    return sections;
  }

  List<Widget> _buildFactsSection() {
    final facts = scholarshipData?['facts'] as Map?;
    if (facts == null || facts.isEmpty) return [];

    return [
      const SizedBox(height: 16),
      const Text(
        "Key Facts:",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.greenAccent,
        ),
      ),
      const SizedBox(height: 8),
      ...facts.entries.map((entry) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "• ",
              style: TextStyle(color: Colors.green.shade600),
            ),
            Expanded(
              child: Text(
                "${entry.key}: ${entry.value}",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      )),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Erasmus Scholarship"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/abroad-scholarships', extra: widget.studentData),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchScholarshipData,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.purple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dynamic title from API or fallback
                Text(
                  scholarshipData?['title'] ?? "Erasmus Scholarship",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: _buildDataDisplay(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}