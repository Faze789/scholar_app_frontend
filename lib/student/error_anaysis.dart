import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorAnalysis extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const ErrorAnalysis({super.key, required this.studentData});

  @override
  State<ErrorAnalysis> createState() => _ErrorAnalysisState();
}

class _ErrorAnalysisState extends State<ErrorAnalysis> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Analysis Check'),
        centerTitle: true,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What is MSE (Mean Squared Error)?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                '• MSE measures how far predictions are from actual values by taking the average of squared differences.',
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                '• Lower MSE means better accuracy; higher MSE means the model is performing poorly.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 25),
              const Text(
                'MSE Rating Scale',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _buildScaleRow('Excellent', '0 - 2', Colors.green.shade400),
                    const SizedBox(height: 12),
                    _buildScaleRow('Good', '3 - 5', Colors.blue.shade400),
                    const SizedBox(height: 12),
                    _buildScaleRow('Average', '6 - 8', Colors.orange.shade400),
                    const SizedBox(height: 12),
                    _buildScaleRow('Poor', '9+', Colors.red.shade400),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScaleRow(String label, String range, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(range, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ),
      ],
    );
  }
}
