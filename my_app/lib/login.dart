import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/homePage.dart';
import 'package:my_app/signup.dart';
import 'package:my_app/forgot.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> signIn() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Navigate to HomePage after successful login
      Get.offAll(() => const HomePage());
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Get.snackbar('Login Error', e.message ?? 'Unknown error',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // keep fields left
            children: [
              const SizedBox(height: 30),

              // Center the welcome section
              const Center(
                child: Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  "Login or Sign up to continue",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 40),

              // Email label + input (left)
              const Text("Email",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                    hintText: 'Enter your email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

              // Password label + input (left)
              const Text("Password",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                    hintText: 'Enter your password',
                    border: OutlineInputBorder()),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.to(() => const Forgot()),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🟦 Buttons centered
              Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          ElevatedButton(
                            onPressed: signIn,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15)),
                            child: const Text('Login',
                                style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => Get.to(() => const Signup()),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 15)),
                            child: const Text('Sign up',
                                style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
