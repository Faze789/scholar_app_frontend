import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LumsDashboard extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const LumsDashboard({super.key, required this.studentData});

  @override
  State<LumsDashboard> createState() => _LumsDashboardState();
}

class _LumsDashboardState extends State<LumsDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LUMS University',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.monetization_on, color: Colors.white),
            tooltip: 'LUMS Fees',
            onPressed: () {
              
              context.push('/lums-uni', extra: widget.studentData);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1562774050-3a2b43b8d92a?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black54,
                    BlendMode.darken,
                  ),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to LUMS',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Lahore University of Management Sciences (LUMS) is a leading institution in Pakistan, renowned for its world-class education in business, humanities, and sciences.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
       
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Explore LUMS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 16),
           
            UniversitySection(
              title: 'Academic Programs',
              description:
                  'LUMS offers a diverse range of programs in management, law, engineering, sciences, and humanities, designed to foster critical thinking and leadership.',
              imageUrl:
                  'assets/lums_acad.jpg',
            ),
         
            UniversitySection(
              title: 'Research & Innovation',
              description:
                  'Our state-of-the-art research facilities and innovation centers drive transformative solutions for industry and society.',
              imageUrl:
                  'assets/lums_res.jpg',
            ),
          
            UniversitySection(
              title: 'Campus Life',
              description:
                  'Experience a dynamic campus environment with vibrant student societies, sports, and cultural events that enrich the LUMS experience.',
              imageUrl:
                  'https://images.unsplash.com/photo-1516321497487-e288fb19713f?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
            ),
       
            UniversitySection(
              title: 'Global Opportunities',
              description:
                  'LUMS connects students with global universities and industries, offering exchange programs and international internships.',
              imageUrl:
                  'assets/lums_global.png',
            ),
            const SizedBox(height: 16),
     
            Container(
              color: Colors.red[800],
              padding: const EdgeInsets.all(16.0),
              child: const Center(
                child: Text(
                  '© 2025 LUMS. All rights reserved.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class UniversitySection extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  const UniversitySection({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: (imageUrl.startsWith('assets/')
    ? Image.asset(
        imageUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      )
    : Image.network(
        imageUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 120,
            height: 120,
            color: Colors.grey,
            child: const Icon(Icons.error),
          );
        },
      )),

            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}