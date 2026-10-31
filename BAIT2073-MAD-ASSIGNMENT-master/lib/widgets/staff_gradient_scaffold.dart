import 'package:flutter/material.dart';
import 'package:mad_assignment/Login_Reg_Module/loginPage.dart';

class StaffGradientScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const StaffGradientScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Color(0xFF6F7BF7), // Inner color (center)
                Color(0xFFE3EFFC), // Outer color (edges)
              ],
              center: Alignment.bottomRight,
              // Position the center of the circle
              radius: 1.0, // Adjust how far the gradient spreads
            ),
          ),
          child: body,
        ),
      ),
      backgroundColor: Colors.transparent,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  static AppBar dynamicAppBar({
    required BuildContext context,
    required Widget widget,
    Widget? leading,
  }) {
    return AppBar(
      title: widget,
      centerTitle: true,
      leading: leading ?? SizedBox.shrink(),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginPage(),
              ),
            );
          },
          icon: const Icon(Icons.exit_to_app, color: Colors.white),
        ),
      ],
    );
  }
}
