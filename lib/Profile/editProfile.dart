import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mad_assignment/Profile/changePassword.dart';
import 'package:mad_assignment/widgets/gradient_scaffold.dart';
import 'package:mad_assignment/services/user_storage_service.dart';

class Editprofile extends StatelessWidget {
  const Editprofile({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: GradientScaffold.dynamicAppBar(
        context: context,
        widget: const Text("Edit Profile"),
      ),
      body: const EditProfile(), // Calls the stateful form below
    );
  }
}

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // Controllers for input fields
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Validation key
  String? _profileImageUrl; // Stores Firebase profile image URL

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user info from DB when screen opens
  }

  /// Load current user data from local storage first, then Firebase if needed
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Try to load from local storage first
      final localUserData = await UserStorageService.getCurrentUser();
      
      if (localUserData != null) {
        setState(() {
          // Pre-fill fields from local storage
          _usernameController.text = localUserData["username"] ?? "";
          _emailController.text = localUserData["email"] ?? user.email ?? "";
          _phoneController.text = localUserData["phoneNumber"] ?? "";
          _profileImageUrl = localUserData["photoURL"];
        });
      }

      // Load any missing data from Firebase as backup
      final snapshot = await FirebaseDatabase.instance
          .ref("users/${user.uid}")
          .get();

      if (snapshot.exists) {
        final data = snapshot.value as Map;
        setState(() {
          // Update phone number if not loaded from local storage
          if (_phoneController.text.isEmpty) {
            _phoneController.text = data["phoneNumber"] ?? "";
          }
          // Update profile image URL if not loaded from local storage
          if (_profileImageUrl == null) {
            _profileImageUrl = data["profileImageUrl"];
          }
        });
      }
    }
  }

  /// Pick image from gallery and upload to Firebase Storage
  File? _pickedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _pickedImage = File(pickedFile.path); // Show locally
    });
  }


  /// Save updated profile info to Realtime Database
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      String? downloadUrl = _profileImageUrl;

      if (_pickedImage != null && user != null) {
        // Upload to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref("profileImages/${user.uid}.jpg");
        await storageRef.putFile(_pickedImage!);
        downloadUrl = await storageRef.getDownloadURL();
      }

      if (user != null) {
        // Update Realtime Database
        await FirebaseDatabase.instance.ref("users/${user.uid}").update({
          "username": _usernameController.text,
          "email": _emailController.text,
          "phoneNumber": _phoneController.text,
          "profileImageUrl": downloadUrl,
        });

        // Update local storage with new profile information
        await UserStorageService.updateUser({
          'username': _usernameController.text,
          'email': _emailController.text,
          'photoURL': downloadUrl,
          'phoneNumber': _phoneController.text,
        });

        setState(() {
          _profileImageUrl = downloadUrl;
          _pickedImage = null; // reset
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );

        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    // Clean up controllers when widget is destroyed
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 20),

            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _pickedImage != null
                        ? FileImage(_pickedImage!)
                        : (_profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : const AssetImage('assets/images/car2.png') as ImageProvider),
                  ),
                  Positioned(
                    bottom: -5,
                    right: -5,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                          onTap: () {
                            _pickImage(); // call async function inside a sync closure
                          },
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Color(0xffAFEBFF),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.add_a_photo,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Username field
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Username",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextFormField(
              controller: _usernameController,
              style: const TextStyle(color: Colors.black),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a username';
                }
                if (value.length < 3) {
                  return 'Username must be at least 3 characters';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outline),
                hintText: "Username",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Email field
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Email",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: Colors.black),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                }
                if (!value.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email_outlined),
                hintText: "Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Phone field
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Phone Number",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextFormField(
              controller: _phoneController,
              style: const TextStyle(color: Colors.black),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a phone number';
                }
                if (value.length < 9 || value.length > 11) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone_outlined),
                hintText: "Phone Number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// Change password button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Changepassword(),
                  ),
                ),
                label: const Text(
                  "Change Password",
                  style: TextStyle(color: Color(0xFFB77065)),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFAFAF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAFEBFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(color: Color(0xFF3780B7)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
