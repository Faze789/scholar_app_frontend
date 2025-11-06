import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AbroadScholarshipsScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const AbroadScholarshipsScreen({super.key, required this.studentData});

  @override
  State<AbroadScholarshipsScreen> createState() => _AbroadScholarshipsScreenState();
}

class _AbroadScholarshipsScreenState extends State<AbroadScholarshipsScreen> {
  bool showData = false;

  Widget _dashboardItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 4)),
          ],
        ),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Abroad Scholarships"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/student-dashboard', extra: widget.studentData),
        ),
        actions: [
          IconButton(
            icon: Icon(showData ? Icons.visibility : Icons.visibility_off),
            tooltip: showData ? "Hide Data" : "Show Data",
            onPressed: () {
              setState(() {
                showData = !showData;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.dashboard),
            tooltip: "Go to Dashboard",
            onPressed: () {
              context.go('/student-dashboard', extra: widget.studentData);
            },
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, ${widget.studentData['student_name'] ?? 'Student'}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        GridView.count(
                          crossAxisCount: 2,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          childAspectRatio: 1.2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _dashboardItem(
                              icon: Icons.school,
                              label: "Sweden Scholarships",
                              onTap: () => context.go(
                                '/sweden-scholarships',
                                extra: widget.studentData,
                              ),
                            ),
                            _dashboardItem(
                              icon: Icons.school,
                              label: "Turkey Scholarships",
                              onTap: () => context.go(
                                '/turkey-scholarships',
                                extra: widget.studentData,
                              ),
                            ),
                            _dashboardItem(
                              icon: Icons.school,
                              label: "Hungary Scholarships",
                              onTap: () => context.go(
                                '/hungary-scholarships',
                                extra: widget.studentData,
                              ),
                            ),
                            _dashboardItem(
                              icon: Icons.card_giftcard,
                              label: "Chevening",
                              onTap: () => context.go(
                                '/chevening-scholarship',
                                extra: widget.studentData,
                              ),
                            ),
                            _dashboardItem(
                              icon: Icons.card_giftcard,
                              label: "Erasmus",
                              onTap: () => context.go(
                                '/erasmus-scholarship',
                                extra: widget.studentData,
                              ),
                            ),
                            _dashboardItem(
                              icon: Icons.card_giftcard,
                              label: "Commonwealth",
                              onTap: () => context.go(
                                '/commonwealth-scholarship',
                                extra: widget.studentData,
                              ),
                            ),
                            _dashboardItem(
                              icon: Icons.card_giftcard,
                              label: "Rhodes",
                              onTap: () => context.go(
                                '/rhodes-scholarship',
                                extra: widget.studentData,
                              ),
                            ),
                          ],
                        ),
                        if (showData)
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width - 24,
                              ),
                              child: Text(
                                "Student Name: ${widget.studentData['student_name'] ?? 'Unknown'}\n"
                                "Email: ${widget.studentData['email'] ?? 'N/A'}",
                                style: const TextStyle(fontSize: 14),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}