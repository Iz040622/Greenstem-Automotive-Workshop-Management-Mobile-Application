import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:mad_assignment/main.dart';
import 'package:mad_assignment/widgets/gradient_scaffold.dart';
import 'package:mad_assignment/services/user_storage_service.dart';
import 'package:mad_assignment/model/vehicle.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

void handleMessage(RemoteMessage? message) {
  if (message != null) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => NotificationPage(),
      ),
    );
  }
}

class FirebaseAPI {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _androidChannel = const AndroidNotificationChannel(
    "high_importance_channel",
    "High Importance Notifications",
    description: "This channel is used for important notification",
    importance: Importance.high,
  );
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _database = FirebaseDatabase.instance;
  
  // Timer for auto notifications
  Timer? notificationTimer;
  
  // Stream subscription for booking changes
  StreamSubscription<DatabaseEvent>? bookingSubscription;

  Future<void> initNotification() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    print("Token: $fCMToken");
    await initLocalNotification();
    await initPushNotifications();
    
    // Start listening to booking changes
    startListeningToBookings();
  }

  Future initLocalNotification() async {
    const android = AndroidInitializationSettings('@drawable/logo');
    const settings = InitializationSettings(android: android);
    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          final message = RemoteMessage.fromMap(jsonDecode(details.payload!));
          handleMessage(message);
        }
      },
    );

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future initPushNotifications() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
            ),
          ),
          payload: jsonEncode(message.toMap()),
        );
      }
    });
  }

  // Start listening to booking changes
  void startListeningToBookings() async {
    try {
      // Get current user ID
      final userId = await UserStorageService.getUserId();
      if (userId == null) return;

      // Get user's vehicles
      final vehicles = await VehicleService.getAllVehiclesByUser(userId);
      if (vehicles.isEmpty) return;

      // Listen to booking changes
      bookingSubscription = _database.ref('Booking').onChildChanged.listen((event) {
        _handleBookingChange(event);
      });

      // Also listen to new bookings
      _database.ref('Booking').onChildAdded.listen((event) {
        _handleBookingChange(event);
      });

      print('Started listening to booking changes');
    } catch (e) {
      print('Error starting booking listener: $e');
    }
  }

  // Stop listening to booking changes
  void stopListeningToBookings() {
    bookingSubscription?.cancel();
    bookingSubscription = null;
    print('Stopped listening to booking changes');
  }

  // Handle booking changes
  Future<void> _handleBookingChange(DatabaseEvent event) async {
    try {
      final bookingData = event.snapshot.value as Map<dynamic, dynamic>?;
      if (bookingData == null) return;

      final booking = Map<String, dynamic>.from(bookingData);
      final bookingId = event.snapshot.key!;
      
      // Get current user ID and check if user is still logged in
      final userId = await UserStorageService.getUserId();
      if (userId == null) {
        print('User not logged in, stopping notification listening');
        stopListeningToBookings();
        return;
      }

      // Double check with Firebase Auth to ensure user is still authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('Firebase user not authenticated, stopping notification listening');
        stopListeningToBookings();
        return;
      }

      // Get user's vehicles
      final vehicles = await VehicleService.getAllVehiclesByUser(userId);
      
      // Check if this booking belongs to the current user
      final vehicleId = booking['VehicleId'];
      final belongsToUser = vehicles.any((vehicle) => vehicle.vehicleId == vehicleId);
      
      if (!belongsToUser) return;

      // Get vehicle info for notification
      final vehicle = vehicles.firstWhere((v) => v.vehicleId == vehicleId);
      
      // Check booking status changes
      final bookingStatus = booking['BookingStatus'];
      final serviceStatus = booking['ServiceStatus'];

      // Send notification based on status
      if (bookingStatus == 'Ongoing' && serviceStatus == 'Pending') {
        await sendBookingNotification(
          'Service Started',
          'Your ${vehicle.vehicleModel} (${vehicle.carPlateNumber}) service has started.',
          bookingId,
        );
      } else if (serviceStatus == 'In Repair') {
        await sendBookingNotification(
          'Service In Progress',
          'Your ${vehicle.vehicleModel} (${vehicle.carPlateNumber}) is currently being repaired.',
          bookingId,
        );
      } else if (serviceStatus == 'Ready For Collection') {
        await sendBookingNotification(
          'Ready for Collection',
          'Your ${vehicle.vehicleModel} (${vehicle.carPlateNumber}) is ready for collection!',
          bookingId,
        );
      } else if (bookingStatus == 'Completed') {
        await sendBookingNotification(
          'Service Completed',
          'Your ${vehicle.vehicleModel} (${vehicle.carPlateNumber}) service has been completed.',
          bookingId,
        );
      }

    } catch (e) {
      print('Error handling booking change: $e');
    }
  }

  // Send booking notification
  Future<void> sendBookingNotification(String title, String body, String bookingId) async {
    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    // Show local notification
    await _localNotifications.show(
      notificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/logo',
        ),
      ),
      payload: jsonEncode({'bookingId': bookingId, 'type': 'booking_update'}),
    );
    
    // Store notification in Firebase
    await _storeNotificationInFirebase(title, body, bookingId);
    
    print('Booking notification sent: $title');
  }

  // Store notification in Firebase
  Future<void> _storeNotificationInFirebase(String title, String body, String bookingId) async {
    try {
      final userId = await UserStorageService.getUserId();
      if (userId == null) {
        print('User not logged in, skipping notification storage');
        return;
      }

      // Double check with Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('Firebase user not authenticated, skipping notification storage');
        return;
      }

      final notificationData = {
        'title': title,
        'body': body,
        'bookingId': bookingId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'read': false,
        'type': 'booking_update',
      };

      final notificationRef = _database.ref('Notifications/$userId').push();
      await notificationRef.set(notificationData);
      
      print('Notification stored in Firebase: $title');
    } catch (e) {
      print('Error storing notification in Firebase: $e');
    }
  }

  // Dispose method to clean up resources
  void dispose() {
    notificationTimer?.cancel();
    bookingSubscription?.cancel();
  }
}



class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Notification();
  }
}

class Notification extends StatefulWidget {
  const Notification({super.key});

  @override
  State<Notification> createState() => _NotificationState();
}

class _NotificationState extends State<Notification> {
  List<Map<String, dynamic>> notifications = [];
  bool _isLoading = true;
  final _database = FirebaseDatabase.instance;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh notifications when page becomes visible
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final userId = await UserStorageService.getUserId();
      if (userId == null) {
        print('User not logged in, cannot load notifications');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Double check with Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('Firebase user not authenticated, cannot load notifications');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final notificationsRef = _database.ref('Notifications/$userId');
      final snapshot = await notificationsRef.get();
      
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final notificationList = <Map<String, dynamic>>[];
        
        data.forEach((key, value) {
          final notification = value as Map<dynamic, dynamic>;
          notificationList.add({
            'id': key,
            'title': notification['title'] ?? '',
            'body': notification['body'] ?? '',
            'time': DateFormat("h:mm a").format(DateTime.fromMillisecondsSinceEpoch(notification['timestamp'] ?? 0)),
            'type': _getNotificationTypeFromData(notification),
            'timestamp': notification['timestamp'] ?? 0,
            'read': notification['read'] ?? false,
          });
        });
        
        // Sort by timestamp (newest first)
        notificationList.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
        
        setState(() {
          notifications = notificationList;
          _isLoading = false;
        });
      } else {
        setState(() {
          notifications = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getNotificationTypeFromData(Map<dynamic, dynamic> notification) {
    final type = notification['type'] ?? '';
    final title = notification['title'] ?? '';
    
    if (title.toLowerCase().contains('confirmed')) {
      return 'info';
    } else if (title.toLowerCase().contains('ready') || title.toLowerCase().contains('completed')) {
      return 'success';
    } else if (title.toLowerCase().contains('started') || title.toLowerCase().contains('progress')) {
      return 'alert';
    } else if (title.toLowerCase().contains('cancelled')) {
      return 'alert';
    }
    
    return type;
  }

  void addNotification(String title, String body, String type) {
    setState(() {
      notifications.insert(0, {
        "title": title,
        "body": body,
        "time": DateFormat("h:mm a").format(DateTime.now()),
        "type": type,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final message = ModalRoute
        .of(context)!
        .settings
        .arguments;
    return GradientScaffold(
      appBar: AppBar(
        title: const Text("Notification"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Toggle booking notifications
              if (firebaseAPI.bookingSubscription != null) {
                firebaseAPI.stopListeningToBookings();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking notifications stopped')),
                );
              } else {
                firebaseAPI.startListeningToBookings();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking notifications started')),
                );
              }
            },
            icon: Icon(
              firebaseAPI.bookingSubscription != null 
                  ? Icons.notifications_active 
                  : Icons.notifications_off,
              color: firebaseAPI.bookingSubscription != null 
                  ? Colors.green 
                  : Colors.grey,
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications, color: Colors.yellow),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: _buildNotificationList(),
                ),
    );
  }

  /// Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.notifications_none, size: 60, color: Colors.black),
          SizedBox(height: 16),
          Text(
            "Oops! No notifications yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "It seems that you’ve got a blank state.\nWe’ll let you know when updates arrive!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  /// Notification list widget
  Widget _buildNotificationList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Recent Notifications",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        for (int i = 0; i < notifications.length; i++)
          _buildNotificationCard(
            notifications[i]["title"]!,
            notifications[i]["body"]!,
            notifications[i]["time"]!,
            notifications[i]["type"]!,
            notificationId: notifications[i]["id"],
            isRead: notifications[i]["read"] ?? false,
          ),
      ],
    );
  }

  /// Individual notification card
  Widget _buildNotificationCard(String title, String body, String time, String type, {String? notificationId, bool isRead = false}) {
    return GestureDetector(
      onTap: () {
        if (notificationId != null && !isRead) {
          _markAsRead(notificationId);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Color(0xFFF8F9FA) : Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: isRead ? null : Border.all(color: _getNotificationColor(type).withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getNotificationColor(type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getNotificationIcon(type),
                color: _getNotificationColor(type),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                            color: isRead ? Colors.grey[700] : Colors.black,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getNotificationColor(type),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: TextStyle(
                      fontSize: 14,
                      color: isRead ? Colors.grey[500] : Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      final userId = await UserStorageService.getUserId();
      if (userId == null) {
        print('User not logged in, cannot mark notification as read');
        return;
      }

      // Double check with Firebase Auth
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('Firebase user not authenticated, cannot mark notification as read');
        return;
      }

      await _database.ref('Notifications/$userId/$notificationId/read').set(true);
      
      // Update local state
      setState(() {
        final index = notifications.indexWhere((n) => n['id'] == notificationId);
        if (index != -1) {
          notifications[index]['read'] = true;
        }
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'alert':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return Icons.check_circle;
      case 'alert':
        return Icons.warning;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }
}
