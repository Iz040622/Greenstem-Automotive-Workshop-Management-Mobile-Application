import 'package:firebase_database/firebase_database.dart';

class ServicePrice {
  final String servicePriceId;
  final String vehicleType;
  final double price;
  final String serviceId;

  ServicePrice({
    required this.servicePriceId,
    required this.vehicleType,
    required this.price,
    required this.serviceId,
  });

  factory ServicePrice.fromMap(
    String servicePriceId,
    Map<String, dynamic> map,
  ) {
    return ServicePrice(
      servicePriceId: servicePriceId,
      vehicleType: map['VehicleType'],
      price: (map["Price"] is int)
          ? (map["Price"] as int).toDouble()
          : (map["Price"] as double),
      serviceId: map['ServiceId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'VehicleType': vehicleType,
      'Price': price,
      'ServiceId': serviceId,
    };
  }
}

class ServicePriceService {
  static final DatabaseReference dbRef = FirebaseDatabase.instance.ref(
    'ServicePrice',
  );

  static Future<double> getCostByVehicleModelAndService(
    String vehicleType,
    String serviceId,
  ) async {
    final snapshot = await dbRef.get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;

      final servicePrices = data.entries
          .where((entry) {
            final servicePrice = Map<String, dynamic>.from(entry.value);
            return servicePrice["ServiceId"] == serviceId;
          })
          .map(
            (entry) => ServicePrice.fromMap(
              entry.key,
              Map<String, dynamic>.from(entry.value),
            ),
          )
          .toList();

      for (final servicePrice in servicePrices){
        if (servicePrice.vehicleType == vehicleType){
          return servicePrice.price;
        }
      }
    }
    return 0;
  }
}
