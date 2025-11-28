import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentSignUpScreen extends StatefulWidget {
  const StudentSignUpScreen({super.key});

  @override
  State<StudentSignUpScreen> createState() => _StudentSignUpScreenState();
}

class _StudentSignUpScreenState extends State<StudentSignUpScreen> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String name = '';
  String fatherName = '';
  String matricMarks = '';
  String fscMarks = '';
  String oLevelMarks = '';
  String aLevelMarks = '';
  String ntsMarks = '';
  String netMarks = '';
  String ecatMarks = '';
  String nedMarks = '';
  String cgpa = '';
  String mastersCgpa = ''; 
  String email = '';
  String password = '';
  bool isOALevel = false;
  File? _profileImage;
  List<String> selectedFields = [];
  Map<String, dynamic>? apiResponseData;
  String _selectedDegreeLevel = 'bachelors'; 

  final List<String> fieldsOfStudy = [
    "Computer Science", "Software Engineering", "Electrical Engineering",
    "Mechanical Engineering", "Civil Engineering", "Business Administration",
    "Data Science", "Artificial Intelligence", "Medicine", "Architecture"
  ];

  static const String otpServerUrl = 'http://192.168.100.121:3001';

  // Controllers for marks fields
  final TextEditingController _matricController = TextEditingController();
  final TextEditingController _fscController = TextEditingController();
  final TextEditingController _oLevelController = TextEditingController();
  final TextEditingController _aLevelController = TextEditingController();
  final TextEditingController _ntsController = TextEditingController();
  final TextEditingController _netController = TextEditingController();
  final TextEditingController _ecatController = TextEditingController();
  final TextEditingController _nedController = TextEditingController();
  final TextEditingController _cgpaController = TextEditingController();
  final TextEditingController _mastersCgpaController = TextEditingController();

  // Error states for marks fields
  bool _matricError = false;
  bool _fscError = false;
  bool _oLevelError = false;
  bool _aLevelError = false;
  bool _ntsError = false;
  bool _netError = false;
  bool _ecatError = false;
  bool _nedError = false;
  bool _cgpaError = false;
  bool _mastersCgpaError = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to update error states in real-time
    _matricController.addListener(() => _validateField(_matricController, 1100, (error) => setState(() => _matricError = error)));
    _fscController.addListener(() => _validateField(_fscController, 1100, (error) => setState(() => _fscError = error)));
    _oLevelController.addListener(() => _validateField(_oLevelController, 900, (error) => setState(() => _oLevelError = error)));
    _aLevelController.addListener(() => _validateField(_aLevelController, 1200, (error) => setState(() => _aLevelError = error)));
    _ntsController.addListener(() => _validateField(_ntsController, 100, (error) => setState(() => _ntsError = error)));
    _netController.addListener(() => _validateField(_netController, 200, (error) => setState(() => _netError = error)));
    _ecatController.addListener(() => _validateField(_ecatController, 400, (error) => setState(() => _ecatError = error)));
    _nedController.addListener(() => _validateField(_nedController, 100, (error) => setState(() => _nedError = error)));
    _cgpaController.addListener(() => _validateField(_cgpaController, 4.0, (error) => setState(() => _cgpaError = error)));
    _mastersCgpaController.addListener(() => _validateField(_mastersCgpaController, 4.0, (error) => setState(() => _mastersCgpaError = error)));
  }

  @override
  void dispose() {
    // Dispose controllers
    _matricController.dispose();
    _fscController.dispose();
    _oLevelController.dispose();
    _aLevelController.dispose();
    _ntsController.dispose();
    _netController.dispose();
    _ecatController.dispose();
    _nedController.dispose();
    _cgpaController.dispose();
    _mastersCgpaController.dispose();
    super.dispose();
  }

  // Validate a single field and update error state
  void _validateField(TextEditingController controller, double maxMarks, Function(bool) setError) {
    final text = controller.text;
    if (text.isEmpty) {
      setError(false);
      return;
    }
    
    final value = double.tryParse(text);
    if (value == null || value < 0 || value > maxMarks) {
      setError(true);
    } else {
      setError(false);
    }
  }

  // Validate all marks fields
  bool _validateMarksFields() {
    // Reset all error states first
    setState(() {
      _matricError = false;
      _fscError = false;
      _oLevelError = false;
      _aLevelError = false;
      _ntsError = false;
      _netError = false;
      _ecatError = false;
      _nedError = false;
      _cgpaError = false;
      _mastersCgpaError = false;
    });
    
    bool hasError = false;
    
    // Validate Matric/FSC or O/A Level
    if (!isOALevel) {
      if (!_validateFieldWithController(_matricController, 1100)) {
        setState(() => _matricError = true);
        hasError = true;
      }
      if (!_validateFieldWithController(_fscController, 1100)) {
        setState(() => _fscError = true);
        hasError = true;
      }
    } else {
      if (!_validateFieldWithController(_oLevelController, 900)) {
        setState(() => _oLevelError = true);
        hasError = true;
      }
      if (!_validateFieldWithController(_aLevelController, 1200)) {
        setState(() => _aLevelError = true);
        hasError = true;
      }
    }
    
    // Validate test scores
    if (!_validateFieldWithController(_ntsController, 100)) {
      setState(() => _ntsError = true);
      hasError = true;
    }
    if (!_validateFieldWithController(_netController, 200)) {
      setState(() => _netError = true);
      hasError = true;
    }
    if (!_validateFieldWithController(_ecatController, 400)) {
      setState(() => _ecatError = true);
      hasError = true;
    }
    if (!_validateFieldWithController(_nedController, 100)) {
      setState(() => _nedError = true);
      hasError = true;
    }
    
    // Validate CGPA if applicable
    if (_selectedDegreeLevel == 'masters' || _selectedDegreeLevel == 'phd') {
      if (!_validateFieldWithController(_cgpaController, 4.0)) {
        setState(() => _cgpaError = true);
        hasError = true;
      }
    }
    
    if (_selectedDegreeLevel == 'phd') {
      if (!_validateFieldWithController(_mastersCgpaController, 4.0)) {
        setState(() => _mastersCgpaError = true);
        hasError = true;
      }
    }
    
    return !hasError;
  }

  // Helper to validate a field using its controller
  bool _validateFieldWithController(TextEditingController controller, double maxMarks) {
    final text = controller.text;
    if (text.isEmpty) return false; // Empty field is invalid
    
    final value = double.tryParse(text);
    return value != null && value >= 0 && value <= maxMarks;
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadToCloudinary(File file) async {
    const cloudName = 'dwcsrl6tl';
    const uploadPreset = 'images';
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final response = await request.send();
      final resStr = await response.stream.bytesToString();
      final data = json.decode(resStr);

      if (response.statusCode == 200) {
        print('Image uploaded to Cloudinary: ${data['secure_url']}');
        return data['secure_url'];
      } else {
        print('Cloudinary Upload Failed: ${data['error']}');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  Future<bool> _callPredictionAPI() async {
    try {
      double matric, fsc;
      
      if (isOALevel) {
        matric = (double.tryParse(oLevelMarks) ?? 0) / 900 * 1100;
        fsc = (double.tryParse(aLevelMarks) ?? 0) / 1200 * 1100;
        print('🔄 Converting O/A Level marks for API: O-Level($oLevelMarks/900) -> Matric($matric/1100), A-Level($aLevelMarks/1200) -> FSC($fsc/1100)');
      } else {
        matric = double.tryParse(matricMarks) ?? 0;
        fsc = double.tryParse(fscMarks) ?? 0;
        print('🔄 Using original Matric/FSC marks for API: Matric($matricMarks), FSC($fscMarks)');
      }
      
      double ecat = double.tryParse(ecatMarks) ?? 0;
      double nts = double.tryParse(ntsMarks) ?? 0;
      double net = double.tryParse(netMarks) ?? 0;
      double ned = double.tryParse(nedMarks) ?? 0;

      String program = selectedFields.isNotEmpty ? selectedFields.first : _selectedDegreeLevel;

      final url = Uri.parse("http://192.168.100.121:5000/predict");
      
      print('Making API call to: $url');
      
      Map<String, dynamic> requestData = {
        "matric_marks": matric,
        "fsc_marks": fsc,
        "nts_marks": nts,
        "net_marks": net,
        "ecat_marks": ecat,
        "ned_test_marks": ned,
        "program": program,
      };
      
      if (_selectedDegreeLevel == 'masters' || _selectedDegreeLevel == 'phd') {
        requestData['bachelors_cgpa'] = double.tryParse(cgpa) ?? 0;
      }
      
      if (_selectedDegreeLevel == 'phd') {
        requestData['masters_cgpa'] = double.tryParse(mastersCgpa) ?? 0;
      }
      
      print('Request data: ${json.encode(requestData)}');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestData),
      ).timeout(const Duration(seconds: 30));

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        String processedResponse = response.body.replaceAll('NaN', 'null');
        final result = json.decode(processedResponse);
        
        if (result['universities'] == null || result['universities'] is! List) {
          print('Invalid API response structure');
          _showErrorDialog("Invalid API response structure");
          return false;
        }

        print(' API call successful, universities found: ${result['universities'].length}');
        
        setState(() {
          apiResponseData = result;
        });
        return true;
      } else {
        print(' API Error: ${response.statusCode}');
        _showErrorDialog("API Error: ${response.statusCode}\n${response.body}");
        return false;
      }
    } catch (e) {
      print(' API call failed: $e');
      _showErrorDialog("API call failed: $e");
      return false;
    }
  }

  Future<void> _saveStudentData() async {
    // First validate the form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Then validate marks fields
    if (!_validateMarksFields()) {
      _showErrorDialog("Please correct the marks fields highlighted in red");
      return;
    }
    
    if (_selectedDegreeLevel.isEmpty) {
      _showErrorDialog("Please select a degree level");
      return;
    }

    _formKey.currentState!.save();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Processing..."),
          ],
        ),
      ),
    );

    try {
      print('Starting registration process...');

      String? imageUrl;
      if (_profileImage != null) {
        print('🔄 Uploading image to Cloudinary...');
        imageUrl = await _uploadToCloudinary(_profileImage!);
        if (imageUrl == null) {
          Navigator.pop(context);
          _showErrorDialog("Failed to upload image to Cloudinary.");
          return;
        }
        print(' Image uploaded successfully: $imageUrl');
      }

      print('Calling prediction API...');
      final apiSuccess = await _callPredictionAPI();
      if (!apiSuccess) {
        Navigator.pop(context);
        return;
      }
      print('API call successful');

      Navigator.pop(context);

      print('Sending OTP...');
      final otpSent = await _sendOtp();
      if (!otpSent) {
        return;
      }

      final verified = await _showOtpDialog();
      if (!verified) {
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
            Text("Saving data..."),
            ],
          ),
        ),
      );

      print('Creating Firebase user...');
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("Firebase user creation failed");
      }
      print('Firebase user created: ${user.uid}');

      print('Preparing student data...');
      final studentData = _prepareStudentData(imageUrl);
      print('Student data prepared');

      print('Saving to Firestore...');
      await _firestore.collection('students_data').doc(user.uid).set(studentData)
        .timeout(const Duration(seconds: 30));
      print('Data saved to Firestore with UID: ${user.uid}');

      print('Verifying saved data...');
      final savedDoc = await _firestore.collection('students_data').doc(user.uid).get()
        .timeout(const Duration(seconds: 15));

      if (!savedDoc.exists) {
        throw Exception("Document not found after saving");
      }
      print('✅ Data verification successful');

      Navigator.pop(context);
      _showSuccessDialog();

    } catch (e) {
      print('Registration failed: $e');
      Navigator.pop(context);
      _showErrorDialog("Registration failed: $e");
    }
  }

  String? _otpId;

  Future<bool> _sendOtp() async {
    try {
      final response = await http.post(
        Uri.parse('$otpServerUrl/send-otp'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": email}),
      ).timeout(const Duration(seconds: 10));

      print('Send OTP Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _otpId = data['otpId'];
          print('OTP sent successfully, otpId: $_otpId');
          return true;
        }
      }

      _showErrorDialog("Failed to send OTP: ${response.body}");
      return false;
    } catch (e) {
      print(' Send OTP failed: $e');
      _showErrorDialog("Failed to send OTP: $e");
      return false;
    }
  }

  Future<bool> _verifyOtp(String enteredOtp) async {
    try {
      final response = await http.post(
        Uri.parse('$otpServerUrl/verify-otp'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "otpId": _otpId,
          "otp": enteredOtp,
          "email": email,
        }),
      ).timeout(const Duration(seconds: 10));

      print('Verify OTP Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          print(' OTP verified successfully');
          return true;
        }
      }

      _showErrorDialog("OTP verification failed: ${json.decode(response.body)['error'] ?? response.body}");
      return false;
    } catch (e) {
      print(' Verify OTP failed: $e');
      _showErrorDialog("OTP verification failed: $e");
      return false;
    }
  }

  Future<bool> _showOtpDialog() async {
    final otpController = TextEditingController();
    bool isVerifying = false;

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Verify OTP"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Enter the OTP sent to your email."),
                  const SizedBox(height: 10),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'OTP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (isVerifying)
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isVerifying ? null : () => Navigator.pop(ctx, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isVerifying
                      ? null
                      : () async {
                          if (otpController.text.isEmpty) {
                            _showErrorDialog("Please enter OTP");
                            return;
                          }
                          setDialogState(() => isVerifying = true);
                          final verified = await _verifyOtp(otpController.text);
                          setDialogState(() => isVerifying = false);
                          if (verified) {
                            Navigator.pop(ctx, true);
                          }
                        },
                  child: const Text("Verify"),
                ),
              ],
            );
          },
        );
      },
    ) ?? false;
  }

  Map<String, dynamic> _prepareStudentData(String? imageUrl) {
    Map<String, dynamic> data = {
      'student_name': name,
      'father_name': fatherName,
      'email': email,
      'password': password, 
      'profile_image_url': imageUrl,
      'submission_date': FieldValue.serverTimestamp(),
      'is_o_a_level': isOALevel,
      'program_level': _selectedDegreeLevel, 
      'selected_fields': selectedFields,
    };

    if (isOALevel) {
      data.addAll({
        'o_level_marks': double.tryParse(oLevelMarks) ?? 0,
        'a_level_marks': double.tryParse(aLevelMarks) ?? 0,
        'matric_marks': null,  
        'fsc_marks': null,     
      });
      
      print('O/A Level Student - Saving: O-Level=$oLevelMarks, A-Level=$aLevelMarks, Matric=null, FSC=null');
    } else {
      data.addAll({
        'matric_marks': double.tryParse(matricMarks) ?? 0,
        'fsc_marks': double.tryParse(fscMarks) ?? 0,
        'o_level_marks': null,    
        'a_level_marks': null,   
      });
      
      print(' Matric/FSC Student - Saving: Matric=$matricMarks, FSC=$fscMarks, O-Level=null, A-Level=null');
    }

    data.addAll({
      'nts_marks': double.tryParse(ntsMarks) ?? 0,
      'net_marks': double.tryParse(netMarks) ?? 0,
      'ecat_marks': double.tryParse(ecatMarks) ?? 0,
      'ned_marks': double.tryParse(nedMarks) ?? 0,
    });

    if (_selectedDegreeLevel == 'masters' || _selectedDegreeLevel == 'phd') {
      data['bachelors_cgpa'] = double.tryParse(cgpa) ?? 0;
    }
    
    if (_selectedDegreeLevel == 'phd') {
      data['masters_cgpa'] = double.tryParse(mastersCgpa) ?? 0;
    }

    if (apiResponseData != null && apiResponseData!['universities'] is List) {
      try {
        List<dynamic> universities = apiResponseData!['universities'];
        print('📊 Processing ${universities.length} universities data...');
        
        for (var uni in universities) {
          if (uni == null) continue;
          
          String uniId = (uni['id']?.toString() ?? 'unknown').toLowerCase();
          String uniName = uni['name'] ?? 'Unknown';
          
          print('🏫 Processing data for: $uniName (ID: $uniId)');
          
          data.addAll({
            '${uniId}_name': uniName,
            '${uniId}_predicted_2026_aggregate': uni['predicted_2026_cutoff'],
            '${uniId}_student_aggregate': uni['user_aggregate'],
            '${uniId}_last_year_aggregate': uni['last_actual_cutoff'],
            '${uniId}_last_actual_year': uni['last_actual_year'],
            '${uniId}_admission_chance': uni['admission_chance'],
            '${uniId}_admitted': uni['admitted'],
          });

          if (uni['criteria'] != null) {
            Map<String, dynamic> criteria = uni['criteria'];
            data.addAll({
              '${uniId}_test_used': criteria['test_used'],
            });

            if (criteria['weights'] != null) {
              Map<String, dynamic> weights = criteria['weights'];
              data.addAll({
                '${uniId}_criteria_weights': weights,
              });
            }

            if (criteria['totals'] != null) {
              Map<String, dynamic> totals = criteria['totals'];
              data.addAll({
                '${uniId}_criteria_totals': totals,
              });
            }
          }

          switch (uniId) {
            case 'iiui':
              print(' IIUI data processed successfully');
              data.addAll({
                'iiui_processed': true,
                'iiui_processing_date': FieldValue.serverTimestamp(),
              });
              break;
              
            case 'ned':
              print(' NED data processed successfully');
              break;
              
            case 'nust':
              print(' NUST data processed successfully');
              break;
              
            case 'comsats':
              print(' COMSATS data processed successfully');
              break;
              
            case 'fast':
              print(' FAST data processed successfully');
              break;
              
            case 'uet':
              print(' UET data processed successfully');
              break;
              
            case 'bahria':
              print(' Bahria data processed successfully');
              break;
              
            case 'iqra':
              print(' Iqra data processed successfully');
              break;
              
            default:
              print(' $uniName data processed successfully');
          }
        }

        data.addAll({
          'total_universities_processed': universities.length,
          'universities_list': universities.map((uni) => {
            'id': uni['id'],
            'name': uni['name'],
            'admitted': uni['admitted'],
            'admission_chance': uni['admission_chance'],
          }).toList(),
        });

        print(' All university data processed successfully');
        
      } catch (e) {
        print(' Warning: Error processing API response data: $e');
        data.addAll({
          'api_processing_error': e.toString(),
          'api_processing_timestamp': FieldValue.serverTimestamp(),
        });
      }
    } else {
      print('No API response data available');
      data['api_data_available'] = false;
    }

    print(' FINAL DATA STRUCTURE:');
    print('is_o_a_level: ${data['is_o_a_level']}');
    print('matric_marks: ${data['matric_marks']}');
    print('fsc_marks: ${data['fsc_marks']}');
    print('o_level_marks: ${data['o_level_marks']}');
    print('a_level_marks: ${data['a_level_marks']}');
    print('program_level: ${data['program_level']}');

    return data;
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Registration Successful"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("$name has been registered successfully!"),
            const SizedBox(height: 10),
            if (apiResponseData != null && apiResponseData!['universities'] != null) ...[
              Text("${(apiResponseData!['universities'] as List).length} universities analyzed"),
              const SizedBox(height: 5),
              ...((apiResponseData!['universities'] as List)
                  .where((uni) => uni['admitted'] == true)
                  .map((uni) => Text(" Admitted: ${uni['name']}", 
                      style: const TextStyle(color: Colors.green, fontSize: 12)))
                  .toList()),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/student_login');
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Error"),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
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
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(Icons.camera_alt, size: 40, color: Colors.deepPurple)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Student Registration',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(label: 'Full Name', onSaved: (v) => name = v!),
                  _buildTextField(label: 'Father Name', onSaved: (v) => fatherName = v!),
                  
                  const SizedBox(height: 20),
                  const Text(
                    'Select Degree Level:',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildDegreeOption('Bachelors', 'bachelors'),
                        _buildDegreeOption('Masters', 'masters'),
                        _buildDegreeOption('PhD', 'phd'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      const Text("O/A Level?", style: TextStyle(color: Colors.white)),
                      Switch(
                        value: isOALevel,
                        onChanged: (v) => setState(() {
                          isOALevel = v;
                          // Clear error states when switching between O/A Level and Matric/FSC
                          if (v) {
                            _matricController.clear();
                            _fscController.clear();
                            _matricError = false;
                            _fscError = false;
                          } else {
                            _oLevelController.clear();
                            _aLevelController.clear();
                            _oLevelError = false;
                            _aLevelError = false;
                          }
                        }),
                      ),
                    ],
                  ),
                  if (isOALevel) ...[
                    _buildMarksField(
                      label: 'O Level Marks (out of 900)',
                      controller: _oLevelController,
                      error: _oLevelError,
                      maxMarks: 900,
                      onSaved: (v) => oLevelMarks = v!,
                    ),
                    _buildMarksField(
                      label: 'A Level Marks (out of 1200)',
                      controller: _aLevelController,
                      error: _aLevelError,
                      maxMarks: 1200,
                      onSaved: (v) => aLevelMarks = v!,
                    ),
                  ] else ...[
                    _buildMarksField(
                      label: 'Matric Marks (out of 1100)',
                      controller: _matricController,
                      error: _matricError,
                      maxMarks: 1100,
                      onSaved: (v) => matricMarks = v!,
                    ),
                    _buildMarksField(
                      label: 'FSC Marks (out of 1100)',
                      controller: _fscController,
                      error: _fscError,
                      maxMarks: 1100,
                      onSaved: (v) => fscMarks = v!,
                    ),
                  ],
                  _buildMarksField(
                    label: 'NTS Marks (out of 100)',
                    controller: _ntsController,
                    error: _ntsError,
                    maxMarks: 100,
                    onSaved: (v) => ntsMarks = v!,
                  ),
                  _buildMarksField(
                    label: 'NET Marks (out of 200)',
                    controller: _netController,
                    error: _netError,
                    maxMarks: 200,
                    onSaved: (v) => netMarks = v!,
                  ),
                  _buildMarksField(
                    label: 'ECAT Marks (out of 400)',
                    controller: _ecatController,
                    error: _ecatError,
                    maxMarks: 400,
                    onSaved: (v) => ecatMarks = v!,
                  ),
                  _buildMarksField(
                    label: 'NED Entry Test Marks (out of 100)',
                    controller: _nedController,
                    error: _nedError,
                    maxMarks: 100,
                    onSaved: (v) => nedMarks = v!,
                    helperText: 'Required for NED University admission prediction',
                  ),
                  
                  if (_selectedDegreeLevel == 'masters' || _selectedDegreeLevel == 'phd')
                    _buildMarksField(
                      label: 'Bachelor\'s CGPA (out of 4.0)',
                      controller: _cgpaController,
                      error: _cgpaError,
                      maxMarks: 4.0,
                      onSaved: (v) => cgpa = v!,
                    ),
                  
                  if (_selectedDegreeLevel == 'phd')
                    _buildMarksField(
                      label: 'Master\'s CGPA (out of 4.0)',
                      controller: _mastersCgpaController,
                      error: _mastersCgpaError,
                      maxMarks: 4.0,
                      onSaved: (v) => mastersCgpa = v!,
                    ),
                  
                  _buildTextField(
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    onSaved: (v) => email = v!,
                    validator: (v) => v!.contains('@') ? null : 'Enter valid email',
                  ),
                  _buildTextField(
                    label: 'Password',
                    obscureText: true,
                    onSaved: (v) => password = v!,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter a password';
                      if (v.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  
                  if (_selectedDegreeLevel.isNotEmpty)
                   Column(
                     children: fieldsOfStudy.map((field) {
                       bool isSelected = selectedFields.contains(field);
                       bool disableOther = selectedFields.isNotEmpty && !isSelected;

                       return CheckboxListTile(
                         title: Text(field, style: const TextStyle(color: Colors.white)),
                         value: isSelected,
                         onChanged: disableOther
                             ? null  
                             : (v) {
                                 setState(() {
                                   if (v == true) {
                                     selectedFields = [field]; 
                                   } else {
                                     selectedFields.remove(field);
                                   }
                                 });
                               },
                       );
                     }).toList(),
                   ),
                  
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveStudentData,
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDegreeOption(String title, String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDegreeLevel = value;
          selectedFields.clear(); 
          // Clear CGPA fields when changing degree level
          if (value != 'masters' && value != 'phd') {
            _cgpaController.clear();
            _cgpaError = false;
          }
          if (value != 'phd') {
            _mastersCgpaController.clear();
            _mastersCgpaError = false;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _selectedDegreeLevel == value 
              ? Colors.white 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: _selectedDegreeLevel == value 
                ? Colors.blue.shade900 
                : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    String? helperText,
  }) {
    return Padding( 
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          helperStyle: const TextStyle(color: Colors.white70),
          labelStyle: const TextStyle(color: Colors.white),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white70),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        validator: validator ?? (v) => v!.isEmpty ? 'Required field' : null,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildMarksField({
    required String label,
    required TextEditingController controller,
    required bool error,
    required double maxMarks,
    required FormFieldSetter<String> onSaved,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: error ? Colors.red : Colors.white),
        keyboardType: TextInputType.numberWithOptions(decimal: maxMarks <= 4.0),
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          helperStyle: const TextStyle(color: Colors.white70),
          labelStyle: TextStyle(color: error ? Colors.red : Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: error ? Colors.red : Colors.white70),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: error ? Colors.red : Colors.white),
          ),
          errorText: error ? 'Must be between 0 and $maxMarks' : null,
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Required field';
          final value = double.tryParse(v);
          if (value == null) return 'Please enter a valid number';
          if (value < 0 || value > maxMarks) return 'Must be between 0 and $maxMarks';
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }
}