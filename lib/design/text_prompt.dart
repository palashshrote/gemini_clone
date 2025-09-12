import 'package:flutter/material.dart';

Widget customListTile(String data, String role) {
  final isUser = role == 'user';

  return Align(
    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isUser ? Colors.tealAccent.shade700 : Colors.grey.shade800,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(0),
          bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(18),
        ),
      ),
      child: Text(
        data,
        style: TextStyle(
          color: isUser ? Colors.black : Colors.white,
          fontSize: 15,
        ),
      ),
    ),
  );
}
