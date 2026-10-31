import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mad_assignment/staff/serviceList.dart';
import 'package:mad_assignment/widgets/staff_gradient_scaffold.dart';

class NewBookingPage extends StatelessWidget {
  const NewBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const NewBooking();
  }
}

class NewBooking extends StatefulWidget {
  const NewBooking({super.key});

  @override
  State<NewBooking> createState() => _NewBookingState();
}

class _NewBookingState extends State<NewBooking> {
  final DatabaseReference rootDb = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => isLoading = true);

    final snapshot = await rootDb
        .child('Booking')
        .orderByChild('BookingStatus')
        .equalTo('Upcoming')
        .get();

    final List<Map<String, dynamic>> loadedBookings = [];

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      final futures = data.entries.map((entry) async {
        final bookingKey = entry.key;
        Map<String, dynamic> booking = Map<String, dynamic>.from(entry.value);
        booking['id'] = bookingKey;

        final vehicleId = booking['VehicleId'];
        final vehicleSnapshot = await rootDb
            .child('Vehicle')
            .child(vehicleId)
            .get();
        if (vehicleSnapshot.exists) {
          final vehicleData = vehicleSnapshot.value as Map<dynamic, dynamic>;
          booking['vehicleModel'] = vehicleData['VehicleModel'] ?? '';
          booking['plate'] = vehicleData['CarPlateNumber'] ?? vehicleId;
        } else {
          booking['vehicleModel'] = '';
          booking['plate'] = vehicleId;
        }

        final bookingServiceSnapshot = await rootDb
            .child('BookingService')
            .orderByChild('BookingId')
            .equalTo(bookingKey)
            .get();
        List<String> serviceNames = [];

        for (var bs in bookingServiceSnapshot.children) {
          final serviceId = (bs.value as Map<dynamic, dynamic>)['ServiceId'];
          final serviceSnapshot = await rootDb
              .child('Service')
              .child(serviceId)
              .get();
          if (serviceSnapshot.exists) {
            final serviceData = serviceSnapshot.value as Map<dynamic, dynamic>;
            serviceNames.add(serviceData['ServiceName'] ?? '');
          }
        }

        booking['tasks'] = serviceNames;
        return booking;
      }).toList();

      loadedBookings.addAll(await Future.wait(futures));
    }

    setState(() {
      bookings = loadedBookings;
      isLoading = false;
    });
  }

  Future<void> _confirmBooking(Map<String, dynamic> booking) async {
    final bookingId = booking['id'];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Booking"),
          content: const Text("Are you sure you want to confirm this booking?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (confirm != null && confirm) {
      try {
        await rootDb.child('Booking').child(bookingId).update({
          'BookingStatus': 'Ongoing',
          'ServiceStatus': 'Pending',
        });

        setState(() {
          bookings.removeWhere((b) => b['id'] == bookingId);
        });

        // Fetch vehicle first
        final vehicleId = booking['VehicleId'];
        final vehicleSnapshot = await rootDb
            .child('Vehicle')
            .child(vehicleId)
            .get();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booking confirmed!')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error confirming booking: $e')));
      }
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top buttons
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
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NewBookingPage(),
                        ),
                      );
                    },
                    label: const Text("New Booking"),
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
                    "New Booking",
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

            // Service list
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : bookings.isEmpty
                  ? const Center(
                      child: Text(
                        "No new booking yet",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff0A01BF),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final service = bookings[index];
                        return _buildBookingCard(service);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F7FC),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Vehicle info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xffA9C7FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${booking['vehicleModel']}\n${booking['plate']}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xff0A01BF),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "${booking['AppointmentDate']} • ${booking['AppointmentTime']}",
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
                  children: List.generate(booking['tasks']?.length ?? 0, (i) {
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
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            i == 0 ? Icons.opacity : Icons.settings,
                            size: 18,
                            color: const Color(0xff858585),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              booking['tasks'][i],
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

          // Confirm button
          Container(
            margin: const EdgeInsets.only(left: 8), // space from services
            child: InkWell(
              onTap: () => _confirmBooking(booking),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xffA7E7FA),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xff1A1A71),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
