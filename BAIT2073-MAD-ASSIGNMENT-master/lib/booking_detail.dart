import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mad_assignment/model/vehicle.dart';
import 'package:mad_assignment/res/design.dart';
import 'package:mad_assignment/widgets/alert_dialog.dart';
import 'package:mad_assignment/widgets/booking_service_card.dart';
import 'package:mad_assignment/widgets/button.dart';
import 'package:mad_assignment/widgets/gradient_scaffold.dart';
import 'package:mad_assignment/widgets/snackbar.dart';
import 'package:mad_assignment/notification.dart';
import 'package:mad_assignment/main.dart';
import 'package:mad_assignment/Payment/payment.dart';
import 'package:mad_assignment/Payment/invoice.dart';
import 'package:mad_assignment/Feedback/feedback.dart';
import 'package:mad_assignment/services/user_storage_service.dart';

import 'make_booking.dart';
import 'model/service.dart';
import 'model/booking.dart' as booking_model;
import 'model/booking_service.dart' as booking_service_model;

class BookingDetailPage extends StatelessWidget {
  final booking_model.Booking booking;
  final Vehicle vehicle;

  const BookingDetailPage({
    super.key,
    required this.booking,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: GradientScaffold.dynamicAppBar(
        context: context,
        widget: const Text("Booking"),
      ),
      body: BookingDetail(booking: booking, vehicle: vehicle),
    );
  }
}

class BookingDetail extends StatefulWidget {
  final booking_model.Booking booking;
  final Vehicle vehicle;

  const BookingDetail({
    super.key,
    required this.booking,
    required this.vehicle,
  });

  @override
  State<BookingDetail> createState() => _BookingDetailState();
}

class _BookingDetailState extends State<BookingDetail> {
  late final dynamic displays;
  late final Map<String, String> details;
  List<String>? _services;
  bool _isLoading = true;
  bool _hasFeedback = false;

  @override
  void initState() {
    super.initState();

    displays = bookingStatusDesign(widget.booking.bookingStatus);

    details = {
      "Date": DateFormat("d/M/y").format(widget.booking.appointmentDate),
      "Time": formatTime(widget.booking.appointmentTime),
      "Vehicle": widget.vehicle.vehicleModel,
      "Plate Number": widget.vehicle.carPlateNumber,
      "Estimated Time": widget.booking.estimatedDuration.inMinutes > 60
            ? '${widget.booking.estimatedDuration.inHours} Hours ${widget.booking.estimatedDuration.inMinutes.remainder(60)} Minutes'
            : '${widget.booking.estimatedDuration.inMinutes} Minutes',
      "Cost": "RM${widget.booking.cost.toStringAsFixed(2)}",
    };

    _loadBookedServices();
    if (widget.booking.bookingStatus == 'Completed') {
      _checkFeedbackStatus();
    }
  }

  Future<void> _loadBookedServices() async {
    final bookingServices =
        await booking_service_model
            .BookingServiceService.getAllBookingServicesByBooking(
          widget.booking.bookingId,
        );
    final services = await getServicesFromBookingServices(
      bookingServices
          .map((bookingService) => bookingService.serviceId)
          .toList(),
    );

    setState(() {
      _services = services;
      _isLoading = false;
    });
  }

  Future<void> _checkFeedbackStatus() async {
    try {
      final userId = await UserStorageService.getUserId();
      if (userId == null) {
        print('User ID is null');
        return;
      }

      print('Checking feedback for userId: $userId, bookingId: ${widget.booking.bookingId}');

      final database = FirebaseDatabase.instance;
      final feedbackRef = database.ref('Feedback');
      final snapshot = await feedbackRef.get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        bool hasFeedback = false;

        print('Found ${data.length} feedback entries');

        data.forEach((key, value) {
          final feedback = Map<String, dynamic>.from(value);
          print('Checking feedback: userId=${feedback['userId']}, bookingId=${feedback['bookingId']}');
          
          if (feedback['userId'] == userId && feedback['bookingId'] == widget.booking.bookingId) {
            hasFeedback = true;
            print('Found matching feedback!');
          }
        });

        print('Has feedback: $hasFeedback');

        if (mounted) {
          setState(() {
            _hasFeedback = hasFeedback;
          });
        }
      } else {
        print('No feedback data found');
      }
    } catch (e) {
      print('Error checking feedback status: $e');
    }
  }

  Future<List<String>> getServicesFromBookingServices(
    List<String> serviceIds,
  ) async {
    List<String> services = [];
    for (var serviceId in serviceIds) {
      Service? service = await ServiceService.getServiceById(serviceId);
      services.add(service!.serviceName);
    }
    return services;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          SizedBox(height: 15),
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
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                  decoration: BoxDecoration(
                    color: displays['backgroundColor'],
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
                    children: [
                      Text(
                        widget.booking.bookingStatus,
                        style: TextStyle(
                          color: displays['textColor'],
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.booking.bookingStatus == 'Ongoing')
                        Text(
                          widget.booking.serviceStatus!,
                          style: TextStyle(
                            color: displays['textColor'],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  decoration: BoxDecoration(
                    color: displays['backgroundColor'],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.1 * 255).toInt()),
                        blurRadius: 4,
                        offset: Offset(0, 4), // Offset
                      ),
                    ],
                  ),
                  child: Icon(
                    displays['icon'],
                    size: 32,
                    color: displays['textColor'],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 25),
          BookingServiceCard(details: details, services: _services!,),
          SizedBox(height: 12),
          if (widget.booking.bookingStatus == 'Upcoming')
            Button(
              backgroundColor: Color(0xFFFEA9A9),
              foregroundColor: Color(0xFFD70004),
              iconData: Icons.close,
              label: 'Cancel Booking',
              action: () async{
                bool? cancel = await showAlertDialog(
                  context,
                  "Cancel Booking?",
                  null,
                  [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Back',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Cancel booking',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                );

                if (cancel!){
                    await booking_model.BookingService.cancelBooking(widget.booking.bookingId);

                    // Send booking cancellation notification
                    await firebaseAPI.sendBookingNotification(
                      'Booking Cancelled',
                      'Your ${widget.vehicle.vehicleModel} (${widget.vehicle.carPlateNumber}) service appointment for ${DateFormat("d/M/y").format(widget.booking.appointmentDate)} at ${widget.booking.appointmentTime.format(context)} has been cancelled.',
                      widget.booking.bookingId,
                    );

                    showSnackbar(context, Text("Booking cancelled successfully", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center,), null);

                    Future.delayed(Duration(seconds: 2), () {
                      Navigator.pop(context, "true");
                    });
                }
              },
            )
          else if (widget.booking.bookingStatus == 'Cancelled' ||
              widget.booking.bookingStatus == 'Missed')
            Button(
              backgroundColor: Color(0xFFFEA9A9),
              foregroundColor: Color(0xFFD70004),
              iconData: Icons.sticky_note_2,
              label: 'Make a Booking Again',
              action: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MakeBooking(),
                  ),
                );
              },
            )
          else if (widget.booking.bookingStatus == 'Completed')
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: Button(
                    backgroundColor: Color(0xFFC2FEA9),
                    foregroundColor: Color(0xFF20BF01),
                    iconData: Icons.note,
                    label: 'View Invoice',
                    action: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InvoicePage(
                            booking: widget.booking,
                            vehicle: widget.vehicle,
                            paymentMethod: 'Credit/Debit Card', // Default, could be improved
                            totalAmount: widget.booking.cost,
                            services: _services ?? [],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.52,
                  child: Button(
                    backgroundColor: Color(0xFFFFFFAF),
                    foregroundColor: Color(0xFFACB737),
                    iconData: Icons.star,
                    label: _hasFeedback ? 'View Feedback' : 'Share Your Feedback',
                    action: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FeedbackPage(
                            isViewMode: _hasFeedback,
                            bookingId: widget.booking.bookingId,
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            )
          else
            if (widget.booking.serviceStatus == "Ready For Collection")
              Button(
                backgroundColor: Color(0xFFAFEBFF),
                foregroundColor: Color(0xFF3780B7),
                iconData: Icons.payment,
                label: 'Make Payment',
                action: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentPage(
                        booking: widget.booking,
                        vehicle: widget.vehicle,
                        service: _services!,
                      ), //Payment
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }
}
