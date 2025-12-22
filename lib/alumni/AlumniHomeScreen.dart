import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AlumniHomeScreen extends StatefulWidget {
  final Map<String, dynamic> alumniData;

  const AlumniHomeScreen({super.key, required this.alumniData});

  @override
  State<AlumniHomeScreen> createState() => _AlumniHomeScreenState();
}

class _AlumniHomeScreenState extends State<AlumniHomeScreen> {
  String? _degreeImageUrl;
  bool _isLoadingDegree = false;
  bool _isUploading = false;

  final String _cloudName = 'dwcsrl6tl';
  final String _uploadPreset = 'images';
  late final Uri _cloudinaryUploadUrl = Uri.parse(
      "https://api.cloudinary.com/v1_1/$_cloudName/image/upload");


  Future<void> _fetchDegreeImageUrl() async {
    setState(() {
      _isLoadingDegree = true;
    });
    try {
      final String userEmail = widget.alumniData['email'];
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('alumni_degree_data')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        final data = result.docs.first.data() as Map<String, dynamic>;
        setState(() {
          _degreeImageUrl = data['degree_image_url'];
        });
      } else {
        setState(() {
          _degreeImageUrl = null; 
        });
      }
    } catch (e) {
    
      _degreeImageUrl = null;
    } finally {
      setState(() {
        _isLoadingDegree = false;
      });
    }
  }


  Future<String?> _uploadImage(File imageFile) async {
    try {
      final request = http.MultipartRequest('POST', _cloudinaryUploadUrl)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = utf8.decode(responseData);
        final jsonMap = json.decode(responseString);
        return jsonMap['secure_url']; 
      }
    } catch (e) {
  
    }
    return null;
  }

  
  Future<void> _updateDegreeImageUrl(String newImageUrl) async {
    try {
      final String userEmail = widget.alumniData['email'];
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('alumni_degree_data')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        final docRef = result.docs.first.reference;
        await docRef.update({'degree_image_url': newImageUrl});
        setState(() {
          _degreeImageUrl = newImageUrl;
        });
      }
    } catch (e) {
     
    }
  }

 
  Future<void> _changeDegreePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
        Navigator.of(context).pop(); 
      });

      final File imageFile = File(pickedFile.path);
      final String? newUrl = await _uploadImage(imageFile);

      if (newUrl != null) {
        await _updateDegreeImageUrl(newUrl);
      } else {
       
      }

      setState(() {
        _isUploading = false;
        
      });
    }
  }


  void _showAlumniInfoDialog(BuildContext context) {
    if (_isLoadingDegree) {
      showDialog(
        context: context,
        builder: (ctx) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Fetching Degree Info...'),
            ],
          ),
        ),
      );
      return;
    }


    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your Info'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(widget.alumniData['image_url']),
                ),
              ),
              const SizedBox(height: 20),
              _infoRow("Name", widget.alumniData['name']),
              _infoRow("Gmail", widget.alumniData['email']),
              _infoRow("Institute", widget.alumniData['institute']),
              _infoRow("Field", widget.alumniData['field']),
              _infoRow("BS CGPA", widget.alumniData['cgpa']),
              const Divider(height: 20),
              const Text('Degree Certificate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              if (_isUploading)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Uploading new degree...'),
                    ],
                  ),
                )
              else if (_degreeImageUrl != null)
                Column(
                  children: [
                    Image.network(_degreeImageUrl!, height: 200, fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Text('Error loading image', style: TextStyle(color: Colors.red))),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _changeDegreePicture,
                      icon: const Icon(Icons.edit),
                      label: const Text('Change Pic'),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    const Text('No degree image found for this email.'),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _changeDegreePicture,
                      icon: const Icon(Icons.upload),
                      label: const Text('Upload Degree Pic'),
                    ),
                  ],
                ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildHomeButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.38,
        height: 100,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.purple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(widget.alumniData['image_url']),
              ),
              const SizedBox(height: 20),
              Text(
                "Welcome, ${widget.alumniData['name']}",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "${widget.alumniData['field']} | ${widget.alumniData['institute']}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildHomeButton(
                    context,
                    icon: Icons.chat,
                    label: 'Chats',
                    onTap: () {
                      context.go('/alumni-chats', extra: widget.alumniData);
                    },
                  ),
                  _buildHomeButton(
                    context,
                    icon: Icons.event,
                    label: 'University Events',
                    onTap: () {
                      context.go('/all_uni_events', extra: widget.alumniData);
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildHomeButton(
                    context,
                    icon: Icons.info_outline,
                    label: 'Check Own Info',
                    onTap: () async {
                   
                      await _fetchDegreeImageUrl();
                      _showAlumniInfoDialog(context);
                    },
                  ),
                  _buildHomeButton(
                    context,
                    icon: Icons.logout,
                    label: 'Logout',
                    onTap: () {
                      context.go('/student_admin');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}