import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final Map message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            message['uid']!.toString().substring(0, 8),
            style: TextStyle(color: Colors.grey[300], fontSize: 12),
          ),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: isMe ? null : Colors.white,
                    gradient: isMe
                        ? const LinearGradient(
                            colors: [Color(0xFF2F8762), Color(0xFF183429)],
                            stops: [0.5, 1],
                            end: Alignment.bottomLeft,
                            begin: Alignment.topRight)
                        : null,
                    borderRadius: BorderRadius.only(
                      bottomRight: const Radius.circular(16),
                      bottomLeft: const Radius.circular(16),
                      topLeft: isMe
                          ? const Radius.circular(16)
                          : const Radius.circular(0),
                      topRight: isMe
                          ? const Radius.circular(0)
                          : const Radius.circular(16),
                    )),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                child: Text(
                  message['message']!,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
