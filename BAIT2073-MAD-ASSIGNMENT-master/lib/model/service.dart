import 'package:firebase_database/firebase_database.dart';

class Service{
  final String serviceId;
  final String serviceName;
  final Duration serviceDuration;

  Service({
    required this.serviceId,
    required this.serviceName,
    required this.serviceDuration,
  });

  factory Service.fromMap(String serviceId, Map<String, dynamic> map) {
    return Service(
      serviceId: serviceId,
      serviceName: map['ServiceName'],
      serviceDuration: Duration(minutes: map['ServiceDuration']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ServiceName': serviceName,
      'ServiceDuration': serviceDuration.inMinutes,
    };
  }
}

class ServiceService{
  static final DatabaseReference dbRef = FirebaseDatabase.instance.ref('Service');

  // //Get all services
  static Future<List<Service>> getAllServices() async{
    final snapshot = await dbRef.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      return data.entries.map((entry) {
        return Service.fromMap(entry.key, Map<String, dynamic>.from(entry.value));
      }).toList();
    }
    return [];
  }

  //Get service by ID
  static Future<Service?> getServiceById(String serviceId) async{
    final snapshot = await dbRef.child(serviceId).get();

    if (snapshot.exists) {
      return Service.fromMap(serviceId, Map<String, dynamic>.from(snapshot.value as Map));
    }
    return null;
  }
}