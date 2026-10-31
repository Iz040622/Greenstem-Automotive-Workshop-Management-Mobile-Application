import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mad_assignment/model/vehicle.dart';

class Booking {
  final String bookingId;
  final DateTime appointmentDate;
  final TimeOfDay appointmentTime;
  final Duration estimatedDuration;
  final double cost;
  final String bookingStatus;
  final String? serviceStatus;
  final String vehicleId;

  Booking({
    required this.bookingId,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.estimatedDuration,
    required this.cost,
    required this.bookingStatus,
    required this.serviceStatus,
    required this.vehicleId,
  });

  DateTime get startDateTime => DateTime(
    appointmentDate.year,
    appointmentDate.month,
    appointmentDate.day,
    appointmentTime.hour,
    appointmentTime.minute,
  );

  DateTime get endDateTime => startDateTime.add(estimatedDuration);

  factory Booking.fromMap(String bookingId, Map<String, dynamic> map) {
    return Booking(
      bookingId: bookingId,
      appointmentDate: DateFormat("d/M/y").parse(map['AppointmentDate']),
      appointmentTime: TimeOfDay.fromDateTime(
        DateFormat("h:mma").parse(map['AppointmentTime']),
      ),
      estimatedDuration: Duration(minutes: map['EstimatedDuration']),
      cost: (map['Cost'] as num).toDouble(),
      bookingStatus: map['BookingStatus'],
      serviceStatus: map['ServiceStatus'] == "null"
          ? null
          : map['ServiceStatus'],
      vehicleId: map['VehicleId'],
    );
  }

  Map<String, dynamic> toMap() {
    String appointmentTimeStr = "";
    if (appointmentTime.hour > 12) {
      appointmentTimeStr += (appointmentTime.hour - 12).toString();
    } else {
      appointmentTimeStr += appointmentTime.hour.toString();
    }
    appointmentTimeStr +=
        ":${appointmentTime.minute.toString().padLeft(2, '0')}";
    appointmentTime.hour >= 12
        ? appointmentTimeStr += "PM"
        : appointmentTimeStr += "AM";

    return {
      'AppointmentDate': DateFormat("d/M/y").format(appointmentDate),
      'AppointmentTime': appointmentTimeStr,
      'EstimatedDuration': estimatedDuration.inMinutes,
      'Cost': cost,
      'BookingStatus': bookingStatus,
      'ServiceStatus': serviceStatus ?? "null",
      'VehicleId': vehicleId,
    };
  }
}

class BookingService {
  static final DatabaseReference dbRef = FirebaseDatabase.instance.ref(
    'Booking',
  );

  // Get all bookings by vehicle ID
  static Future<List<Booking>> getAllBookingsByVehicles(
    List<Vehicle> vehicles,
  ) async {
    final snapshot = await dbRef.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      final bookings = data.entries
          .where((entry) {
            final booking = Map<String, dynamic>.from(entry.value);
            return vehicles.any(
              (vehicle) => vehicle.vehicleId == booking['VehicleId'],
            );
          })
          .map(
            (entry) => Booking.fromMap(
              entry.key,
              Map<String, dynamic>.from(entry.value),
            ),
          )
          .toList();

      return bookings;
    }
    return [];
  }

  //Get soonest upcoming/ongoing booking
  static Future<Booking?> getNextBooking(List<Booking> bookings) async {
    final ongoing = bookings
        .where((booking) => booking.bookingStatus == 'Ongoing')
        .toList();
    if (ongoing.isNotEmpty) {
      return _getEarliestBooking(ongoing);
    }

    final upcoming = bookings
        .where((booking) => booking.bookingStatus == 'Upcoming')
        .toList();
    if (upcoming.isNotEmpty) {
      return _getEarliestBooking(upcoming);
    }

    return null;
  }

  //Helper method to get soonest booking
  static Booking? _getEarliestBooking(List<Booking> bookings) {
    bookings.sort((a, b) {
      if (a.appointmentDate.compareTo(b.appointmentDate) != 0) {
        return a.appointmentDate.compareTo(b.appointmentDate);
      }
      return a.appointmentTime.compareTo(b.appointmentTime);
    });

    return bookings.first;
  }

  static Future<void> cancelBooking(String bookingId) async {
    final bookingRef = dbRef.child(bookingId);

    final snapshot = await bookingRef.get();
    if (!snapshot.exists) {
      throw Exception('Booking with ID $bookingId does not exist.');
    }

    await bookingRef.update({
      'BookingStatus': 'Cancelled',
    });
  }

  static Future<void> completeBooking(String bookingId) async {
    final bookingRef = dbRef.child(bookingId);

    final snapshot = await bookingRef.get();
    if (!snapshot.exists) {
      throw Exception('Booking with ID $bookingId does not exist.');
    }

    await bookingRef.update({
      'BookingStatus': 'Completed',
    });
  }

  static Future<List<Booking>> getBookingsByPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await dbRef.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return data.entries.map((entry) {
        return Booking.fromMap(entry.key, Map<String, dynamic>.from(entry.value));
      }).where((booking) {
        return booking.appointmentDate.isAfter(startDate.subtract(Duration(days: 1))) &&
            booking.appointmentDate.isBefore(endDate.add(Duration(days: 1)));
      }).toList();
    }

    return [];
  }

  static Future<String> createBooking(Map<String, dynamic> map) async {
    final snapshot = await dbRef.get();

    int count = 0;

    if (snapshot.exists && snapshot.value != null && snapshot.value is Map) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      count = data.length;
    }

    final newBookingId = 'B${count + 1}';

    await dbRef.child(newBookingId).set(map);
    return newBookingId;
  }
}