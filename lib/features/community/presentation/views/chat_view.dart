import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  Future<void> sendMessage(String message) async {
    setState(() {
      _messages.add({"role": "user", "content": message});
      _isLoading = true;
    });

    try {
      // Exemple avec API locale ou serveur backend
      // 👉 Ici il faudra remplacer par ton endpoint d’IA (Flask, Node.js, ou OpenAI si tu veux)
      final response = await http.post(
        Uri.parse("https://api-inventee-ou-ton-backend.com/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          _messages
              .add({"role": "assistant", "content": data["reply"] ?? "..."});
        });
      } else {
        setState(() {
          _messages
              .add({"role": "assistant", "content": "Erreur du serveur ❌"});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(
            {"role": "assistant", "content": "Impossible de se connecter 🤖"});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat avec l'IA 🤖"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["role"] == "user";
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.deepPurple[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      msg["content"] ?? "",
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Écris ton message...",
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.deepPurple),
                onPressed: () {
                  final text = _controller.text.trim();
                  if (text.isNotEmpty) {
                    sendMessage(text);
                    _controller.clear();
                  }
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
