import 'package:flutter/material.dart';

final Map<String, IconData> serviceIcons = {
  "Oil Change": Icons.water_drop_outlined,
  "Break Service": Icons.settings_suggest_outlined,
  "Tire Rotation": Icons.cable_outlined,
  "Battery Replacement": Icons.battery_alert,
  "Engine Diagnostic": Icons.memory_rounded,
  "Aircond Service": Icons.ac_unit_rounded,
  "Transmission Service": Icons.settings_ethernet_rounded,
  "Wheel Alignment": Icons.crop_rotate,
  "Full Vehicle Inspection": Icons.directions_car,
};

String formatTime(time){
  String timeStr = "";
  if (time.hour > 12){
    timeStr += (time.hour - 12).toString();
  }
  else{
    timeStr += time.hour.toString();
  }
  timeStr += ":${time.minute.toString().padLeft(2, '0')}";
  time.hour >= 12 ? timeStr += "PM" : timeStr += "AM";
  return timeStr;
}

Map<String, dynamic> bookingStatusDesign(status){
  switch (status) {
    case 'Upcoming':
      return {'icon': Icons.event, 'textColor': Color(0xFFBF7A01), 'backgroundColor': Color(0xFFFFC786)};
    case 'Ongoing':
      return {'icon': Icons.build_outlined, 'textColor': Color(0xFF0A01BF), 'backgroundColor': Color(0xFFA9C7FE)};
    case 'Completed':
      return {'icon': Icons.check, 'textColor': Color(0xFF20BF01), 'backgroundColor': Color(0xFFC2FEA9)};
    case 'Missed':
    case 'Cancelled':
      return {'icon': Icons.close, 'textColor': Color(0xFFD70004), 'backgroundColor': Color(0xFFFEA9A9)};
    default:
      return {'icon': Icons.help, 'textColor': Colors.grey, 'backgroundColor': Colors.grey.shade200};
  }
}