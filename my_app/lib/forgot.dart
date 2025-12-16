import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/signup.dart';

class Forgot extends StatefulWidget {
  const Forgot({super.key});

  @override
  State<Forgot> createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {

    TextEditingController emailController=TextEditingController();

  reset()async{
    await FirebaseAuth.instance.sendPasswordResetEmail(
      email: emailController.text
    );
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
        title: Text('Forgot password'),),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
                        const Text(
              "Reset your password",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 40), // space before fields

            Align(
              alignment: Alignment.centerLeft,
              child:const Text(
              "Email",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Enter Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 12,
              ),
            ),
            ),

            SizedBox(height: 40,),

                        Center(
              child: ElevatedButton(
                onPressed: () => reset(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue, // 👈 Light blue color
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Send Reset Link',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}