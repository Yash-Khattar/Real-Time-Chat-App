import 'package:flutter/material.dart';
import 'package:real_time_chat_app/message_bubble.dart';
import 'package:real_time_chat_app/url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  late IO.Socket socket;
  TextEditingController messageController = TextEditingController();
  List<Map<String, String>> messages = [];
  String? uid;

  @override
  void initState() {
    super.initState();
    connectToSocket();
  }

  Future<void> connectToSocket() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    socket = IO.io(
        backendUrl,
        // 'http://localhost:3001',
        <String, dynamic>{
          'transports': ['websocket'],
        });

    socket.on('connect', (_) {});

    // Listen for UID from the server
    socket.on('uid', (data) async {
      setState(() {
        uid = data;
      });

      // Store UID in SharedPreferences
      await prefs.setString('uid', uid!);
    });

    // Listen for messages from the server
    socket.on('message', (data) {
      setState(() {
        messages.insert(0, {
          'uid': data['uid'],
          'message': data['message'],
        });
      });
    });

    // Listen for initial messages from the server
    socket.on('getMessages', (data) {
      setState(() {
        messages = List<Map<String, String>>.from(data.map((msg) => {
              'uid': msg['uid'].toString(),
              'message': msg['message'].toString()
            }));
      });
    });

    socket.on('disconnect', (_) {});

    socket.on('reconnect_attempt', (_) {});

    socket.on('reconnect', (_) {});
  }

  void sendMessage() {
    String message = messageController.text;
    if (uid != null) {
      socket.emit('message', {'uid': uid, 'message': message});
      setState(() {
        messages.insert(0, {'uid': uid!, 'message': message});
      });
      messageController.clear();
    } else {}
  }

  @override
  void dispose() {
    socket.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF14171B),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return MessageBubble(
                        message: messages[index],
                        isMe: uid == messages[index]['uid']);
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: messageController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 22),
                      hintStyle: const TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w400),
                      hintText: 'Enter message',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: sendMessage,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
