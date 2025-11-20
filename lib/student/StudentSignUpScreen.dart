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
  bool isBS = false;
  bool isMS = false;
  bool isPhD = false;
  bool isOALevel = false;
  File? _profileImage;
  List<String> selectedFields = [];
  Map<String, dynamic>? apiResponseData;

  String _selectedDegreeLevel = 'bachelors'; 

  final List<String> fieldsOfStudy = [
    "Computer Science",
    "Software Engineering",
    "Electrical Engineering",
    "Mechanical Engineering",
    "Civil Engineering",
    "Business Administration",
    "Data Science",
    "Artificial Intelligence",
    "Medicine",
    "Architecture"
  ];

  static const String otpServerUrl = 'http://192.168.100.149:3001';

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

    final url = Uri.parse("http://35.174.6.20:5000/predict");
    
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
    if (!_formKey.currentState!.validate()) return;
    
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

    // Add CGPA fields based on degree level
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
                        onChanged: (v) => setState(() => isOALevel = v),
                      ),
                    ],
                  ),
                  if (isOALevel) ...[
                    _buildTextField(
                      label: 'O Level Marks (out of 900)',
                      keyboardType: TextInputType.number,
                      onSaved: (v) => oLevelMarks = v!,
                    ),
                    _buildTextField(
                      label: 'A Level Marks (out of 1200)',
                      keyboardType: TextInputType.number,
                      onSaved: (v) => aLevelMarks = v!,
                    ),
                  ] else ...[
                    _buildTextField(
                      label: 'Matric Marks (out of 1100)',
                      keyboardType: TextInputType.number,
                      onSaved: (v) => matricMarks = v!,
                    ),
                    _buildTextField(
                      label: 'FSC Marks (out of 1100)',
                      keyboardType: TextInputType.number,
                      onSaved: (v) => fscMarks = v!,
                    ),
                  ],
                  _buildTextField(
                    label: 'NTS Marks (out of 100)',
                    keyboardType: TextInputType.number,
                    onSaved: (v) => ntsMarks = v!,
                  ),
                  _buildTextField(
                    label: 'NET Marks (out of 200)',
                    keyboardType: TextInputType.number,
                    onSaved: (v) => netMarks = v!,
                  ),
                  _buildTextField(
                    label: 'ECAT Marks (out of 400)',
                    keyboardType: TextInputType.number,
                    onSaved: (v) => ecatMarks = v!,
                  ),
                  _buildTextField(
                    label: 'NED Entry Test Marks (out of 100)',
                    keyboardType: TextInputType.number,
                    onSaved: (v) => nedMarks = v!,
                    helperText: 'Required for NED University admission prediction',
                  ),
                  
                  // Conditional CGPA fields based on degree level
                  if (_selectedDegreeLevel == 'masters' || _selectedDegreeLevel == 'phd')
                    _buildTextField(
                      label: 'Bachelor\'s CGPA',
                      keyboardType: TextInputType.number,
                      onSaved: (v) => cgpa = v!,
                    ),
                  
                  if (_selectedDegreeLevel == 'phd')
                    _buildTextField(
                      label: 'Master\'s CGPA',
                      keyboardType: TextInputType.number,
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
                  
                  // Field selection
                  if (_selectedDegreeLevel.isNotEmpty)
                    Column(
                      children: fieldsOfStudy.map((field) {
                        return CheckboxListTile(
                          title: Text(field, style: const TextStyle(color: Colors.white)),
                          value: selectedFields.contains(field),
                          onChanged: (v) => setState(() {
                            v! ? selectedFields.add(field) : selectedFields.remove(field);
                          }),
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
}