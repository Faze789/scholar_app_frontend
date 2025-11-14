import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http; // for API requests

class AirUniFees extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const AirUniFees({super.key, required this.studentData});

  @override
  State<AirUniFees> createState() => _AirUniFeesState();
}

class _AirUniFeesState extends State<AirUniFees> {
  Map<String, dynamic>? feeData;
  Map<String, dynamic>? scholarshipData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadData();
  }


  Future<void> loadData() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.100.121:5000/feesair"));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

     
        if (decoded is Map<String, dynamic> && decoded.containsKey("fee_structure")) {
          setState(() {
            feeData = decoded["fee_structure"];
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = "Invalid API response structure";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Server error: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error fetching data: $e";
        isLoading = false;
      });
    }
  }

  
  String formatValue(dynamic value) {
    if (value is double) {
      return value.toStringAsFixed(1);
    }
    return value?.toString() ?? 'N/A';
  }


  String _formatKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (match) => '${match[1]} ${match[2]}')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

 
  Widget _buildFeeCard(String programName, dynamic programData) {
    
    if (programData is String) {
      return Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "$programName: $programData",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo),
          ),
        ),
      );
    } else if (programData is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            programName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.indigo),
          ),
          const SizedBox(height: 8),
          ...programData.map((item) {
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text(item["Course/Program Name"] ?? "N/A"),
                subtitle: Text(item["Fee Structure"] ?? "N/A"),
                trailing: Text(item["Duration"] ?? ""),
              ),
            );
          }),
        ],
      );
    } else if (programData is Map<String, dynamic>) {
 
      return _buildFeeCard(programName, programData.values.toList());
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: const Text(
    "Air University Fee & Scholarships",
    style: TextStyle(color: Colors.white),
  ),
  backgroundColor: Colors.indigo,
  actions: [
   IconButton(
  icon: const Icon(Icons.assessment, color: Colors.white),
  tooltip: 'Merit Check',
  onPressed: () {

    final airData = <String, dynamic>{};
    widget.studentData.forEach((key, value) {
      if (key.toLowerCase().contains('air')) {
        airData[key] = value;
      }
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Air University Merit Check",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.indigo),
          ),
          content: airData.isEmpty
              ? const Text("No Air University data found in student info.")
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: airData.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              _formatKey(entry.key),
                              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.indigo),
                            ),
                          ),
                          const Text(": ", style: TextStyle(fontWeight: FontWeight.w600)),
                          Expanded(
                            flex: 3,
                            child: Text(formatValue(entry.value)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Close",
                style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  },
),

    IconButton(
      icon: const Icon(Icons.school_sharp, color: Colors.white),
      tooltip: 'Scholarships',
      onPressed: () {
        context.go('/air-scholarship', extra: widget.studentData); 
      },
    ),
    IconButton(
      icon: const Icon(Icons.dashboard_customize, color: Colors.white),
      tooltip: 'Student Dashboard',
      onPressed: () {
        context.go('/student_dashboard', extra: widget.studentData); 
      },
    ),
  ],
),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    "⚠️ $errorMessage",
                    style: const TextStyle(fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display fees from API
                      if (feeData != null)
                        ...feeData!.entries.map((entry) => _buildFeeCard(entry.key, entry.value)),

                      const SizedBox(height: 24),
                      // Scholarships & contact sections remain unchanged
                      buildScholarshipSection(),
                      const SizedBox(height: 24),
                      buildContactSection(),
                    ],
                  ),
                ),
    );
  }

  
  Widget buildScholarshipSection() => Container(); 
  Widget buildContactSection() => Container(); 
}
