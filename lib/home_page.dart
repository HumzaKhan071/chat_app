import 'package:chat_app/chat.dart';
import 'package:chat_app/chat_page.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'find_friend_page.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage(this.username, {Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _userStream;
  late CollectionReference<Map<String, dynamic>> conversationsCollection;
  late CollectionReference<Map<String, dynamic>> usersCollection;
  List<Chat> chats = [];

  Future<void> updateChats(QuerySnapshot<Map<String, dynamic>> data) async {
    print(data.docChanges);
    for (DocumentChange<Map<String, dynamic>> doc in data.docChanges) {
      Chat? chat = chats.firstWhereOrNull((e) => e.conversationId == doc.doc.id);
      Map<String, dynamic> data = doc.doc.data()!;
      if (chat != null) {
        chat.updatedAt = (data['updatedAt'] as Timestamp).toDate();
        chat.fetchMessages().then((value) => setState(() {}));
      } else {
        String friendId = (data['members'] as List).firstWhere((e) => e != FirebaseAuth.instance.currentUser!.uid);
        Chat newChat = Chat(friendId, conversationId: doc.doc.id, updatedAt: (data['updatedAt'] as Timestamp).toDate());
        chats.add(newChat);
        newChat.fetchMessages().then((value) => setState(() {}));
      }
      chats.sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
    }
  }

  void initStream() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    _userStream = conversationsCollection.where('members', arrayContainsAny: [userId]).snapshots();
    _userStream.listen((data) {
      setState(() {
        updateChats(data);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    conversationsCollection = FirebaseFirestore.instance.collection('conversations');
    usersCollection = FirebaseFirestore.instance.collection('users');
    initStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout))],
      ),
      body: chats.isEmpty
          ? const Center(child: Text('No chat found'))
          : ListView.builder(
              padding: const EdgeInsets.only(top: 4.0),
              itemCount: chats.length,
              itemBuilder: (context, index) {
                Chat item = chats[index];
                return Column(
                  children: [
                    ListTile(
                      title: FutureBuilder(
                        future: item.fetchFriendUsername(),
                        builder: (context, AsyncSnapshot<String> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) return const Text('Loading...');
                          if (snapshot.hasError) return const Text('Error');
                          return Text(item.friendUsername!);
                        },
                      ),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPage(item))),
                      trailing: item.unreadMessagesCount > 0
                          ? Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.blue[400],
                                shape: BoxShape.circle,
                              ),
                              child: Text('${item.unreadMessagesCount}'),
                            )
                          : const SizedBox(),
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FindFriendPage(chats))),
        child: const Icon(Icons.chat),
      ),
    );
  }
}