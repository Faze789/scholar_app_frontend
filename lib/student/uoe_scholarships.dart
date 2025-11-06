import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart' show rootBundle;

class UoeScholarships extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const UoeScholarships({super.key, required this.studentData});

  @override
  State<UoeScholarships> createState() => _UoeScholarshipsState();
}

class _UoeScholarshipsState extends State<UoeScholarships> {
  List<dynamic> scholarships = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadScholarships();
  }

  Future<void> loadScholarships() async {
    try {
      final String response = await rootBundle.loadString('assets/scholarships.json');
      final data = json.decode(response);
      if (data is Map && data['universities'] is List) {
        final List universities = data['universities'];
        final university = universities.firstWhere(
          (u) => u['university']
              .toString()
              .toLowerCase()
              .contains('university of education'),
          orElse: () => null,
        );
        if (university != null && university['scholarships'] is List) {
          setState(() {
            scholarships = university['scholarships'];
            isLoading = false;
          });
        } else {
          setState(() {
            scholarships = [];
            isLoading = false;
          });
        }
      } else {
        setState(() {
          scholarships = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.studentData;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "University of Education Scholarships",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 6,
        shadowColor: Colors.indigoAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_customize, color: Colors.white),
            tooltip: 'Student Dashboard',
            onPressed: () {
              context.go('/student_dashboard', extra: student);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : scholarships.isEmpty
              ? const Center(
                  child: Text(
                    "No scholarships found for University of Education.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : RefreshIndicator(
                  color: Colors.indigo,
                  onRefresh: loadScholarships,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.indigo.shade700, Colors.indigoAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Text(
                            "🎓 Available Scholarships",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: scholarships.length,
                          itemBuilder: (context, index) {
                            final sch = scholarships[index];
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sch['title'] ?? 'No Title',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      sch['description'] ?? 'No description available.',
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade800,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    _infoRow(Icons.attach_money, "Funding Resource", sch['funding_resource']),
                                    _infoRow(Icons.monetization_on, "Financial Support", sch['financial_support']),
                                    _infoRow(Icons.how_to_reg, "How to Apply", sch['how_to_apply']),
                                    if (sch['details_link'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6.0),
                                        child: InkWell(
                                          onTap: () {},
                                          child: Text(
                                            sch['details_link'],
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 25),
                        const Divider(thickness: 1.5),
                        const SizedBox(height: 10),
                        const Text(
                          "👤 Student Information",
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoRow(Icons.person, "Name", student['name']),
                                _infoRow(Icons.email, "Email", student['email']),
                                _infoRow(Icons.school, "Program", student['program']),
                                _infoRow(Icons.grade, "CGPA", student['cgpa']),
                                if (student['fields'] != null)
                                  _infoRow(Icons.list, "Fields", (student['fields'] as List).join(', ')),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _infoRow(IconData icon, String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.indigo, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$title: ${value ?? 'N/A'}",
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
