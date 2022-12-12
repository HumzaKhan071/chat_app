import 'package:chat_app/chat.dart';
import 'package:chat_app/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class FindFriendPage extends StatefulWidget {
  final List<Chat> chats;

  const FindFriendPage(this.chats, {Key? key}) : super(key: key);

  @override
  State<FindFriendPage> createState() => _FindFriendPageState();
}

class _FindFriendPageState extends State<FindFriendPage> {
  String username = '';
  bool isSearching = false;

  void showNotFoundDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: const Text('Not Found'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        );
      },
    );
  }

  void findUser() async {
    setState(() => isSearching = true);
    QuerySnapshot<Map<String, dynamic>> result =
        await FirebaseFirestore.instance.collection('users').where('username', isEqualTo: username).get();
    print(result.docs);
    if (result.docs.isEmpty) {
      showNotFoundDialog();
    } else {
      String friendId = result.docs.first.id;
      if (friendId == FirebaseAuth.instance.currentUser!.uid) {
        showNotFoundDialog();
      } else {
        Chat? chat = widget.chats.firstWhereOrNull((e) => e.friendId == friendId);
        if (chat != null) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ChatPage(chat!)));
        } else {
          chat = Chat(friendId, friendUsername: result.docs.first.data()['username'], messages: []);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ChatPage(chat!)));
        }
      }
    }
    setState(() => isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find friend')),
      body: isSearching
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
                  child: TextField(
                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Friend's Username"),
                    onChanged: (val) => setState(() => username = val),
                  ),
                ),
                ElevatedButton(
                  onPressed: findUser,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('Find'),
                  ),
                ),
              ],
            ),
    );
  }
}