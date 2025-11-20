import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

class CheveningScholarshipScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const CheveningScholarshipScreen({super.key, required this.studentData});

  @override
  State<CheveningScholarshipScreen> createState() => _CheveningScholarshipScreenState();
}

class _CheveningScholarshipScreenState extends State<CheveningScholarshipScreen> {
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
        Uri.parse('http://35.174.6.20:5000/chevening'),
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
            Text('Loading scholarship data...'),
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

    // Display the data based on the structure you expect from the API
    return ListView(
      children: [
        // Overview Section
        _buildSection(
          title: 'Overview',
          content: scholarshipData?['overview'] ?? 
                   'Chevening Scholarships fund postgraduate studies in the UK for future leaders and influencers.',
        ),
        
        const Divider(),
        
        // Eligibility Section
        _buildSection(
          title: 'Eligibility',
          content: scholarshipData?['eligibility'] ?? 
                   'Requires a bachelor\'s degree, work experience, and leadership potential. Must meet English language requirements.',
        ),
        
        const Divider(),
        
        // How to Apply Section
        _buildSection(
          title: 'How to Apply',
          content: scholarshipData?['applicationProcess'] ?? 
                   'Apply via the Chevening website. Submit essays, references, and proof of academic and professional achievements.',
        ),
        
        const Divider(),
        
        // Display additional dynamic data
        ..._buildAdditionalData(),
      ],
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(content),
    );
  }

  List<Widget> _buildAdditionalData() {
    if (scholarshipData == null) return [];
    
    List<Widget> additionalWidgets = [];
    
    // Add dynamic fields from the API response (excluding already displayed ones)
    scholarshipData!.forEach((key, value) {
      if (!['overview', 'eligibility', 'applicationProcess'].contains(key)) {
        additionalWidgets.addAll([
          ListTile(
            title: Text(
              _formatKey(key),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(value.toString()),
          ),
          const Divider(),
        ]);
      }
    });
    
    return additionalWidgets;
  }

  String _formatKey(String key) {
    // Convert snake_case or camelCase to Title Case
    String formatted = key.replaceAll('_', ' ').splitMapJoin(
      RegExp(r'[A-Z]'),
      onMatch: (m) => ' ${m[0]}',
      onNonMatch: (n) => n,
    );
    return formatted.replaceFirstMapped(RegExp(r'^[a-z]'), (match) => match.group(0)!.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chevening Scholarship"),
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
                // Header with dynamic title if available
                Text(
                  scholarshipData?['title'] ?? "Chevening Scholarship",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Display last updated time if available
                if (scholarshipData?['lastUpdated'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Last updated: ${scholarshipData!['lastUpdated']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Main content area
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    padding: const EdgeInsets.all(12.0),
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