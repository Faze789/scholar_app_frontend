import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectAlumniScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const ConnectAlumniScreen({super.key, required this.studentData});

  @override
  State<ConnectAlumniScreen> createState() => _ConnectAlumniScreenState();
}

class _ConnectAlumniScreenState extends State<ConnectAlumniScreen> {
  List<Map<String, dynamic>> alumniList = [];
  bool isLoading = true;
  String searchQuery = '';

  final List<String> targetInstitutes = [
    'comsats',
    'cui',
    'comsat',
    'ned',
    'NED',
    'iqra',
    'Iqra',
    'bahria',
    'Bahria',
    'uol',
    'UOL',
    'nust',
    'Nust',
  ];

  @override
  void initState() {
    super.initState();
    fetchAlumniData();
  }

  Future<void> fetchAlumniData() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('alumni_data').get();

      final filteredAlumni = snapshot.docs
          .map((doc) => doc.data())
          .where((data) =>
              data['institute'] != null &&
              targetInstitutes
                  .contains(data['institute'].toString().toLowerCase()))
          .cast<Map<String, dynamic>>()
          .toList();

      setState(() {
        alumniList = filteredAlumni;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching alumni data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredAlumniList {
    if (searchQuery.isEmpty) return alumniList;
    return alumniList.where((alumni) {
      final name = alumni['name']?.toString().toLowerCase() ?? '';
      final field = alumni['field']?.toString().toLowerCase() ?? '';
      final institute = alumni['institute']?.toString().toLowerCase() ?? '';
      final query = searchQuery.toLowerCase();
      return name.contains(query) ||
          field.contains(query) ||
          institute.contains(query);
    }).toList();
  }

  Color _getInstituteColor(String? institute) {
    if (institute == null) return Colors.grey;
    final instituteLower = institute.toLowerCase();
    final colors = {
      'comsats': const Color(0xFF1E88E5),
      'comsat': const Color(0xFF1E88E5),
      'cui': const Color(0xFF43A047),
      'ned': const Color(0xFFE53935),
      'iqra': const Color(0xFF8E24AA),
      'bahria': const Color(0xFFF4511E),
      'uol': const Color(0xFF00897B),
      'nust': const Color(0xFFFFB300),
    };
    return colors[instituteLower] ?? const Color(0xFF5E35B1);
  }

  Widget _buildAlumniCard(Map<String, dynamic> data) {
    final instituteColor = _getInstituteColor(data['institute']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            context.go('/chat', extra: {
              'currentStudent': widget.studentData,
              'alumni': data,
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: instituteColor.withOpacity(0.3),
                          width: 2.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: instituteColor.withOpacity(0.1),
                        backgroundImage: data['image_url'] != null &&
                                data['image_url'].toString().isNotEmpty
                            ? NetworkImage(data['image_url'])
                            : null,
                        child: data['image_url'] == null ||
                                data['image_url'].toString().isEmpty
                            ? Text(
                                data['name']?.substring(0, 1).toUpperCase() ??
                                    'A',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: instituteColor,
                                ),
                              )
                            : null,
                        onBackgroundImageError: (_, __) {},
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF07C160),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                
                // Alumni info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data['name'] ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: instituteColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              data['institute'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: instituteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      Row(
                        children: [
                          Icon(
                            Icons.school_rounded,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              data['field'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      Row(
                        children: [
                          if (data['cgpa_bs'] != null &&
                              data['cgpa_bs'].toString() != 'N/A') ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'BS: ${data['cgpa_bs']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (data['cgpa_ms'] != null &&
                              data['cgpa_ms'].toString() != 'N/A') ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'MS: ${data['cgpa_ms']}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.purple.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Message button
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF07C160),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayList = filteredAlumniList;

    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2C2C2C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Connect with Alumni',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_rounded, color: Colors.white),
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
      body: Column(
        children: [
          // Search bar
          Container(
            color: const Color(0xFF2C2C2C),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3C3C3C),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Search alumni by name, field, or institute',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade500,
                    size: 22,
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                          onPressed: () => setState(() => searchQuery = ''),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // Alumni count
          if (!isLoading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Text(
                '${displayList.length} ${displayList.length == 1 ? 'Alumni' : 'Alumni'} Available',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Alumni list
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF07C160)),
                    ),
                  )
                : displayList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isEmpty
                                  ? 'No Alumni Found'
                                  : 'No Results',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              searchQuery.isEmpty
                                  ? 'Check back later for alumni connections'
                                  : 'Try a different search term',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          return _buildAlumniCard(displayList[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}