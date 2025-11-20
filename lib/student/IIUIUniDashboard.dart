import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IIUIUniDashboard extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const IIUIUniDashboard({super.key, required this.studentData});

  @override
  State<IIUIUniDashboard> createState() => _IIUIUniDashboardState();
}

class _IIUIUniDashboardState extends State<IIUIUniDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'International Islamic University',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[800],
        actions: [

          IconButton(
            icon: const Icon(Icons.feed, color: Colors.white),
            tooltip: 'IIUI Fees',
            onPressed: () {
            
              context.push('/iiui-uni', extra: widget.studentData);
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
                    'https://images.unsplash.com/photo-1505533321630-975218a5f66f?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
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
                    'Welcome to IIUI',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'The International Islamic University, Islamabad (IIUI) is a prestigious institution blending modern education with Islamic values, fostering academic excellence and research.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
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
                'Explore IIUI',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 16),
           
            UniversitySection(
              title: 'Academic Programs',
              description:
                  'IIUI offers diverse programs in Islamic studies, sciences, engineering, and humanities, designed to nurture intellectual and ethical growth.',
              imageUrl:
                  'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
            ),
        
            UniversitySection(
              title: 'Research Excellence',
              description:
                  'Our research centers promote cutting-edge studies in Islamic thought, social sciences, and technology, contributing to global knowledge.',
              imageUrl:
                  'assets/iiui_re.jpg',
            ),
         
            UniversitySection(
              title: 'Campus Life',
              description:
                  'Enjoy a vibrant campus with cultural events, sports, and student societies that promote holistic development and community engagement.',
              imageUrl:
                  'https://images.unsplash.com/photo-1498243691581-b145c3f54a5a?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
            ),
          
            UniversitySection(
              title: 'International Collaboration',
              description:
                  'IIUI partners with global institutions to provide students with international exposure and opportunities for academic exchange.',
              imageUrl:
                  'https://images.unsplash.com/photo-1552664730-d307ca884978?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80',
            ),
            const SizedBox(height: 16),
            
            Container(
              color: Colors.green[800],
              padding: const EdgeInsets.all(16.0),
              child: const Center(
                child: Text(
                  '© 2025 IIUI. All rights reserved.',
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
                        color: Colors.green,
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