import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mad_assignment/widgets/gradient_scaffold.dart';

class Changepassword extends StatelessWidget {
  const Changepassword({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: GradientScaffold.dynamicAppBar(
        context: context,
        widget: const Text("Change Password"),
      ),
      body: const ChangePassword(),
    );
  }
}

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _passOld = true;
  bool _passNew = true;
  bool _passConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (user != null && user.email != null) {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      try {
        // Re-authenticate user with old password
        await user.reauthenticateWithCredential(credential);

        // Update password
        await user.updatePassword(newPassword);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password changed successfully!")),
        );

        // Clear text fields
        _oldPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } on FirebaseAuthException catch (e) {
        String message = "Something went wrong!";
        if (e.code == 'wrong-password') {
          message = "Old password is incorrect.";
        } else if (e.code == 'weak-password') {
          message = "New password is too weak.";
        } else if (e.code == 'requires-recent-login') {
          message = "Please log out and log in again to change password.";
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "CHANGE PASSWORD",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Create a strong and secure new password",
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),

            // Old Password
            TextFormField(
              controller: _oldPasswordController,
              style: TextStyle(color: Colors.black),
              obscureText: _passOld,
              decoration: InputDecoration(
                hintText: "Old Password",
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.black),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passOld ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black,
                  ),
                  onPressed: () => setState(() => _passOld = !_passOld),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter your old password';
                return null;
              },
            ),
            const SizedBox(height: 15),

            // New Password
            TextFormField(
              controller: _newPasswordController,
              style: TextStyle(color: Colors.black),
              obscureText: _passNew,
              decoration: InputDecoration(
                hintText: "New Password",
                prefixIcon: const Icon(Icons.lock_reset, color: Colors.black),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passNew ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black,
                  ),
                  onPressed: () => setState(() => _passNew = !_passNew),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter a new password';
                if (value.length < 6)
                  return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 15),

            // Confirm Password
            TextFormField(
              controller: _confirmPasswordController,
              style: TextStyle(color: Colors.black),
              obscureText: _passConfirm,
              decoration: InputDecoration(
                hintText: "Confirm Password",
                prefixIcon: const Icon(Icons.lock, color: Colors.black),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passConfirm ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black,
                  ),
                  onPressed: () => setState(() => _passConfirm = !_passConfirm),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.black),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please confirm your new password';
                if (value != _newPasswordController.text)
                  return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 25),

            // Change Password Button
            ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFAFAF),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Change Password",
                      style: TextStyle(color: Color(0xFFB77065)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
