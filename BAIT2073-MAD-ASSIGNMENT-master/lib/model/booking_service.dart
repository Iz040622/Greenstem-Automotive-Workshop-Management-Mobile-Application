import 'package:firebase_database/firebase_database.dart';

class BookingService{
  final String bookingServiceId;
  final String bookingId;
  final String serviceId;

  BookingService({
    required this.bookingServiceId,
    required this.bookingId,
    required this.serviceId,
  });

  factory BookingService.fromMap(String bookingServiceId, Map<String, dynamic> map) {
    return BookingService(
      bookingServiceId: bookingServiceId,
      bookingId: map['BookingId'],
      serviceId: map['ServiceId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'BookingId': bookingId,
      'ServiceId': serviceId,
    };
  }
}

class BookingServiceService{
  static final DatabaseReference dbRef = FirebaseDatabase.instance.ref('BookingService');

  // Get all bookingServices by booking ID
  static Future<List<BookingService>> getAllBookingServicesByBooking(String bookingId) async {
    final snapshot = await dbRef
        .orderByChild('BookingId')
        .equalTo(bookingId)
        .get();

    if (snapshot.exists) {
      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        return BookingService.fromMap(entry.key, Map<String, dynamic>.from(entry.value));
      }).toList();
    }
    return [];
  }

  static Future<void> createBookingService(Map<String, dynamic> map) async {
    final snapshot = await dbRef.get();

    int count = 0;

    if (snapshot.exists && snapshot.value != null && snapshot.value is Map) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      count = data.length;
    }

    final newBookingId = 'BS${count + 1}';

    await dbRef.child(newBookingId).set(map);
  }
}