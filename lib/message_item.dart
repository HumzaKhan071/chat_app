import 'package:chat_app/chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageItem extends StatelessWidget {
  final Message message;

  const MessageItem(this.message, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isAuthor = message.authorId == FirebaseAuth.instance.currentUser!.uid;
    double radius = 12.0;

    return Row(
      mainAxisAlignment: isAuthor ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        isAuthor
            ? Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Icon(Icons.check_circle, size: 20, color: message.readAt == null ? Colors.grey : Colors.blue[400]),
              )
            : const SizedBox(),
        Card(
          color: isAuthor ? Colors.blue[300] : Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: isAuthor ? Radius.circular(radius) : const Radius.circular(2.0),
              topRight: isAuthor ? const Radius.circular(2.0) : Radius.circular(radius),
              bottomLeft: Radius.circular(radius),
              bottomRight: Radius.circular(radius),
            ),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 250),
                    child: Container(
                      alignment: isAuthor ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(message.message),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Container(
                    alignment: isAuthor ? Alignment.centerLeft : Alignment.centerRight,
                    child: Text(message.time, style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}