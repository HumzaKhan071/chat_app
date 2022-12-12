import 'package:chat_app/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool showPassword = false;
  bool isLoading = false;
  String? errorMessage;
  String? emailErrorMessage;
  String? passwordErrorMessage;

  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      emailErrorMessage = null;
      passwordErrorMessage = null;
    });
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      print(e);
      if (e.code == 'user-not-found') {
        emailErrorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        passwordErrorMessage = 'Wrong password.';
        passwordController.clear();
      } else {
        errorMessage = 'something went wrong';
      }
    } catch (e) {
      errorMessage = 'something went wrong';
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 56.0, bottom: 20.0),
            child: Text('Login', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600)),
          ),
          TextField(
            decoration:
                InputDecoration(labelText: 'Email', border: const OutlineInputBorder(), errorText: emailErrorMessage),
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
            onPressed: isLoading ? null : login,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(isLoading ? 'Loading...' : 'Login'),
            ),
          ),
          const SizedBox(height: 20.0),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }
}