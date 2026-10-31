import 'package:flutter/material.dart';
import 'package:mad_assignment/res/design.dart';
import 'package:mad_assignment/widgets/button.dart';
import 'package:mad_assignment/widgets/snackbar.dart';
import 'package:mad_assignment/services/user_storage_service.dart';
import 'package:mad_assignment/Profile/addNewVehicle.dart';

import 'model/vehicle.dart';
import 'model/service.dart';

class MakeBookingStep1 extends StatefulWidget {
  const MakeBookingStep1({
    super.key,
    required this.onNext,
    required this.selectVehicle,
    required this.selectServices,
    required this.setEstimatedDuration,
  });

  final VoidCallback onNext;
  final Function(String) selectVehicle;
  final Function(List<Service>) selectServices;
  final Function setEstimatedDuration;

  @override
  State<MakeBookingStep1> createState() => _MakeBookingStep1State();
}

class _MakeBookingStep1State extends State<MakeBookingStep1> {
  bool _isLoading = true;
  List<Vehicle>? _vehicleList;
  String? _selectedVehicle;
  List<Service>? _serviceList;
  final List<Service> _selectedServiceList = [];

  @override
  void initState() {
    super.initState();
    _loadVehiclesAndServices();
  }

  Future<void> _loadVehiclesAndServices() async {
    // Get current user ID
    final userId = await UserStorageService.getUserId();
    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final vehicles = await VehicleService.getAllVehiclesByUser(userId);
    final services = await ServiceService.getAllServices();

    setState(() {
      _vehicleList = vehicles;
      if (vehicles.isNotEmpty) {
        _selectedVehicle = vehicles[0].vehicleId;
      }
      _serviceList = services;
      _isLoading = false;
    });
  }

  void selectServices(Service service) {
    setState(() {
      if (_selectedServiceList.contains(service)) {
        _selectedServiceList.remove(service);
      } else if (_selectedServiceList.length < 3) {
        _selectedServiceList.add(service);
      } else {
        showSnackbar(context, Text("Only 3 services can be chosen", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center,), null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 26, right: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Make Booking",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 10, left: 5),
            child: const Text(
              "Step 1:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Color(0xFFE8F7FC),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.1 * 255).toInt()),
                  blurRadius: 4,
                  offset: Offset(0, 4), // Offset
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select your vehicle:",
                  style: TextStyle(color: Colors.black),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: _vehicleList == null || _vehicleList!.isEmpty
                      ? Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.directions_car_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 8),
                              Text(
                                "No vehicles found",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Add a vehicle to make a booking",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AddVehiclePage(),
                                    ),
                                  ).then((_) => _loadVehiclesAndServices()); // Refresh vehicle list after adding
                                },
                                icon: Icon(Icons.add, size: 18),
                                label: Text("Add Vehicle"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[600],
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        )
                      : DropdownButton<String>(
                          value: _selectedVehicle,
                          dropdownColor: Colors.blue[100],
                          onChanged: (newValue) {
                            if (newValue == 'add') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddVehiclePage(),
                                ),
                              ).then((_) => _loadVehiclesAndServices()); // Refresh vehicle list after adding
                            } else {
                              setState(() {
                                _selectedVehicle = newValue;
                              });
                            }
                          },
                          items: [
                            for (var vehicle in _vehicleList!) ...[
                              DropdownMenuItem<String>(
                                value: vehicle.vehicleId,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        vehicle.vehicleModel,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        vehicle.carPlateNumber,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            DropdownMenuItem<String>(
                              value: "add",
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Icon(Icons.add, color: Colors.black38),
                              SizedBox(width: 8),
                              Text(
                                "Add vehicle",
                                style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25, bottom: 10),
                  child: Row(
                    children: [
                      Text(
                        "Select your service: ",
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                        "(Maximum 3 services)",
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 10,
                    padding: EdgeInsets.all(10),
                    childAspectRatio: 0.9,
                    children: [
                      for (var service in _serviceList!) ...[
                        ElevatedButton(
                          onPressed: () {
                            selectServices(service);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _selectedServiceList.contains(
                                  service,
                                )
                                ? Color(0xFF0DFF1D)
                                : _selectedServiceList.length < 3
                                ? Color(0xFFA7E7FA)
                                : Color(0xFF3F3F3F),
                            padding: EdgeInsets.all(5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                            shadowColor: Colors.black.withAlpha(
                              (0.1 * 255).toInt(),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                serviceIcons[service.serviceName],
                                color: Colors.black38,
                                size: 25,
                              ),
                              SizedBox(height: 4),
                              Text(
                                service.serviceName,
                                style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Button(
              backgroundColor: Color(0xFFAFEBFF),
              foregroundColor: Color(0xFF3780B7),
              label: 'Next',
              action: _selectedServiceList.isNotEmpty
                  ? () {
                      widget.selectVehicle(_selectedVehicle!);
                      widget.selectServices(_selectedServiceList);
                      widget.setEstimatedDuration();
                      widget.onNext();
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
