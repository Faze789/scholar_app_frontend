import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplyAlumnii extends StatefulWidget {
  final Map<String, dynamic> alumniData;
  final String eventTitle;
  final String eventDate;

  const ApplyAlumnii({
    super.key,
    required this.alumniData,
    required this.eventTitle,
    required this.eventDate,
  });

  @override
  State<ApplyAlumnii> createState() => _ApplyAlumniiState();
}

class _ApplyAlumniiState extends State<ApplyAlumnii> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController gmailController;
  late TextEditingController instituteController;
  late TextEditingController fieldController;
  late TextEditingController cgpaBsController;
  late TextEditingController cgpaMsController;

  @override
  void initState() {
    super.initState();

      print("🧾 Received alumniData: ${widget.alumniData}");
    nameController = TextEditingController(text: widget.alumniData['name']);
    gmailController = TextEditingController(text: widget.alumniData['gmail']);
    instituteController = TextEditingController(text: widget.alumniData['institute']);
    fieldController = TextEditingController(text: widget.alumniData['field']);
    cgpaBsController = TextEditingController(text: widget.alumniData['cgpa_bs']);
    cgpaMsController = TextEditingController(text: widget.alumniData['cgpa_ms']);
  }

  Future<String> _generateUniqueId() async {
    final random = Random();
    String id;

    do {
      final randomNum = random.nextInt(99999).toString().padLeft(5, '0');
      id = 'AB$randomNum';
    } while ((await FirebaseFirestore.instance.collection('alumni_events').doc(id).get()).exists);

    return id;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() != true) return;

    final uniqueId = await _generateUniqueId();

    final data = {
      'id': uniqueId,
      'name': nameController.text.trim(),
      'gmail': gmailController.text.trim(),
      'institute': instituteController.text.trim(),
      'field': fieldController.text.trim(),
      'cgpa_bs': cgpaBsController.text.trim(),
      'cgpa_ms': cgpaMsController.text.trim(),
      'event_title': widget.eventTitle,
      'event_date': widget.eventDate,
      'image_url': widget.alumniData['image_url'],
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance
        .collection('alumni_events')
        .doc(uniqueId)
        .set(data);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Registered successfully for ${widget.eventTitle}"),
          backgroundColor: Colors.green,
        ),
      );
     context.go('/alumni_home_screen', extra: widget.alumniData);

    }
  }

  Widget _buildField(String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.indigo.shade50,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
  title: Text(widget.eventTitle),
  backgroundColor: Colors.indigo,
  actions: [
    IconButton(
      icon: const Icon(Icons.home),
      tooltip: 'Home screen',
      onPressed: () {
     context.go('/alumni_home_screen', extra: widget.alumniData);

      },
    ),
  ],
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(30),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        '📅 ${widget.eventDate}',
        style: const TextStyle(color: Colors.white70),
      ),
    ),
  ),
),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(widget.alumniData['image_url']),
                  ),
                  const SizedBox(height: 20),

                  _buildField("Name", nameController),
                  _buildField("Gmail", gmailController, readOnly: true),
                  _buildField("Institute", instituteController),
                  _buildField("Field", fieldController),
                  _buildField("BS CGPA", cgpaBsController),
                  _buildField("MS CGPA", cgpaMsController),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Register", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
