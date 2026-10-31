import 'package:flutter/material.dart';
import 'package:mad_assignment/widgets/booking_list_item.dart';
import 'package:mad_assignment/services/user_storage_service.dart';

import 'model/booking.dart';
import 'model/vehicle.dart';

class BookingList extends StatefulWidget {
  const BookingList({super.key});

  @override
  State<BookingList> createState() => _BookingListState();
}

class _BookingListState extends State<BookingList> {
  List<Booking>? _sortedBookings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      // Get current user ID
      final userId = await UserStorageService.getUserId();
      if (userId == null) {
        setState(() {
          _sortedBookings = [];
          _isLoading = false;
        });
        return;
      }

      // Get user's vehicles
      final vehicles = await VehicleService.getAllVehiclesByUser(userId);
      if (vehicles.isEmpty) {
        setState(() {
          _sortedBookings = [];
          _isLoading = false;
        });
        return;
      }

      // Get bookings for user's vehicles
      final bookings = await BookingService.getAllBookingsByVehicles(vehicles);
      final sortedBookings = [...bookings];
      sortedBookings.sort((a, b) {
        int dateCompare = b.appointmentDate.compareTo(a.appointmentDate);
        if (dateCompare != 0) return dateCompare;

        return b.appointmentTime.hour.compareTo(a.appointmentTime.hour) != 0
            ? b.appointmentTime.hour.compareTo(a.appointmentTime.hour)
            : b.appointmentTime.minute.compareTo(a.appointmentTime.minute);
      });

      setState(() {
        _sortedBookings = sortedBookings;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading bookings: $e');
      setState(() {
        _sortedBookings = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _reloadBookings() async {
    setState(() {
      _isLoading = true;
    });
    await _loadBookings();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_sortedBookings!.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: _reloadBookings,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            SizedBox(height: 35),
            for (var booking in _sortedBookings!) ...[
              BookingListItem(booking: booking, onBookingUpdated: _reloadBookings,),
              SizedBox(height: 16),
            ],
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 32),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Image.asset(
            'assets/images/no_booking_car_icon.png',
            width: 200,
            height: 100,
          ),
          const SizedBox(height: 25),
          Text(
            "Oops! No Booking Yet!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'You haven’t booked any service appointments yet. Tap the "+" button at the bottom right to schedule your first service now!',
            style: TextStyle(fontSize: 15, color: Colors.black38),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
