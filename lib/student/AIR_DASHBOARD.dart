import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class air_univeristy extends StatefulWidget {
  final Map<String, dynamic> studentData;
  const air_univeristy({super.key, required this.studentData});

  @override
  State<air_univeristy> createState() => _UOLUniversityDashboardState();
}

class _UOLUniversityDashboardState extends State<air_univeristy> {
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
        backgroundColor: const Color(0xFF004D40), 
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
                    Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'AIR Fee',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
           
            Container(
              height: 320,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF004D40), Color(0xFF00695C)],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1591123120675-6f7f1aae0e5b?auto=format&fit=crop&w=1000&q=80',
                      fit: BoxFit.cover,
                      opacity: const AlwaysStoppedAnimation(0.4),
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
                          'Transforming lives through quality education and research since 1999',
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
                            foregroundColor: const Color(0xFF004D40),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
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
                  const Text(
                    'About AIR UNIVERSITY',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004D40),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Founded in 1999, the AIR UNIVERSITY is one of Pakistan’s leading private universities, known for its diverse academic programs and state-of-the-art facilities. With campuses in Lahore, Islamabad, Sargodha, and Gujrat, UOL is dedicated to fostering innovation, research, and global leadership.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('25+', 'Years of Excellence'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('35,000+', 'Students'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('5', 'Campuses'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

      
            _buildSection(
              title: 'Academic Faculties',
              imageUrl: 'https://images.unsplash.com/photo-1503676260728-332c239b7241?auto=format&fit=crop&w=1000&q=80',
              items: [
                'Faculty of Engineering & Technology',
                'Faculty of Information Technology',
                'Faculty of Management Sciences',
                'Faculty of Allied Health Sciences',
                'Faculty of Law',
                'Faculty of Arts & Architecture',
              ],
            ),

            
            _buildSection(
              title: 'Programs & Degrees',
              imageUrl: 'https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04?auto=format&fit=crop&w=1000&q=80',
              items: [
                'Undergraduate Programs (BS/BBA)',
                'Master’s Programs (MS/MBA)',
                'Doctoral Programs (PhD)',
                'Professional Certifications',
                'Medical & Dental Programs',
                'Online Learning Programs',
              ],
            ),

           
            _buildSection(
              title: 'Research & Innovation',
              imageUrl: 'https://images.unsplash.com/photo-1532094349884-543995b5f930?auto=format&fit=crop&w=1000&q=80',
              items: [
                'Research Centers & Labs',
                'Innovation & Entrepreneurship Hub',
                'Industry-Academia Collaborations',
                'Research Publications',
                'Technology Transfer Initiatives',
                'Sustainable Development Projects',
              ],
            ),

          
            _buildSection(
              title: 'Student Life',
              imageUrl: 'https://images.unsplash.com/photo-1523050854058-8df90110c9d1?auto=format&fit=crop&w=1000&q=80',
              items: [
                'Student Societies & Clubs',
                'Sports & Fitness Facilities',
                'Cultural & Tech Events',
                'Career Services & Internships',
                'Hostel & Residential Facilities',
                'Student Wellness Programs',
              ],
            ),

            _buildSection(
              title: 'International Affairs',
              imageUrl: 'https://images.unsplash.com/photo-1541339907198-e08756fdad5d?auto=format&fit=crop&w=1000&q=80',
              items: [
                'Global University Partnerships',
                'Student & Faculty Exchange',
                'International Research Collaborations',
                'Dual Degree Programs',
                'Global Conferences & Workshops',
                'Scholarships for International Students',
              ],
            ),

           
            _buildSection(
              title: 'Alumni Network',
              imageUrl: 'https://images.unsplash.com/photo-1516321318423-4e15f3a08b97?auto=format&fit=crop&w=1000&q=80',
              items: [
                'UOL Alumni Association',
                'Global Alumni Network',
                'Career Support & Mentorship',
                'Alumni Events & Reunions',
                'Professional Development Programs',
                'Lifelong Learning Opportunities',
              ],
            ),

          
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF004D40), Color(0xFF00695C)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Get in Touch',
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
                          '1-KM Defence Road, Lahore, Pakistan',
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
                        '+92-42-111-865-865',
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
                        'info@uol.edu.pk',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF004D40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Visit Campus',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Apply Now',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

        
            Container(
              color: const Color(0xFF004D40),
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                '© 2025 University of Lahore. All rights reserved.',
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
        color: const Color(0xFF004D40).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF004D40).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004D40),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
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
            offset: const Offset(0, 2),
          ),
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
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
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
                                color: Color(0xFF004D40),
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