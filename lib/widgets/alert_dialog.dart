import 'package:flutter/material.dart';

Future<bool?> showAlertDialog(BuildContext context, String? title, String? content, List<Widget> actions) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Color(0xFFB2D7EF),
      title: title == null ? null : Text(title, style: TextStyle(color: Colors.black),),
      content: content == null ? null : Text(content, style: TextStyle(color: Colors.black),),
      actions: actions,
    ),
  );
}
