import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'profile_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  bool _isRegister = false;

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final endpoint = _isRegister ? '/users/register' : '/users/login';
        final body = _isRegister 
          ? {
              'email': _emailController.text,
              'password': _passwordController.text,
              'nama': _namaController.text
            }
          : {
              'email': _emailController.text,
              'password': _passwordController.text
            };

        final response = await http.post(
          Uri.parse('http://localhost:3000$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );

        print('Status Code: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(
                token: data['token'],
                userId: data['user']['id']
              )
            ),
          );
        } else {
          final errorData = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${_isRegister ? 'Registrasi' : 'Login'} gagal: ${errorData['message'] ?? 'Unknown error'}')),
          );
        }
      } catch (e) {
        print('Error detail: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isRegister ? 'Register' : 'Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_isRegister)
                TextFormField(
                  controller: _namaController,
                  decoration: InputDecoration(labelText: 'Nama'),
                  validator: (value) => value!.isEmpty ? 'Masukkan nama' : null,
                ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Masukkan email' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Masukkan password' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(_isRegister ? 'Register' : 'Login'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isRegister = !_isRegister;
                  });
                },
                child: Text(_isRegister ? 'Sudah punya akun? Login' : 'Belum punya akun? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}