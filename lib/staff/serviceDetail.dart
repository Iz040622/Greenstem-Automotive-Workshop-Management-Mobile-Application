import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mad_assignment/widgets/staff_gradient_scaffold.dart';
import 'package:mad_assignment/res/design.dart';

class ServiceDetailPage extends StatelessWidget {
  final Map<String, dynamic> service;

  const ServiceDetailPage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return ServiceDetail(service: service);
  }
}

class ServiceDetail extends StatefulWidget {
  final Map<String, dynamic> service;

  const ServiceDetail({super.key, required this.service});

  @override
  State<ServiceDetail> createState() => _ServiceDetailState();
}

class _ServiceDetailState extends State<ServiceDetail> {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  late String serviceStatus;
  late String bookingStatus;

  @override
  void initState() {
    super.initState();
    // Fetch the value from DB
    String? dbValue = widget.service['serviceStatus'];
    // Make sure it matches one of the options
    if (dbValue == 'Pending' ||
        dbValue == 'In Repair' ||
        dbValue == 'Ready For Collection') {
      serviceStatus = dbValue!;
    } else {
      serviceStatus = 'Pending';
    }
    bookingStatus = widget.service['bookingStatus'] ?? 'Upcoming';
  }

  Future<void> _updateStatus() async {
    final bookingId = widget.service['bookingId'];
    Map<String, dynamic> updateData = {'ServiceStatus': serviceStatus};

    try {
      await db.child('Booking').child(bookingId).update(updateData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StaffGradientScaffold(
      appBar: StaffGradientScaffold.dynamicAppBar(
        context: context,
        widget: const Text("Staff"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle + Plate
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffA9C7FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "${widget.service["vehicleModel"]}\n${widget.service["plate"]}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xff0A01BF),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Info rows
              _infoRow(Icons.calendar_today, "Date", widget.service["date"]),
              _divider(),
              _infoRow(Icons.access_time, "Time", widget.service["time"]),
              _divider(),
              _infoRow(
                Icons.directions_car,
                "Vehicle",
                widget.service["vehicleModel"],
              ),
              _divider(),
              _infoRow(
                Icons.confirmation_number,
                "Plate Number",
                widget.service["plate"],
              ),
              _divider(),

              // Service tasks
              const Text(
                "Service",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: widget.service["tasks"].map<Widget>((task) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          serviceIcons[task] ?? Icons.miscellaneous_services,
                          size: 18,
                          color: const Color(0xff0A01BF),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          task,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xff0A01BF),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // BookingStatus row with dropdown
              Row(
                children: [
                  const Text(
                    "Status:",
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
                        color: Colors.white.withOpacity(0.9),
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
                          value: serviceStatus,
                          isExpanded: false,
                          dropdownColor: Colors.white.withOpacity(0.95),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xff0A01BF),
                          ),
                          style: const TextStyle(
                            color: Color(0xff0A01BF),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "Pending",
                              child: Text("Pending"),
                            ),
                            DropdownMenuItem(
                              value: "In Repair",
                              child: Text("In Repair"),
                            ),
                            DropdownMenuItem(
                              value: "Ready For Collection",
                              child: Text("Ready For Collection"),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              serviceStatus = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _updateStatus();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA9C7FE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(color: Color(0xff0A01BF)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFAFAF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Color(0xFFB77065)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.black, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(color: Colors.black, thickness: 1, height: 16);
  }
}