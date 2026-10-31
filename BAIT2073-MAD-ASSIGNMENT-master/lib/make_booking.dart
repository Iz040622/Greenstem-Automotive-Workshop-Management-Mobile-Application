import 'package:flutter/material.dart';
import 'package:mad_assignment/widgets/gradient_scaffold.dart';

import 'make_booking_step2.dart';
import 'make_booking_summary.dart';
import 'model/service.dart';
import 'make_booking_step1.dart';

class MakeBooking extends StatefulWidget {
  const MakeBooking({super.key});

  @override
  State<MakeBooking> createState() => _MakeBookingState();
}

class _MakeBookingState extends State<MakeBooking> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  String selectedVehicleId = "";
  List<Service> selectedServices = [];
  Duration estimatedDuration = Duration.zero;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  List<Widget> pages = [];

  void _onBackPressed() {
    if (_currentPage > 0) {
      _controller.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _onNextPressed() {
    if (_currentPage < pages.length - 1) {
      _controller.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _selectVehicle(String vehicleId) {
    setState(() {
      selectedVehicleId = vehicleId;
    });
  }

  void _selectServices(List<Service> services){
    setState(() {
      selectedServices = services;
    });
  }

  void _setEstimatedDuration(){
    setState(() {
      for (final service in selectedServices){
        estimatedDuration += service.serviceDuration;
      }
    });
  }

  void _selectDate(DateTime dateTime){
    setState(() {
      selectedDate = dateTime;
    });
  }

  void _selectTime(TimeOfDay time){
    setState(() {
      selectedTime = time;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    pages = [
      MakeBookingStep1(onNext: _onNextPressed, selectVehicle: _selectVehicle, selectServices: _selectServices, setEstimatedDuration: _setEstimatedDuration,),
      MakeBookingStep2(vehicleId: selectedVehicleId, selectedServiceList: selectedServices, estimatedDuration: estimatedDuration, onNext: _onNextPressed, selectDate: _selectDate, selectTime: _selectTime,),
      MakeBookingSummary(vehicleId: selectedVehicleId, selectedServiceList: selectedServices, estimatedDuration: estimatedDuration, selectedDate: selectedDate ?? DateTime.now(), selectedTime: selectedTime ?? TimeOfDay.now(), onNext: _onNextPressed,),
    ];

    return GradientScaffold(
      appBar: GradientScaffold.dynamicAppBar(
        context: context,
        widget: Text("Booking"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBackPressed,
        ),
      ),
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: pages,
      ),
    );
  }
}
