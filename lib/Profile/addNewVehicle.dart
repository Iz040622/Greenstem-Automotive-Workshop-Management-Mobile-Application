import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mad_assignment/widgets/gradient_scaffold.dart';

class AddVehiclePage extends StatelessWidget {
  const AddVehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: GradientScaffold.dynamicAppBar(
        context: context,
        widget: const Text("Add Vehicle"),
      ),
      body: const AddVehicle(),
    );
  }
}

class AddVehicle extends StatefulWidget {
  const AddVehicle({super.key});

  @override
  State<AddVehicle> createState() => _AddVehicleState();
}

class _AddVehicleState extends State<AddVehicle> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController plateController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  String? VehicleType;

  final user = FirebaseAuth.instance.currentUser; // Current logged-in user

  /// Upload vehicle details to Firebase Realtime Database
  Future<void> _uploadVehicle() async {
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref("Vehicle");

    // Prepare vehicle data
    final vehicleData = {
      "UserId": user!.uid,
      "VehicleModel": modelController.text.trim(),
      "CarPlateNumber": plateController.text.trim(),
      "Year": yearController.text.trim(),
      "VehicleType": VehicleType ?? "",
    };

    try {
      // Push vehicle to database
      await ref.push().set(vehicleData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vehicle Added Successfully")),
      );

      // Clear text fields
      modelController.clear();
      plateController.clear();
      yearController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error adding vehicle: $e")));
    }
  }

  @override
  void dispose() {
    modelController.dispose();
    plateController.dispose();
    yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // Title
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Add Vehicle",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 24, // slightly bigger
                ),
              ),
            ),
            const SizedBox(height: 20),

            Image.asset(
              'assets/images/car2.png',
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.2,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),

            // Car Model
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Car Model",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            TextFormField(
              controller: modelController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Car Model",
                hintStyle: const TextStyle(color: Color(0xff5D5D5D)),
                prefixIcon: const Icon(Icons.directions_car),
                filled: true,
                fillColor: Color(0xffF0EDFF).withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return "Enter car model";
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Plate Number
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Plate Number",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            TextFormField(
              controller: plateController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Plate Number",
                hintStyle: const TextStyle(color: Color(0xff5D5D5D)),
                prefixIcon: const Icon(Icons.confirmation_number),
                filled: true,
                fillColor: Color(0xffF0EDFF).withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return "Enter plate number";
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Year
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Year Manufacture",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            TextFormField(
              controller: yearController,
              style: const TextStyle(color: Colors.black),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Year manufacture",
                hintStyle: const TextStyle(color: Color(0xff5D5D5D)),
                prefixIcon: const Icon(Icons.calendar_today),
                filled: true,
                fillColor: Color(0xffF0EDFF).withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return "Enter year";
                return null;
              },
            ),
            const SizedBox(height: 16),

            //VehicleType
            Row(
              children: [
                const Text(
                  "Vehicle Type:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xffF0EDFF).withOpacity(0.8),
                      // Matches your container
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xffA9C7FE),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: VehicleType,
                        hint: const Text(
                          "Select Vehicle Type",
                          style: TextStyle(color: Color(0xff5D5D5D)),
                        ),
                        isExpanded: false,
                        dropdownColor: Color(0xffF0EDFF),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xff5D5D5D),
                        ),
                        style: const TextStyle(
                          color: Color(0xff5D5D5D),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "HatchBack",
                            child: Text("HatchBack"),
                          ),
                          DropdownMenuItem(
                            value: "Sedan",
                            child: Text("Sedan"),
                          ),
                          DropdownMenuItem(
                              value: "SUV",
                              child: Text("SUV")
                          ),
                          DropdownMenuItem(
                              value: "4X4",
                              child: Text("4X4")
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            VehicleType = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Add Vehicle Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent.shade100,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(Icons.add, color: Color(0xff3780B7)),
              label: const Text(
                "Add New Vehicle",
                style: TextStyle(color: Color(0xff3780B7), fontSize: 16),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (VehicleType == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select a car model"),
                      ),
                    );
                  }
                  await _uploadVehicle(); // Upload to Firebase
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
