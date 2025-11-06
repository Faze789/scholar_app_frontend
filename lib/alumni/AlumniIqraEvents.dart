import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class AlumniIqraEvents extends StatefulWidget {
  final Map<String, dynamic> alumniData;

  const AlumniIqraEvents({super.key, required this.alumniData});

  @override
  State<AlumniIqraEvents> createState() => _AlumniIqraEventsState();
}

class _AlumniIqraEventsState extends State<AlumniIqraEvents> {
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    loadEventData();
  }

  Future<void> loadEventData() async {
    final String jsonString = await rootBundle.loadString('assets/uni_events.json');
    final Map<String, dynamic> data = json.decode(jsonString);

    final List<dynamic> universities = data['universities'];
    final iqraData = universities.firstWhere(
      (u) => u['university'] == 'Iqra University Islamabad Campus',
      orElse: () => null,
    );

    if (iqraData != null) {
      setState(() {
        events = List<Map<String, dynamic>>.from(iqraData['events']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iqra University Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Home',
            onPressed: () {
              context.go('/alumni_home_screen', extra: widget.alumniData);
            },
          ),
        ],
      ),
      body: events.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.event, color: Colors.deepPurple),
                    title: Text(event['title']),
                    subtitle: Text('${event['category']} • ${event['date']}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        context.go('/apply-alumni', extra: {
                          'alumniData': widget.alumniData,
                          'eventTitle': event['title'],
                          'eventDate': event['date'],
                        });
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
