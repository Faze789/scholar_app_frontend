import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class CommonwealthScholarshipScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const CommonwealthScholarshipScreen({super.key, required this.studentData});

  @override
  State<CommonwealthScholarshipScreen> createState() => _CommonwealthScholarshipScreenState();
}

class _CommonwealthScholarshipScreenState extends State<CommonwealthScholarshipScreen> {
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
        Uri.parse('http://192.168.100.121:5000/commonwealth'),
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
            Text('Loading Commonwealth scholarship data...'),
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

        // Quick Facts Table
        _buildFactsTable(),

        const SizedBox(height: 20),

        // Headings and Paragraphs
        ..._buildContentSections(),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFactsTable() {
    final facts = scholarshipData?['facts'] as Map?;
    if (facts == null || facts.isEmpty) return Container();

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📊 Quick Facts",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue
            ),
          ),
          const SizedBox(height: 12),
          ...facts.entries.map((entry) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    entry.value.toString(),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<Widget> _buildContentSections() {
    List<Widget> sections = [];
    
    final headings = scholarshipData?['headings'] as List?;
    final paragraphs = scholarshipData?['paragraphs'] as List?;

    if (headings != null && paragraphs != null) {
      for (int i = 0; i < headings.length; i++) {
        // Skip "Table of Contents" heading since we have the facts table
        if (headings[i] == "Table of Contents") continue;

        // Add heading
        sections.add(
          Padding(
            padding: EdgeInsets.only(
              top: i == 0 ? 0 : 20.0,
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

        // Find corresponding paragraphs
        List<String> relatedParagraphs = [];
        for (int j = 0; j < paragraphs.length; j++) {
          // Simple logic to map headings to paragraphs (you might need to adjust this based on your API structure)
          if (j >= i && j < i + 3) { // Get next 3 paragraphs for this heading
            if (paragraphs[j] != null && paragraphs[j].toString().isNotEmpty) {
              relatedParagraphs.add(paragraphs[j]);
            }
          }
        }

        // Add related paragraphs
        for (String paragraph in relatedParagraphs) {
          sections.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                paragraph,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          );
        }

        // Add divider except for last item
        if (i < headings.length - 1 && headings[i] != "Table of Contents") {
          sections.add(const Divider(height: 24));
        }
      }
    }

    // If no content was added, show fallback content
    if (sections.isEmpty) {
      sections.addAll([
        ListTile(
          title: const Text(
            "Overview",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            scholarshipData?['overview'] ?? 
            "Commonwealth Scholarships support students from Commonwealth countries for postgraduate studies in the UK and other member countries.",
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
            "Requires a bachelor's degree and citizenship of a Commonwealth country. Strong academic record needed.",
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
            "Apply through the Commonwealth Scholarship Commission website. Submit academic transcripts and references.",
          ),
        ),
      ]);
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Commonwealth Scholarship"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/abroad-scholarships', extra: widget.studentData),
        ),
        actions: [
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
                  scholarshipData?['title'] ?? "Commonwealth Scholarship",
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