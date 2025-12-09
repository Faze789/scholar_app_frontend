import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlumniSignUp extends StatefulWidget {
  const AlumniSignUp({super.key});

  @override
  State<AlumniSignUp> createState() => _AlumniSignUpState();
}

class _AlumniSignUpState extends State<AlumniSignUp> {
  final _formKey = GlobalKey<FormState>();

  // User input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _registrationNoController = TextEditingController();
  final TextEditingController _instituteController = TextEditingController();
  final TextEditingController _fieldController = TextEditingController();
  final TextEditingController _cgpaController = TextEditingController();
  final TextEditingController _workExpController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  // Two image files
  File? _profileImageFile;
  File? _degreeImageFile;
  final picker = ImagePicker();

  bool _isLoading = false;
  String? _otpId;

  final String cloudName = 'dwcsrl6tl';
  final String uploadPreset = 'images';

  // OTP URLs
  String otpSendUrl = "https://sign-up-final-fyp-faze789s-projects.vercel.app/send-otp?x-vercel-protection-bypass=fazal111111111111111111111111111";
  String otpVerifyUrl = "https://sign-up-final-fyp-faze789s-projects.vercel.app/verify-otp?x-vercel-protection-bypass=fazal111111111111111111111111111";

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fatherNameController.dispose();
    _registrationNoController.dispose();
    _instituteController.dispose();
    _fieldController.dispose();
    _cgpaController.dispose();
    _workExpController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // ========== IMAGE PICKERS ==========
  Future<void> _pickProfileImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDegreeImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _degreeImageFile = File(pickedFile.path);
      });
    }
  }

  // ========== CLOUDINARY UPLOAD ==========
  Future<String?> _uploadToCloudinary(File imageFile) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    final res = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      final data = json.decode(res.body);
      return data['secure_url'] as String?;
    } else {
      debugPrint('Cloudinary upload failed: ${response.statusCode} ${res.body}');
      return null;
    }
  }

  // ========== OTP FUNCTIONS ==========
  Future<void> _sendOTP(String email) async {
    if (_profileImageFile == null) {
      _showSnackBar('Please upload profile picture', isError: true);
      return;
    }
    
    if (_degreeImageFile == null) {
      _showSnackBar('Please upload degree picture', isError: true);
      return;
    }

    try {
      final otpResponse = await http.post(
        Uri.parse(otpSendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      ).timeout(const Duration(seconds: 10));

      if (otpResponse.statusCode == 200) {
        final responseData = jsonDecode(otpResponse.body);
        if (responseData['success'] == true) {
          setState(() {
            _otpId = responseData['otpId'];
          });
          _showOTPDialog(email);
        } else {
          final err = responseData['error'] ?? 'Unknown error';
          _showSnackBar('Failed to send OTP: $err', isError: true);
        }
      } else {
        _showSnackBar('Failed to connect to server: ${otpResponse.statusCode}',
            isError: true);
      }
    } catch (e) {
      debugPrint('SEND OTP ERROR: $e');
      _showSnackBar('Error sending OTP', isError: true);
    }
  }

  Future<void> _verifyOTP(String email, String otp) async {
    if (_otpId == null) {
      _showSnackBar('OTP ID not found. Please try again.', isError: true);
      return;
    }

    try {
      final verifyResponse = await http.post(
        Uri.parse(otpVerifyUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'otpId': _otpId, 'otp': otp, 'email': email}),
      ).timeout(const Duration(seconds: 10));

      if (verifyResponse.statusCode == 200) {
        final responseData = jsonDecode(verifyResponse.body);
        if (responseData['success'] == true) {
          await _createFirebaseUserAndSave(email);
        } else {
          final err = responseData['error'] ?? 'Invalid OTP';
          _showSnackBar('OTP verification failed: $err', isError: true);
        }
      } else {
        _showSnackBar('Failed to verify OTP: ${verifyResponse.statusCode}',
            isError: true);
      }
    } catch (e) {
      debugPrint('VERIFY OTP ERROR: $e');
      _showSnackBar('Error verifying OTP', isError: true);
    }
  }

  // ========== FIREBASE USER CREATION ==========
  Future<void> _createFirebaseUserAndSave(String email) async {
    setState(() => _isLoading = true);

    try {
      // Upload both images
      final profileImageUrl = await _uploadToCloudinary(_profileImageFile!);
      final degreeImageUrl = await _uploadToCloudinary(_degreeImageFile!);
      
      if (profileImageUrl == null || degreeImageUrl == null) {
        throw Exception('Image upload failed');
      }

      // Create Firebase user
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      final user = credential.user;
      if (user == null) throw Exception('Firebase user creation failed');

      // Save data to alumni_data collection
      final alumniData = {
        'name': _nameController.text.trim(),
        'email': email,
        'father_name': _fatherNameController.text.trim(),
        'registration_no': _registrationNoController.text.trim(),
        'institute': _instituteController.text.trim(),
        'field': _fieldController.text.trim(),
        'cgpa': _cgpaController.text.trim(),
        'work_experience': _workExpController.text.trim(),
        'image_url': profileImageUrl,
        'degree_image_url': degreeImageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'user_id': user.uid, // Store user ID for reference
      };

      // Save degree verification data to separate collection
      final degreeData = {
        'email': email,
        'name': _nameController.text.trim(),
        'registration_no': _registrationNoController.text.trim(),
        'institute': _instituteController.text.trim(),
        'field': _fieldController.text.trim(),
        'degree_image_url': degreeImageUrl,
        'profile_image_url': profileImageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'user_id': user.uid,
        'verification_status': 'pending', // Can be: pending, verified, rejected
        'verified_by': null,
        'verification_date': null,
        'verification_notes': null,
      };

      // Save to both collections in a batch write for consistency
      final batch = FirebaseFirestore.instance.batch();
      
      // Document in alumni_data collection
      final alumniRef = FirebaseFirestore.instance
          .collection('alumni_data')
          .doc(user.uid);
      batch.set(alumniRef, alumniData);
      
      // Document in alumni_degree_data collection
      final degreeRef = FirebaseFirestore.instance
          .collection('alumni_degree_data')
          .doc(user.uid);
      batch.set(degreeRef, degreeData);
      
      // Commit the batch
      await batch.commit();

      _showSnackBar('Alumni Registered Successfully!', isError: false);

      // Send email verification
      try {
        await user.sendEmailVerification();
        _showSnackBar('Verification email sent', isError: false);
      } catch (_) {}

      if (mounted) context.go('/alumni-signin');
    } on FirebaseAuthException catch (e) {
      String msg = 'Registration failed';
      if (e.code == 'email-already-in-use') {
        msg = 'This email is already registered';
      } else if (e.code == 'weak-password') {
        msg = 'Password too weak';
      } else if (e.code == 'invalid-email') {
        msg = 'Invalid email';
      }
      _showSnackBar(msg, isError: true);
    } catch (e) {
      debugPrint('CREATE USER ERROR: $e');
      _showSnackBar('Registration failed: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ========== OTP DIALOG ==========
  void _showOTPDialog(String email) {
    _otpController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enter OTP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('We sent a code to $email'),
            const SizedBox(height: 16),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: 'Enter 6-digit OTP',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final otp = _otpController.text.trim();
              if (otp.length == 6) {
                Navigator.pop(context);
                _verifyOTP(email, otp);
              } else {
                _showSnackBar('Please enter a 6-digit OTP', isError: true);
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ========== UI BUILD ==========
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alumni Sign Up'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              const Text('Profile Picture', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: _pickProfileImage,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: _profileImageFile == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person, size: 40, color: Colors.blue),
                              SizedBox(height: 10),
                              Text('Upload Profile\nPicture', textAlign: TextAlign.center),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(_profileImageFile!, fit: BoxFit.cover),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Degree Picture Section
              const Text('Degree/Transcript Picture', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: _pickDegreeImage,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: _degreeImageFile == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.school, size: 40, color: Colors.blue),
                              SizedBox(height: 10),
                              Text('Upload Degree\nPicture', textAlign: TextAlign.center),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(_degreeImageFile!, fit: BoxFit.cover),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Note: Your degree picture will be stored securely in a separate verification database.',
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Personal Information Section
              const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Father's Name Field
              TextFormField(
                controller: _fatherNameController,
                decoration: const InputDecoration(
                  labelText: "Father's Name *",
                  prefixIcon: Icon(Icons.family_restroom),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter father\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Registration No Field
              TextFormField(
                controller: _registrationNoController,
                decoration: const InputDecoration(
                  labelText: 'Registration Number *',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter registration number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password *',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Academic Information Section
              const Text('Academic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // University/Institute Field
              TextFormField(
                controller: _instituteController,
                decoration: const InputDecoration(
                  labelText: 'University/Institute *',
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your university/institute';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Field of Study
              TextFormField(
                controller: _fieldController,
                decoration: const InputDecoration(
                  labelText: 'Field of Study *',
                  prefixIcon: Icon(Icons.book),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your field of study';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // CGPA
              TextFormField(
                controller: _cgpaController,
                decoration: const InputDecoration(
                  labelText: 'CGPA *',
                  prefixIcon: Icon(Icons.grade),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter CGPA';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Professional Information
              const Text('Professional Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Work Experience
              TextFormField(
                controller: _workExpController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Work Experience *',
                  prefixIcon: Icon(Icons.work),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter work experience';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () {
                    if (_formKey.currentState!.validate()) {
                      _sendOTP(_emailController.text.trim());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Login Link
              Center(
                child: TextButton(
                  onPressed: () {
                    context.go('/alumni-signin');
                  },
                  child: const Text(
                    'Already have an account? Sign In',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}