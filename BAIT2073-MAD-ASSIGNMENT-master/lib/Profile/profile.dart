import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mad_assignment/Login_Reg_Module/loginPage.dart';
import 'package:mad_assignment/Profile/editProfile.dart';
import 'package:mad_assignment/Profile/editVehicle.dart';
import 'package:mad_assignment/widgets/gradient_scaffold.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Profile();
  }
}

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String email = "Loading...";
  String? userProfileImageUrl; //

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
  }

  Future<void> _fetchUserEmail() async {
    try {
      // Get current logged-in user
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;

        // Read from Realtime Database
        final ref = FirebaseDatabase.instance.ref("users/$uid");
        final snapshot = await ref.get();

        if (snapshot.exists) {
          final data = snapshot.value as Map;
          setState(() {
            email = data["email"] ?? "No Email";
          });
        } else {
          setState(() {
            email = "No Data Found";
          });
        }
      } else {
        setState(() {
          email = "Not logged in";
        });
      }
    } catch (e) {
      setState(() {
        email = "Error loading email";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage: (userProfileImageUrl != null && userProfileImageUrl!.isNotEmpty)
                  ? NetworkImage(userProfileImageUrl!)
                  : const AssetImage('assets/images/car2.png') as ImageProvider,
            ),
            const SizedBox(height: 10),
            Text(email, style: const TextStyle(color: Colors.black)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Editprofile()),
              ),
              label: const Text(
                "Edit Profile",
                style: TextStyle(color: Color(0xFF3780B7)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAFEBFF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),

            // GENERAL
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "GENERAL",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const Divider(color: Color(0xFF5E84A1)),

            ListTile(
              leading: const Icon(Icons.directions_car, color: Colors.black),
              title: const Text("Vehicle List",
                  style: TextStyle(color: Colors.black)),
              subtitle: const Text(
                "For the new update and vehicle update",
                style: TextStyle(color: Colors.black),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditVehiclePage(),
                ),
              ),
            ),
            const Divider(color: Color(0xFF5E84A1)),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.black),
              title: const Text("Log Out",
                  style: TextStyle(color: Colors.black)),
              subtitle: const Text("Log out and see you soon",
                  style: TextStyle(color: Colors.black)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
