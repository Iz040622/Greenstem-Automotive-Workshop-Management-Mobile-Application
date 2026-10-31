import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  final Color foregroundColor;
  final Color backgroundColor;
  final IconData? iconData;
  final String label;
  final VoidCallback? action;

  const Button({super.key, required this.foregroundColor, required this.backgroundColor, this.iconData, required this.label, this.action});

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.action,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor,
          foregroundColor: widget.foregroundColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.iconData != null) ...[
              Icon(widget.iconData),
              SizedBox(width: 5),
            ],
            Text(widget.label)],
        ),
      ),
    );
  }
}
