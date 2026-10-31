import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mad_assignment/model/vehicle.dart';
import 'package:mad_assignment/model/booking.dart';

import '../booking_detail.dart';
import '../res/design.dart';

class BookingListItem extends StatefulWidget {
  final Booking booking;
  final VoidCallback onBookingUpdated;

  const BookingListItem({super.key, required this.booking, required this.onBookingUpdated});

  @override
  State<BookingListItem> createState() => _BookingListItemState();
}

class _BookingListItemState extends State<BookingListItem> {
  Vehicle? _vehicle;
  bool _isLoading = true;
  late final dynamic displays;

  @override
  void initState() {
    super.initState();
    displays = bookingStatusDesign(widget.booking.bookingStatus);
    _loadVehicle();
  }

  Future<void> _loadVehicle() async {
    final vehicle = await VehicleService.getVehicleById(
      widget.booking.vehicleId,
    );

    setState(() {
      _vehicle = vehicle;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Container(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Column(
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
                child: Text(
                  widget.booking.bookingStatus,
                  style: TextStyle(
                    color: displays['textColor'],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
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
                child: Icon(displays['icon'], size: 32, color: displays['textColor']),
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  DateFormat("d MMMM yyyy").format(widget.booking.appointmentDate).toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Car Model: ${_vehicle!.vehicleModel}",
                  style: TextStyle(fontSize: 10, color: Colors.black),
                ),
                SizedBox(height: 6),
                Text(
                  "Plate Number: ${_vehicle!.carPlateNumber}",
                  style: TextStyle(fontSize: 10, color: Colors.black),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final update = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingDetailPage(booking: widget.booking, vehicle: _vehicle!,),
                ),
              );

              if (update == "true"){
                setState(() {
                  widget.onBookingUpdated();
                });
              }
            },
            child: Container(
              margin: EdgeInsets.only(left: 10),
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Color(0xFFA7E7FA).withAlpha((0.8 * 255).toInt()),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.1 * 255).toInt()),
                    blurRadius: 4,
                    offset: Offset(0, 4), // Offset
                  ),
                ],
              ),
              child: Icon(Icons.double_arrow, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
