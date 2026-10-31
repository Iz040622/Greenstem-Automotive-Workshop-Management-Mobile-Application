import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mad_assignment/Profile/addNewVehicle.dart';
import 'package:mad_assignment/widgets/gradient_scaffold.dart';

class EditVehiclePage extends StatelessWidget {
  const EditVehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: GradientScaffold.dynamicAppBar(
        context: context,
        widget: const Text("Edit Vehicles"),
      ),
      body: const EditVehicle(),
    );
  }
}

class EditVehicle extends StatefulWidget {
  const EditVehicle({super.key});

  @override
  State<EditVehicle> createState() => _EditVehicleState();
}

class _EditVehicleState extends State<EditVehicle> {
  bool deleteMode = false; // Flag to enable delete mode
  List<Map<String, String>> vehicles = []; // List of user vehicles
  final Set<int> selectedForDelete =
      {}; // Tracks selected vehicles in delete mode
  final user = FirebaseAuth.instance.currentUser; // Current logged-in user

  @override
  void initState() {
    super.initState();
    _loadVehicles(); // Load vehicles when page opens
  }

  /// Fetch vehicles from Firebase Realtime Database for the current user
  Future<void> _loadVehicles() async {
    if (user == null) return; // No user logged in
    final ref = FirebaseDatabase.instance.ref("Vehicle");

    // Query vehicles with UserId matching current user
    final snapshot = await ref.orderByChild("UserId").equalTo(user!.uid).get();

    if (snapshot.exists) {
      final Map data = snapshot.value as Map;
      final List<Map<String, String>> loadedVehicles = [];

      // Convert snapshot into a list of maps
      data.forEach((key, value) {
        loadedVehicles.add({
          "UserId": key, // Store Firebase key for deletion
          "VehicleModel": value['VehicleModel'] ?? '',
          "CarPlateNumber": value['CarPlateNumber'] ?? '',
          "Year": value['Year'] ?? '',
          "VehicleType": value["VehicleType"],
        });
      });

      setState(() {
        vehicles = loadedVehicles; // Update UI
      });
    } else {
      setState(() {
        vehicles = [];
      });
    }
  }

  /// Delete selected vehicles from Firebase
  Future<void> _deleteVehicles() async {
    if (selectedForDelete.isEmpty) return;

    final ref = FirebaseDatabase.instance.ref("Vehicle");
    int deletedCount = 0;

    try {
      for (var index in selectedForDelete) {
        final vehicleId = vehicles[index]['UserId']; // Use 'UserId' which contains the Firebase key
        if (vehicleId != null) {
          await ref.child(vehicleId).remove(); // Delete vehicle
          deletedCount++;
        }
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully deleted $deletedCount vehicle(s)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting vehicles: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    selectedForDelete.clear(); // Clear selected set
    _loadVehicles(); // Refresh vehicle list
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Title
        Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: const Text(
              "Current Vehicle",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Vehicle list
        Expanded(
          child: vehicles.isEmpty
              ? const Center(
                  child: Text(
                    "No vehicles found.",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final v = vehicles[index];
                    final isSelected = selectedForDelete.contains(index);

                    return GestureDetector(
                      onTap: () {
                        if (deleteMode) {
                          setState(() {
                            if (isSelected) {
                              selectedForDelete.remove(index);
                            } else {
                              selectedForDelete.add(index);
                            }
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xffE3F9ED).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: (deleteMode && isSelected)
                              ? Border.all(
                                  color: isSelected
                                      ? Colors.red
                                      : Colors.redAccent,
                                  width: 2,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Vehicle image
                            Container(
                              width: 120,
                              height: 80,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: AssetImage('assets/images/car1.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Vehicle details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Vehicle Model: ${v['VehicleModel']}",
                                    style: const TextStyle(
                                      color: Color(0xFF5D5D5D),
                                    ),
                                  ),
                                  Text(
                                    "Year manufacture: ${v['Year']}",
                                    style: const TextStyle(
                                      color: Color(0xFF5D5D5D),
                                    ),
                                  ),
                                  Text(
                                    "Plate Number: ${v['CarPlateNumber']}",
                                    style: const TextStyle(
                                      color: Color(0xFF5D5D5D),
                                    ),
                                  ),
                                  Text(
                                    "Vehicle Type: ${v['VehicleType']}",
                                    style: const TextStyle(
                                      color: Color(0xFF5D5D5D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        // Bottom buttons
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Delete button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFAFAF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: Icon(
                  deleteMode ? Icons.delete_forever : Icons.delete,
                  color: const Color(0xFFB77065),
                ),
                label: Text(
                  deleteMode ? "Confirm Delete" : "Delete Vehicle",
                  style: const TextStyle(
                    color: Color(0xFFB77065),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  if (deleteMode) {
                    if (selectedForDelete.isNotEmpty) {
                      // Show confirmation dialog
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirm Delete'),
                          content: Text('Are you sure you want to delete ${selectedForDelete.length} vehicle(s)?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: Text('Delete', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await _deleteVehicles(); // Delete selected vehicles
                        setState(() {
                          deleteMode = false; // Exit delete mode
                        });
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select vehicles to delete'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  } else {
                    setState(() {
                      deleteMode = true; // Enter delete mode
                    });
                  }
                },
              ),

              const SizedBox(height: 8),

              // Add button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffAFEBFF),
                  foregroundColor: const Color(0xff3780B7),
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: Icon(deleteMode ? Icons.close : Icons.add),
                label: Text(deleteMode ? "Cancel" : "Add New Vehicle"),
                onPressed: () {
                  if (deleteMode) {
                    setState(() {
                      deleteMode = false; // Cancel delete mode
                      selectedForDelete.clear();
                    });
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddVehiclePage(),
                      ),
                    ).then((_) => _loadVehicles()); // Refresh list after adding
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}