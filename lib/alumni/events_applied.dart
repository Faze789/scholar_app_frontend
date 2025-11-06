import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventsApplied extends StatefulWidget {
  final Map<String, dynamic> alumniData;

  const EventsApplied({super.key, required this.alumniData});

  static Widget _infoText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            TextSpan(
              text: "$title:\n",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  State<EventsApplied> createState() => _EventsAppliedState();
}

class _EventsAppliedState extends State<EventsApplied> {
  void _showPersonalInfoDialog(BuildContext context, Map<String, dynamic> data, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "🎓 Your Personal Information",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
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
              EventsApplied._infoText("User ID (Document ID)", docId),
              EventsApplied._infoText("Name", data['name']),
              EventsApplied._infoText("Gmail", data['gmail']),
              EventsApplied._infoText("Institute", data['institute']),
              EventsApplied._infoText("Field", data['field']),
              EventsApplied._infoText("BS CGPA", data['cgpa_bs']),
              EventsApplied._infoText("MS CGPA", data['cgpa_ms']),
              EventsApplied._infoText("Event Title", data['event_title']),
              EventsApplied._infoText("Event Date", data['event_date']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String gmail = widget.alumniData['gmail'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events You Applied To'),
        backgroundColor: Colors.indigo,
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('alumni_events')
            .where('gmail', isEqualTo: gmail)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No events applied yet."));
          }

          final events = snapshot.data!.docs;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final doc = events[index];
              final event = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  onTap: () => _showPersonalInfoDialog(context, event, doc.id),
                  contentPadding: const EdgeInsets.all(16),
                  leading: const Icon(Icons.event_available, color: Colors.indigo),
                  title: Text(
                    event['event_title'] ?? 'No Title',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      if (event['description'] != null)
                        Text(event['description']),
                      if (event['event_date'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text("📅 ${event['event_date']}"),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
