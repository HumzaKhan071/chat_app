import 'package:chat_app/chat.dart';
import 'package:chat_app/message_item.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final Chat chat;

  const ChatPage(this.chat, {Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.chat.markAsRead().then((value) {
      setState(() {});
    });
    widget.chat.isOpen = true;
  }

  @override
  void dispose() {
    widget.chat.isOpen = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.chat.friendUsername!)),
      body: Column(
        children: [
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: widget.chat.notifier,
              builder: (context, _, __) {
                return GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 12.0),
                    itemCount: widget.chat.messages!.length,
                    itemBuilder: (context, index) {
                      return MessageItem(widget.chat.messages![index]);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'Message...',
                suffixIcon: IconButton(
                  onPressed: () {
                    widget.chat.sendMessage(controller.text).then((value) {
                      setState(() {
                        controller.clear();
                      });
                    });
                  },
                  icon: const Icon(Icons.send),
                ),
              ),
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }
}