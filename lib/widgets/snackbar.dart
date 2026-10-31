import 'package:flutter/material.dart';

void showSnackbar(BuildContext context, Text text, SnackBarAction? snackBarAction) {
  final snackBar = SnackBar(
    content: text,
    duration: Duration(seconds: 2),
    action: snackBarAction,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
