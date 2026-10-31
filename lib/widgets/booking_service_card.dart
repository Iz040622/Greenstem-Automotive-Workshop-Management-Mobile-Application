import 'package:flutter/material.dart';

import '../res/design.dart';

class BookingServiceCard extends StatefulWidget {
  const BookingServiceCard({super.key, required this.details, required this.services});

  final Map<String, String> details;
  final List<String> services;

  @override
  State<BookingServiceCard> createState() => _BookingServiceCardState();
}

class _BookingServiceCardState extends State<BookingServiceCard> {
  Map<String, IconData> icons = {
    "Date": Icons.event,
    "Time": Icons.access_time_outlined,
    "Vehicle": Icons.directions_car,
    "Plate Number": Icons.call_to_action,
    "Estimated Time": Icons.timer,
    "Cost": Icons.monetization_on,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ...widget.details.entries.map((entry) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Row(
                          children: [
                            Icon(
                              icons[entry.key],
                              color: Colors.black,
                            ),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                entry.key,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          entry.value,
                          style: TextStyle(color: Colors.black38),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.grey, thickness: 1, height: 26),
              ],
            );
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Row(
                    children: [
                      Icon(Icons.build_outlined, color: Colors.black),
                      SizedBox(width: 5),
                      Text(
                        "Service",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: widget.services.map((service) {
                      return Container(
                        width: 60,
                        height: 60,
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Color(0xFFA7E7FA),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(
                                (0.1 * 255).toInt(),
                              ),
                              blurRadius: 3,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              serviceIcons[service],
                              color: Colors.black38,
                              size: 20,
                            ),
                            SizedBox(height: 2),
                            Text(
                              service,
                              style: TextStyle(
                                color: Colors.black38,
                                fontSize: 7,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
