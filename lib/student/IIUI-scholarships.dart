import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart' show rootBundle;

class IIUIScholarships extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const IIUIScholarships({super.key, required this.studentData});


  @override
  State<IIUIScholarships> createState() => _IIUIScholarshipsState();
}

class _IIUIScholarshipsState extends State<IIUIScholarships> {
  List<dynamic> scholarships = [];
  String universityName = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadScholarships();
  }

  Future<void> loadScholarships() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/scholarships.json');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      final List<dynamic> universities = jsonData['universities'] ?? [];
      final iiuiData = universities.firstWhere(
        (uni) => uni['name'] ==
            "International Islamic University Islamabad (IIUI)",
        orElse: () => null,
      );

      if (iiuiData != null) {
        setState(() {
          universityName = iiuiData['name'] ?? "";
          scholarships = iiuiData['scholarships'] ?? [];
        });
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading scholarships: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildBulletList(List<dynamic> items, IconData icon, Color color) {
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.toString(),
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(universityName.isNotEmpty ? universityName : "IIUI Scholarships"),
        centerTitle: true,
        backgroundColor: Colors.green[700],
        actions: [
              IconButton(
      icon: const Icon(Icons.home),
      tooltip: 'Home',
      onPressed: () {
        context.go(
          '/student_dashboard',
          extra: widget.studentData,
        );
      },
    ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : scholarships.isEmpty
              ? const Center(child: Text("No IIUI scholarship data available"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: scholarships.length,
                  itemBuilder: (context, index) {
                    final scholarship = scholarships[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            Text(
                              scholarship['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),

                          
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                scholarship['category'] ?? '',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blueGrey[800],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                       
                            if (scholarship['eligibility'] != null) ...[
                              const Text(
                                "🎯 Eligibility",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              buildBulletList(
                                scholarship['eligibility'],
                                Icons.check_circle,
                                Colors.green,
                              ),
                              const SizedBox(height: 10),
                            ],

                         
                            if (scholarship['benefits'] != null) ...[
                              const Text(
                                "🎁 Benefits",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              buildBulletList(
                                scholarship['benefits'],
                                Icons.star,
                                Colors.orange,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
