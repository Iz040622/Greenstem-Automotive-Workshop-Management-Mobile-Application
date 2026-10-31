import 'package:flutter/material.dart';
import 'package:mad_assignment/model/vehicle.dart';
import 'package:mad_assignment/widgets/booking_list_item.dart';
import 'package:mad_assignment/services/user_storage_service.dart';

import 'make_booking.dart';
import 'model/booking.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.goToBookings});

  final VoidCallback goToBookings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 26, right: 26),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Welcome",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 25),
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..scale(-1.0, 1.0, 1.0), // Flip X axis
                  child: Icon(
                    Icons.waving_hand,
                    color: Colors.amberAccent,
                    size: 28,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 8, bottom: 25),
              child: Text(
                "Your one-stop app for all car service needs.",
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MakeBooking(),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(13),
                    width: 92,
                    height: 128,
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F7FC),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.1 * 255).toInt()),
                          blurRadius: 4,
                          offset: Offset(4, 4), // Offset
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFFA7E7FA),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(
                                  (0.2 * 255).toInt(),
                                ),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/car_service_icon.png',
                            width: 40,
                            height: 40,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Center(
                              child: Text(
                                "Make New Booking",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(2, 2),
                                      blurRadius: 1,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){goToBookings();},
                  child: Container(
                    padding: EdgeInsets.all(13),
                    width: 92,
                    height: 128,
                    decoration: BoxDecoration(
                      color: Color(0xFFFCE8E8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.1 * 255).toInt()),
                          blurRadius: 4,
                          offset: Offset(4, 4), // Offset
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFA8AA),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(
                                  (0.2 * 255).toInt(),
                                ),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/booking_list_icon.png',
                            width: 40,
                            height: 40,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Center(
                              child: Text(
                                "My Bookings",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(2, 2),
                                      blurRadius: 1,
                                      color: Colors.grey,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(13),
                  width: 92,
                  height: 128,
                  decoration: BoxDecoration(
                    color: Color(0xFFE2FFE4),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.1 * 255).toInt()),
                        blurRadius: 4,
                        offset: Offset(4, 4), // Offset
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFF8CFFA5),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(
                                (0.2 * 255).toInt(),
                              ),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/vehicle_list_icon.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Center(
                            child: Text(
                              "Vehicle List",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                shadows: [
                                  Shadow(
                                    offset: Offset(2, 2),
                                    blurRadius: 1,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 30, bottom: 15),
              child: Text(
                "Only For You",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MakeBooking(),
                  ),
                );
              },
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.1 * 255).toInt()),
                          blurRadius: 4,
                          offset: Offset(0, 4), // Offset
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/banner.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 120,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: SizedBox(
                      width: 200,
                      child: Text(
                        "Car Trouble? We've Got You Covered!",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Color(0xFFE8F7FC).withAlpha((0.6 * 255).toInt()),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withAlpha((0.5 * 255).toInt()),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "Book Now",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 35, bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Track Real-time Status",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    child: Text(
                      "More", 
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            HomeScreenState(),
          ],
        ),
      ),
    );
  }
}

class HomeScreenState extends StatefulWidget {
  const HomeScreenState({super.key});

  @override
  State<HomeScreenState> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreenState> {
  Booking? _nextBooking;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNextBooking(); 
  }

  Future<void> _loadNextBooking() async {
      // Get current user ID from local storage
      final userId = await UserStorageService.getUserId();
      
      if (userId != null) {
        final vehicles = await VehicleService.getAllVehiclesByUser(userId);
        final bookings = await BookingService.getAllBookingsByVehicles(vehicles);
        final booking = await BookingService.getNextBooking(bookings);

        setState(() {
          _nextBooking = booking;
          _isLoading = false;
        });
      } else {
        setState(() {
          _nextBooking = null;
          _isLoading = false;
        });
      }
  }

  Future<void> _reloadNextBooking() async {
    setState(() {
      _isLoading = true;
    });
    await _loadNextBooking();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_nextBooking != null) {
      return BookingListItem(
          booking: _nextBooking!, onBookingUpdated: _reloadNextBooking,);
    }

    return Container(
      margin: EdgeInsets.only(top: 10, left: 25, right: 25),
      padding: EdgeInsetsDirectional.symmetric(vertical: 10),
      alignment: Alignment.center,
      color: Colors.white.withAlpha((0.4 * 255).toInt()),
      child: Text("No ongoing/upcoming bookings", style: TextStyle(fontSize: 15, color: Colors.black38),),
    );
  }
}

