import 'package:flutter/material.dart';
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
        'http://ec2-184-73-64-161.compute-1.amazonaws.com:3001',
        // 'http://localhost:3001',
        <String, dynamic>{
          'transports': ['websocket'],
        });

    socket.on('connect', (_) {
      print('Connected to server');
    });

    // Listen for UID from the server
    socket.on('uid', (data) async {
      print('Received UID: $data');
      setState(() {
        uid = data;
      });

      // Store UID in SharedPreferences
      await prefs.setString('uid', uid!);
    });

    // Listen for messages from the server
    socket.on('message', (data) {
      print('Message from server: ${data['message']} from UID: ${data['uid']}');
      setState(() {
        messages.insert(0, {
          'uid': data['uid'],
          'message': data['message'],
        });
      });
    });

    // Listen for initial messages from the server
    socket.on('getMessages', (data) {
      print(data);
      setState(() {
        messages = List<Map<String, String>>.from(data.map((msg) => {
              'uid': msg['uid'].toString(),
              'message': msg['message'].toString()
            }));
      });
    });

    socket.on('disconnect', (_) {
      print('Disconnected from server');
    });

    socket.on('reconnect_attempt', (_) {
      print('Attempting to reconnect');
    });

    socket.on('reconnect', (_) {
      print('Reconnected to server');
    });
  }

  void sendMessage() {
    String message = messageController.text;
    if (uid != null) {
      socket.emit('message', {'uid': uid, 'message': message});
      setState(() {
        messages.insert(0, {'uid': uid!, 'message': message});
      });
      messageController.clear();
    } else {
      print('UID is null, message not sent');
    }
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
        appBar: AppBar(
          title: const Text('Flutter Socket.IO Demo'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(messages[index]['message']!),
                    subtitle: Text(messages[index]['uid']!),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: messageController,
                        decoration: const InputDecoration(
                          hintText: 'Enter message',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: sendMessage,
                    child: const Text('Send'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
