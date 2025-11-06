import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// alumni_signup.dart

class AlumniSignUp extends StatefulWidget {
  const AlumniSignUp({super.key});

  @override
  State<AlumniSignUp> createState() => _AlumniSignUpState();
}

class _AlumniSignUpState extends State<AlumniSignUp> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _gmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bsCgpaController = TextEditingController();
  final TextEditingController _msCgpaController = TextEditingController();
  final TextEditingController _instituteController = TextEditingController();
  final TextEditingController _fieldController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  File? _imageFile;
  final picker = ImagePicker();

  bool _isLoading = false;
  String? _otpId;

  
  final String cloudName = 'dwcsrl6tl';
  final String uploadPreset = 'images';

 
  String otpServerBaseUrl = 'http://192.168.100.121:3001';

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

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

  Future<void> _sendOTP(String email) async {
    try {
      final otpResponse = await http.post(
        Uri.parse('$otpServerBaseUrl/send-otp'),
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send OTP: $err')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to server: ${otpResponse.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('SEND OTP ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error sending OTP')));
    }
  }

  Future<void> _verifyOTP(String email, String otp) async {
    if (_otpId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP ID not found. Please try again.')),
      );
      return;
    }

    try {
      final verifyResponse = await http.post(
        Uri.parse('$otpServerBaseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'otpId': _otpId, 'otp': otp, 'email': email}),
      ).timeout(const Duration(seconds: 10));

      if (verifyResponse.statusCode == 200) {
        final responseData = jsonDecode(verifyResponse.body);
        if (responseData['success'] == true) {
    
          await _createFirebaseUserAndSave(email);
        } else {
          final err = responseData['error'] ?? 'Invalid OTP';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('OTP verification failed: $err')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to verify OTP: ${verifyResponse.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('VERIFY OTP ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error verifying OTP')));
    }
  }

  Future<void> _createFirebaseUserAndSave(String email) async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image')));
      return;
    }

    setState(() => _isLoading = true);

    try {

      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      final user = credential.user;
      if (user == null) throw Exception('Firebase user creation failed');

  
      final imageUrl = await _uploadToCloudinary(_imageFile!);
      if (imageUrl == null) {
        throw Exception('Image upload failed');
      }

     
      final data = {
        'name': _nameController.text.trim(),
        'gmail': email,
        'cgpa_bs': _bsCgpaController.text.trim(),
        'cgpa_ms': _msCgpaController.text.trim(),
         'password': _passwordController.text.trim(),
        'institute': _instituteController.text.trim(),
        'field': _fieldController.text.trim(),
        'image_url': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('alumni_data').doc(user.uid).set(data);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alumni Registered Successfully!')));

   
      try {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification email sent')));
      } catch (_) {}

     
      if (mounted) context.go('/alumni-signin');
    } on FirebaseAuthException catch (e) {
      String msg = 'Registration failed';
      if (e.code == 'email-already-in-use') msg = 'This email is already registered';
      if (e.code == 'weak-password') msg = 'Password too weak';
      if (e.code == 'invalid-email') msg = 'Invalid email';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      debugPrint('CREATE USER ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showOTPDialog(String email) {
    _otpController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter OTP'),
        content: TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter 6-digit OTP'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final otp = _otpController.text.trim();
              if (otp.length == 6) {
                Navigator.pop(context);
                _verifyOTP(email, otp);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a 6-digit OTP')));
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> _registerAlumni() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields and select an image')));
      return;
    }

    final String email = _gmailController.text.trim();

    setState(() {
      _isLoading = true;
    });

    await _sendOTP(email);

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.purple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'Alumni Sign Up',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: _imageFile == null
                            ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(_nameController, 'Name'),
                    const SizedBox(height: 15),
                    _buildTextField(_gmailController, 'Gmail', keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 15),
                    _buildTextField(_passwordController, 'Password', obscureText: true),
                    const SizedBox(height: 15),
                    _buildTextField(_bsCgpaController, 'CGPA in BS', keyboardType: TextInputType.number),
                    const SizedBox(height: 15),
                    _buildTextField(_msCgpaController, 'CGPA in MS', keyboardType: TextInputType.number),
                    const SizedBox(height: 15),
                    _buildTextField(_instituteController, 'Graduated From'),
                    const SizedBox(height: 15),
                    _buildTextField(_fieldController, 'Field of Study'),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : ElevatedButton(
                            onPressed: _registerAlumni,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.purple,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
