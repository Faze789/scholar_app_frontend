import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class air_univeristy extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const air_univeristy({super.key, required this.studentData});

  @override
  State<air_univeristy> createState() => _AirUniversityDashboardState();
}

class _AirUniversityDashboardState extends State<air_univeristy> {
  final Color auColor = const Color(0xFF003B73); // Air University Blue

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Air University',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: auColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                context.go('/air-uni-fee', extra: widget.studentData);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_balance_wallet,
                        color: Colors.white, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'AU Fee',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // MAIN BODY
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER WITH IMAGE
            Container(
              height: 320,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [auColor, auColor.withOpacity(0.7)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      'https://upload.wikimedia.org/wikipedia/en/6/61/Air_University_Pakistan_Insignia.png',
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.3),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome to',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'AIR UNIVERSITY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'A federally chartered public sector university under Pakistan Air Force, pioneering research and innovation.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: auColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Explore Programs',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

       
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Air University',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: auColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Established in 2002, Air University is a public-sector university supervised by the Pakistan Air Force. '
                    'With campuses in Islamabad, Kamra (Aerospace & Aviation Campus), and Multan, AU is known for its strong programs '
                    'in Engineering, Cyber Security, Computer Science, Aviation, and Health Sciences.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('2002', 'Founded')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('12,000+', 'Students')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('3', 'Campuses')),
                    ],
                  ),
                ],
              ),
            ),

      
            _buildSection(
              title: 'Faculties',
              imageUrl:
                  'https://au.edu.pk/Pages/Faculties/FCAI/Departments/CYS/Assets/3.PSX_20191109_194422-01-011.jpeg',
              items: [
                'Faculty of Engineering',
                'Faculty of Computing & AI',
                'Faculty of Cyber Security',
                'Faculty of Aviation & Aerospace',
                'Faculty of Management Sciences',
                'Faculty of Social Sciences',
                'Faculty of Health Sciences',
              ],
            ),

            _buildSection(
              title: 'Programs Offered',
              imageUrl:
                  'https://www.au.edu.pk/AU_New_Assets/images/blog/10.jpg',
              items: [
                'BS Computer Science',
                'BS Cyber Security',
                'BS Software Engineering',
                'BS Artificial Intelligence',
                'BS Aviation Management',
                'BE Electrical Engineering',
                'MS & PhD Programs',
              ],
            ),

        
            _buildSection(
              title: 'Research & Innovation',
              imageUrl:
                  'https://aumc.edu.pk/files/research.webp',
              items: [
                'National Centre for Cyber Security (NCCS)',
                'Aerospace & Aviation Research Labs',
                'AI, Robotics & Machine Learning Labs',
                'Industry Collaboration & Technology Transfer',
                'Research Publications & Conferences',
              ],
            ),

          
            _buildSection(
              title: 'Student Life at AU',
              imageUrl:
                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSfXWqyYDg28wA2vEWe58kMQWLv5Uxk3lq37g&s',
              items: [
                'Sports & Fitness Center',
                'Air University Students Club',
                'Tech & Research Competitions',
                'Inter-University Events',
                'Hostel, Cafeteria & Transport',
              ],
            ),

            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [auColor, auColor.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Main Campus, PAF Complex, E-9 Islamabad',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.phone, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '+92-51-9153220',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.email, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'info@au.edu.pk',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

         
            Container(
              color: auColor,
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                '© 2025 Air University. All rights reserved.',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF003B73).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF003B73).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF003B73),
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String imageUrl,
    required List<String> items,
  }) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                image:
                    DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF003B73),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
