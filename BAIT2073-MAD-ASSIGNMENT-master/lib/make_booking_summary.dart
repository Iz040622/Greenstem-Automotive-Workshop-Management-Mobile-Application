import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mad_assignment/model/service_price.dart';
import 'package:mad_assignment/res/design.dart';
import 'package:mad_assignment/widgets/alert_dialog.dart';
import 'package:mad_assignment/widgets/booking_service_card.dart';
import 'package:mad_assignment/widgets/button.dart';
import 'package:mad_assignment/widgets/snackbar.dart';
import 'package:mad_assignment/notification.dart';
import 'package:mad_assignment/main.dart';
import 'model/service.dart';
import 'model/vehicle.dart';
import 'model/booking.dart' as booking;
import 'model/booking_service.dart' as booking_service;

class MakeBookingSummary extends StatefulWidget {
  const MakeBookingSummary({
    super.key,
    required this.vehicleId,
    required this.selectedServiceList,
    required this.estimatedDuration,
    required this.selectedDate,
    required this.selectedTime,
    required this.onNext,
  });

  final String vehicleId;
  final List<Service> selectedServiceList;
  final Duration estimatedDuration;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final VoidCallback onNext;

  @override
  State<MakeBookingSummary> createState() => _MakeBookingSummaryState();
}

class _MakeBookingSummaryState extends State<MakeBookingSummary> {
  bool _isLoading = true;
  late final Map<String, String> details;
  List<String>? selectedServiceStrList;
  double _cost = 0;

  Future<void> _loadData() async {
    final vehicle = await VehicleService.getVehicleById(widget.vehicleId);
    String? vehicleType = vehicle?.vehicleType;
    String? vehicleModel = vehicle?.vehicleModel;
    String? plateNumber = vehicle?.carPlateNumber;

    double cost = 0;
    for (final service in widget.selectedServiceList) {
      double price = await ServicePriceService.getCostByVehicleModelAndService(
        vehicleType ?? "",
        service.serviceId,
      );
      cost += price;
    }

    _cost = cost;

    details = {
      "Date": DateFormat("d/M/y").format(widget.selectedDate),
      "Time": formatTime(widget.selectedTime),
      "Vehicle": vehicleModel ?? "",
      "Plate Number": plateNumber ?? "",
      "Estimated Time": widget.estimatedDuration.inMinutes > 60
          ? '${widget.estimatedDuration.inHours} Hours ${widget.estimatedDuration.inMinutes.remainder(60)} Minutes'
          : '${widget.estimatedDuration.inMinutes} Minutes',
      "Cost": cost.toStringAsFixed(2),
    };

    selectedServiceStrList = widget.selectedServiceList
        .map((service) => service.serviceName)
        .toList();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
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
            "Booking Summary",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 40),
          BookingServiceCard(
            details: details,
            services: selectedServiceStrList!,
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Button(
              backgroundColor: Color(0xFFC2FEA9),
              foregroundColor: Color(0xFF20BF01),
              label: 'Confirm Booking',
              action: () async{
                bool? book = await showAlertDialog(
                  context,
                  "Confirm Booking?",
                  null,
                  [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Confirm booking',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                );

                if (book!) {
                  final newBooking = booking.Booking(
                    bookingId: '',
                    appointmentDate: widget.selectedDate,
                    appointmentTime: widget.selectedTime,
                    estimatedDuration: widget.estimatedDuration,
                    cost: _cost,
                    bookingStatus: 'Upcoming',
                    serviceStatus: null,
                    vehicleId: widget.vehicleId,
                  );

                  String bookingId = await booking.BookingService.createBooking(newBooking.toMap());
                  for (final service in widget.selectedServiceList){
                    final serviceBooking = booking_service.BookingService(
                      bookingServiceId: '',
                      bookingId: bookingId,
                      serviceId: service.serviceId,
                    );

                    await booking_service.BookingServiceService.createBookingService(serviceBooking.toMap());
                  }

                  // Send booking confirmation notification
                  final vehicle = await VehicleService.getVehicleById(widget.vehicleId);
                  if (vehicle != null) {
                    await firebaseAPI.sendBookingNotification(
                      'Booking Confirmed',
                      'Your ${vehicle.vehicleModel} (${vehicle.carPlateNumber}) service appointment has been confirmed for ${DateFormat("d/M/y").format(widget.selectedDate)} at ${widget.selectedTime.format(context)}.',
                      bookingId,
                    );
                  }

                  showSnackbar(context, Text("Booking made successfully", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center,), null);

                  Future.delayed(Duration(seconds: 2), () {
                    widget.onNext();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
