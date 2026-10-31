import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mad_assignment/staff/newBooking.dart';
import 'package:mad_assignment/staff/serviceDetail.dart';
import 'package:mad_assignment/widgets/staff_gradient_scaffold.dart';
import 'package:mad_assignment/res/design.dart';
import 'dart:async';

class ServiceListPage extends StatelessWidget {
  const ServiceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ServiceList();
  }
}

class ServiceList extends StatefulWidget {
  const ServiceList({super.key});

  @override
  State<ServiceList> createState() => _ServiceListState();
}

class _ServiceListState extends State<ServiceList> {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  List<Map<String, dynamic>> services = [];
  bool isLoading = true;
  int upcomingCount = 0;

  StreamSubscription<DatabaseEvent>? _servicesSub;
  StreamSubscription<DatabaseEvent>? _upcomingSub;

  @override
  void initState() {
    super.initState();
    _listenServices();
    _listenUpcomingCount();
  }

  ///Listen to real-time changes in "Ongoing" bookings
  void _listenServices() {
    _servicesSub = db
        .child('Booking')
        .orderByChild('BookingStatus')
        .equalTo('Ongoing')
        .onValue
        .listen((event) async {
      final bookingSnapshot = event.snapshot;
      List<Map<String, dynamic>> tempServices = [];

      for (var booking in bookingSnapshot.children) {
        final bookingData = booking.value as Map<dynamic, dynamic>;
        final vehicleId = bookingData['VehicleId'] ?? '';

        // Vehicle info
        final vehicleSnapshot =
        await db.child('Vehicle').child(vehicleId).get();
        final vehicleData =
        vehicleSnapshot.exists ? vehicleSnapshot.value as Map : {};

        // Services linked to booking
        final bookingServiceSnapshot = await db
            .child('BookingService')
            .orderByChild('BookingId')
            .equalTo(booking.key)
            .get();

        List<String> serviceNames = [];
        for (var bs in bookingServiceSnapshot.children) {
          final serviceId = (bs.value as Map)['ServiceId'];
          final serviceSnapshot = await db.child('Service').child(serviceId).get();
          if (serviceSnapshot.exists) {
            final serviceData = serviceSnapshot.value as Map;
            serviceNames.add(serviceData['ServiceName'] ?? '');
          }
        }

        tempServices.add({
          'bookingId': booking.key,
          'date': bookingData['AppointmentDate'] ?? '',
          'time': bookingData['AppointmentTime'] ?? '',
          'bookingStatus': bookingData['BookingStatus'] ?? 'Upcoming',
          'serviceStatus': bookingData['ServiceStatus'] ?? 'Pending',
          'vehicleModel': vehicleData['VehicleModel'] ?? '',
          'plate': vehicleData['CarPlateNumber'] ?? '',
          'tasks': serviceNames,
        });
      }

      setState(() {
        services = tempServices;
        isLoading = false;
      });
    });
  }

  /// Listen to count of "Upcoming" bookings
  void _listenUpcomingCount() {
    _upcomingSub = db
        .child('Booking')
        .orderByChild('BookingStatus')
        .equalTo('Upcoming')
        .onValue
        .listen((event) {
      setState(() {
        upcomingCount = event.snapshot.children.length;
      });
    });
  }

  @override
  void dispose() {
    _servicesSub?.cancel();
    _upcomingSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StaffGradientScaffold(
      appBar: StaffGradientScaffold.dynamicAppBar(
        context: context,
        widget: const Text("Staff"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Top buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ServiceListPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.build, size: 18),
                    label: const Text("Ongoing Service"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffA9C7FE),
                      foregroundColor: const Color(0xff0A01BF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const NewBookingPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.book_online, size: 18),
                          label: const Text("New Booking"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffA9C7FE),
                            foregroundColor: const Color(0xff0A01BF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // Notification badge
                      if (upcomingCount > 0)
                        Positioned(
                          right: 8,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "$upcomingCount",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.build, color: Color(0xff0A01BF)),
                  SizedBox(width: 8),
                  Text(
                    "Ongoing Services",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff0A01BF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            //Service list
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : services.isEmpty
                  ? const Center(
                child: Text(
                  "No ongoing services yet",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0A01BF),
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return _buildServiceCard(service);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'pending':
          return Colors.orange;
        case 'in repair':
          return Colors.blue;
        case 'ready for collection':
          return Colors.green;
        default:
          return Colors.grey;
      }
    }

    final String status = service["serviceStatus"] ?? "Pending";
    final Color statusColor = getStatusColor(status);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7FC),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Vehicle info + service status
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha((0.1 * 255).toInt()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffA9C7FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${service["vehicleModel"]}\n${service["plate"]}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xff0A01BF),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Details (date, time, tasks)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "${service["date"]} • ${service["time"]}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff222741),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(service["tasks"].length, (i) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.05 * 255).toInt()),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            serviceIcons[service["tasks"][i]] ?? Icons.miscellaneous_services,
                            size: 18,
                            color: const Color(0xff858585),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              service["tasks"][i],
                              style: const TextStyle(
                                color: Color(0xff808080),
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Arrow button
          InkWell(
            onTap: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ServiceDetailPage(service: service),
                ),
              );

              if (updated == true) {
                // Manual refresh if coming back from details
                _listenServices();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x23A7E7FA),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withAlpha((0.3 * 255).toInt()),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_forward, color: Color(0xff1A1A71)),
            ),
          ),
        ],
      ),
    );
  }
}