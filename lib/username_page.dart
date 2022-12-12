import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SetUsernamePage extends StatefulWidget {
  final void Function() onCompleted;
  const SetUsernamePage(this.onCompleted, {Key? key}) : super(key: key);

  @override
  State<SetUsernamePage> createState() => _SetUsernamePageState();
}

class _SetUsernamePageState extends State<SetUsernamePage> {
  TextEditingController controller = TextEditingController();
  String? errorMessage;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set username')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Username',
                errorText: errorMessage,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
                    setState(() => isLoading = true);
                    User user = FirebaseAuth.instance.currentUser!;
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .set({'username': controller.text, 'email': user.email}).then((value) => widget.onCompleted());
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(isLoading ? 'Loading...' : 'Confirm'),
            ),
          )
        ],
      ),
    );
  }
}