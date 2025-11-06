import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ComsatsEvent extends StatefulWidget {
  final Map<String, dynamic> alumniData;

  const ComsatsEvent({super.key, required this.alumniData});

  @override
  State<ComsatsEvent> createState() => _ComsatsEventState();
}

class _ComsatsEventState extends State<ComsatsEvent> {
  List<dynamic> events = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadComsatsEvents();
  }

  Future<void> loadComsatsEvents() async {
    try {
      final jsonString = await rootBundle.loadString('assets/uni_events.json');
      final data = json.decode(jsonString);

      final List<dynamic> universities = data['universities'] ?? [];

      final comsats = universities.firstWhere(
        (u) => u['university'] == 'COMSATS University Islamabad',
        orElse: () => null,
      );

      setState(() {
        events = comsats != null ? comsats['events'] ?? [] : [];
        isLoading = false;
      });
    } catch (e) {
      print("Error loading JSON: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showAlumniInfoDialog(BuildContext context) {
    final data = widget.alumniData;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alumni Info'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(data['image_url']),
                ),
              ),
              const SizedBox(height: 20),
              _infoRow("Name", data['name']),
              _infoRow("Gmail", data['gmail']),
              _infoRow("Institute", data['institute']),
              _infoRow("Field", data['field']),
              _infoRow("BS CGPA", data['cgpa_bs']),
              _infoRow("MS CGPA", data['cgpa_ms']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade200.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event['title'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.indigo),
              const SizedBox(width: 6),
              Text(event['date']),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                context.go('/apply-alumni', extra: {
                  'alumniData': widget.alumniData,
                  'eventTitle': event['title'],
                  'eventDate': event['date'],
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.indigo.shade200),
                ),
              ),
              child: const Text("Apply", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text("COMSATS Events"),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAlumniInfoDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Go to Home',
            onPressed: () {
              context.go('/alumni_home_screen', extra: widget.alumniData);
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : events.isEmpty
              ? const Center(child: Text("No events found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: events.length,
                  itemBuilder: (context, index) => _buildEventCard(events[index]),
                ),
    );
  }
}
