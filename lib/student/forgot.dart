import 'dart:convert';
import 'reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  String? otpId;
  bool isLoading = false;
  bool otpSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnackBar('Please enter a valid email');
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://signupnodejs.vercel.app/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        otpId = data['otpId'];
        setState(() => otpSent = true);
        _showSnackBar('OTP sent successfully');
      } else {
        _showSnackBar(data['error'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      _showSnackBar('Error sending OTP: $e');
    }

    setState(() => isLoading = false);
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length != 6) {
      _showSnackBar('Please enter a valid 6-digit OTP');
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://signupnodejs.vercel.app/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'otp': otp,
          'otpId': otpId
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
       
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(email: _emailController.text.trim()),
          ),
        );
        return;
      } else {
        _showSnackBar('Invalid OTP. Please try again.');
      }
    } catch (e) {
      _showSnackBar('Error verifying OTP: $e');
    }

    setState(() => isLoading = false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: otpSent ? _buildOtpForm() : _buildEmailForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Column(
      children: [
        const Text(
          'Enter your email to receive OTP',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _sendOtp,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Send OTP'),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpForm() {
    return Column(
      children: [
        const Text(
          'Enter the OTP sent to your email',
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _otpController,
          decoration: const InputDecoration(
            labelText: 'OTP',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Verify OTP'),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  setState(() {
                    otpSent = false;
                    _otpController.clear();
                  });
                },
          child: const Text('Change Email'),
        ),
      ],
    );
  }
}