import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:scholar_match_app/alumni/AlumniResetPassword.dart';

class AlumniOtpVerify extends StatefulWidget {
  final String email;
  final String otpId;

  const AlumniOtpVerify({
    super.key,
    required this.email,
    required this.otpId,
  });

  @override
  State<AlumniOtpVerify> createState() => _AlumniOtpVerifyState();
}

class _AlumniOtpVerifyState extends State<AlumniOtpVerify> {
  final TextEditingController _otpController = TextEditingController();
  bool _loading = false;

  Future<void> verifyOtp() async {
    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse("https://signupnodejs.vercel.app/send-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "otpId": widget.otpId,
          "otp": _otpController.text.trim(),
          "email": widget.email,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP Verified Successfully")),
        );

        Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => AlumniResetPassword(email: widget.email),
  ),
);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["error"] ?? "Invalid OTP")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _loading = false);
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
              const SizedBox(height: 40),
              const Text(
                "Verify OTP",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _otpController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Enter OTP",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 30),

              _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : ElevatedButton(
                      onPressed: verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.purple.shade700,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Verify OTP",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
