import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  String _phoneNumber = '';
  String _otp = '';
  bool _otpSent = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_otpSent) ...[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+256701234567 or 0701234567',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => _validatePhone(value),
                  onSaved: (value) => _phoneNumber = value!,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  child: _isLoading 
                      ? const CircularProgressIndicator()
                      : const Text('SEND OTP'),
                ),
              ] else ...[
                Text('OTP sent to $_phoneNumber', 
                    style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(labelText: '6-digit OTP'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.length != 6 ? 'Enter valid OTP' : null,
                  onSaved: (value) => _otp = value!,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  child: _isLoading 
                      ? const CircularProgressIndicator()
                      : const Text('LOGIN'),
                ),
                TextButton(
                  onPressed: _isLoading ? null : () => setState(() => _otpSent = false),
                  child: const Text('Change Phone Number'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String? _validatePhone(String? value) {
    final ugandanPhoneRegex = RegExp(r'^(\+256|0)[0-9]{9}$');
    if (value == null || !ugandanPhoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Enter valid Ugandan number';
    }
    return null;
  }

  // In login_screen.dart, replace the _apiService calls with _openAIService
Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    setState(() => _isLoading = true);
    try {
      await _authService.sendOtp(_phoneNumber);
      setState(() => _otpSent = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    setState(() => _isLoading = true);
    try {
      final verified = await _authService.verifyOtp(_phoneNumber, _otp);
      if (verified) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid OTP, please try again')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
