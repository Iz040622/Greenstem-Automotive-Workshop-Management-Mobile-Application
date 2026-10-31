import 'package:firebase_database/firebase_database.dart';

class Vehicle{
  final String vehicleId;
  final String vehicleType;
  final String vehicleModel;
  final String carPlateNumber;
  final String userId;

  Vehicle({
    required this.vehicleId,
    required this.vehicleType,
    required this.vehicleModel,
    required this.carPlateNumber,
    required this.userId,
  });

  factory Vehicle.fromMap(String vehicleId, Map<String, dynamic> map) {
    return Vehicle(
      vehicleId: vehicleId,
      vehicleType: map['VehicleType'],
      vehicleModel: map['VehicleModel'],
      carPlateNumber: map["CarPlateNumber"],
      userId: map['UserId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'VehicleType': vehicleType,
      'VehicleModel': vehicleModel,
      'CarPlateNumber': carPlateNumber,
      'UserId': userId,
    };
  }
}

class VehicleService{
  static final DatabaseReference dbRef = FirebaseDatabase.instance.ref('Vehicle');

  // Get all vehicles by user ID
  static Future<List<Vehicle>> getAllVehiclesByUser(String userId) async {
    final snapshot = await dbRef
        .orderByChild('UserId')
        .equalTo(userId)
        .get();

    if (snapshot.exists) {
      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        return Vehicle.fromMap(entry.key, Map<String, dynamic>.from(entry.value));
      }).toList();
    }
    return [];
  }

  //Get vehicle by ID
  static Future<Vehicle?> getVehicleById(String vehicleId) async{
    final snapshot = await dbRef.child(vehicleId).get();

    if (snapshot.exists) {
      return Vehicle.fromMap(vehicleId, Map<String, dynamic>.from(snapshot.value as Map));
    }
    return null;
  }
}