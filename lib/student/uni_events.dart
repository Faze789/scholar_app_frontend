import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart' show rootBundle;

class UniEvents extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const UniEvents({super.key, required this.studentData});

  @override
  State<UniEvents> createState() => _UniEventsState();
}

class _UniEventsState extends State<UniEvents> {
  List<dynamic> universities = [];

  String getCategory(Map<String, dynamic> item) {
    return item['category'] ??
        item['type'] ??
        item['level'] ??
        item['name'] ??
        item['program_level'] ??
        item['title'] ??
        'No Category';
  }

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    final String jsonString =
        await rootBundle.loadString('assets/uni_events.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      universities = jsonData['universities'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('University Events'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Student Dashboard',
            onPressed: () {
              context.go(
                '/student_dashboard',
                extra: widget.studentData,
              );
            },
          ),
        ],
      ),
      body: universities.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: universities.length,
              itemBuilder: (context, index) {
                final uni = universities[index];
                final events = uni['events'] as List? ?? [];
                if (events.isEmpty) return const SizedBox(); // skip if no events
                return _buildUniversityCard(uni, events);
              },
            ),
    );
  }

  Widget _buildUniversityCard(Map<String, dynamic> uni, List<dynamic> events) {
    final universityName = uni['university'] ?? 'Unknown University';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        title: Text(
          universityName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        children: events
            .map((event) => _buildEventTile(event, universityName))
            .toList(),
      ),
    );
  }

  Widget _buildEventTile(Map<String, dynamic> event, String universityName) {
    final title = event['title'] ?? 'No Title';
    final category = getCategory(event);
    final date = event['date'] ?? 'No date provided';

    return ListTile(
      leading: const Icon(Icons.event, color: Colors.deepPurple),
      title: Text(title),
      subtitle: Text(
        "$category • $date",
        style: const TextStyle(color: Colors.black54),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
