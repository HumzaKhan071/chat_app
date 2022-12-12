import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool showPassword = false;
  bool isLoading = false;
  String? emailErrorMessage;
  String? passwordErrorMessage;
  String? errorMessage;

  Future<void> register() async {
    setState(() => isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        passwordErrorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        emailErrorMessage = 'The account already exists for that email.';
      }
    } catch (e) {
      print(e);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 56.0, bottom: 20.0),
            child: Text('Register', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600)),
          ),
          TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              border: const OutlineInputBorder(),
              errorText: emailErrorMessage,
            ),
            controller: emailController,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: 16.0),
          TextField(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Password',
              errorText: passwordErrorMessage,
              suffixIcon: IconButton(
                onPressed: () => setState(() => showPassword = !showPassword),
                icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
              ),
            ),
            controller: passwordController,
            autofillHints: const [AutofillHints.password],
            obscureText: !showPassword,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
            child: errorMessage != null ? Text(errorMessage!, style: const TextStyle(color: Colors.red)) : const SizedBox(),
          ),
          ElevatedButton(
            onPressed: isLoading ? null : register,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(isLoading ? 'Loading...' : 'Register'),
            ),
          )
        ],
      ),
    );
  }
}