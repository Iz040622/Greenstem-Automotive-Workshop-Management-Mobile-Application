import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:mad_assignment/model/booking_service.dart' as booking_service;
import 'package:mad_assignment/widgets/button.dart';
import 'package:table_calendar/table_calendar.dart';

import 'model/service.dart';
import 'model/booking.dart' as booking;

class MakeBookingStep2 extends StatefulWidget {
  const MakeBookingStep2({
    super.key,
    required this.vehicleId,
    required this.selectedServiceList,
    required this.estimatedDuration,
    required this.onNext,
    required this.selectDate,
    required this.selectTime,
  });

  final String vehicleId;
  final List<Service> selectedServiceList;
  final Duration estimatedDuration;
  final VoidCallback onNext;
  final Function(DateTime) selectDate;
  final Function(TimeOfDay) selectTime;

  @override
  State<MakeBookingStep2> createState() => _MakeBookingStep2State();
}

class _MakeBookingStep2State extends State<MakeBookingStep2> {
  bool _isDatesLoading = true;
  DateTime _focusedDay = DateTime.now();
  final DateTime _firstDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );
  final DateTime _lastDay = DateTime(
    DateTime.now().year,
    DateTime.now().month + 3,
    1,
  ).subtract(Duration(days: 1));
  List<DateTime>? _datesInMonth;
  List<booking.Booking>? _bookingsInMonth;
  List<DateTime> _availableDates = [];
  DateTime? _selectedDay;
  List<DateTime>? _availableSlots;
  TimeOfDay? _selectedSlot;

  void _getVisibleDatesForMonth(DateTime currentDay) {
    final startDay = DateTime(currentDay.year, currentDay.month, 1);
    final lastDayOfMonth = DateTime(currentDay.year, currentDay.month + 1, 0);

    List<DateTime> dates = [];
    for (int i = 0; i <= lastDayOfMonth.difference(startDay).inDays; i++) {
      dates.add(startDay.add(Duration(days: i)));
    }
    _datesInMonth = dates;
  }

  Future<void> _getBookingsByMonths() async {
    final bookings = await booking.BookingService.getBookingsByPeriod(
      _datesInMonth!.first,
      _datesInMonth!.last,
    );

    _bookingsInMonth = bookings;
    await computeAvailableDates();
    setState(() {
      _isDatesLoading = false;
    });
  }

  Future<List<DateTime>> getAvailableTimeSlots({
    required List<booking.Booking> bookings,
    required DateTime date,
    required Duration newBookingDuration,
  }) async {
    const TimeOfDay startTime = TimeOfDay(hour: 8, minute: 0);
    const TimeOfDay lastCallTime = TimeOfDay(hour: 16, minute: 0);

    DateTime current = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );
    DateTime lastCall = DateTime(
      date.year,
      date.month,
      date.day,
      lastCallTime.hour,
      lastCallTime.minute,
    );

    const int maxConcurrent = 5;
    const Duration slotSize = Duration(minutes: 15);
    List<DateTime> availableSlots = [];

    while (current.isBefore(lastCall) || current.isAtSameMomentAs(lastCall)) {
      int overlapCount = 0;
      DateTime newBookingEnd = current.add(newBookingDuration);

      for (final booking in bookings) {
        final start = booking.startDateTime;
        final end = booking.endDateTime;

        if (booking.vehicleId == widget.vehicleId &&
            current.isBefore(end) &&
            newBookingEnd.isAfter(start)) {
          overlapCount++;
          if (overlapCount >= maxConcurrent) break;
        }
      }

      if (overlapCount < maxConcurrent) {
        availableSlots.add(current);
      }

      current = current.add(slotSize);
    }

    return availableSlots;
  }

  Future<void> computeAvailableDates() async {
    Set<DateTime> dates = {};

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    for (var day in _datesInMonth!) {
      DateTime normalizedDay = DateTime(day.year, day.month, day.day);

      if (isSameDay(normalizedDay, normalizedToday)) {
        continue;
      }

      final bookingsOnDay = _bookingsInMonth!
          .where((b) => isSameDay(b.appointmentDate, normalizedDay))
          .toList();

      bool serviceClash = false;

      for (final b in bookingsOnDay) {
        List<booking_service.BookingService> bookingServices =
            await booking_service
                .BookingServiceService.getAllBookingServicesByBooking(
              b.bookingId,
            );

        List<String> serviceIds = bookingServices
            .map((service) => service.serviceId)
            .toList();

        if (b.vehicleId == widget.vehicleId &&
            widget.selectedServiceList.any(
              (service) => serviceIds.contains(service.serviceId),
            )) {
          serviceClash = true;
          break;
        }
      }

      if (serviceClash) {
        continue;
      }

      List<DateTime> dayAvailableSlots = await getAvailableTimeSlots(
        bookings: bookingsOnDay,
        date: normalizedDay,
        newBookingDuration: widget.estimatedDuration,
      );

      if (dayAvailableSlots.isNotEmpty) {
        dates.add(normalizedDay);
      }
    }

    setState(() {
      _availableDates = dates.toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _getVisibleDatesForMonth(DateTime.now());
    _getBookingsByMonths();
  }

  @override
  Widget build(BuildContext context) {
    bool canGoPrev =
        !(_focusedDay.year == _firstDay.year &&
            _focusedDay.month == _firstDay.month);
    bool canGoNext =
        !(_focusedDay.year == _lastDay.year &&
            _focusedDay.month == _lastDay.month);

    if (_isDatesLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 26, right: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Make Booking",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 10, left: 5),
            child: const Text(
              "Step 2:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Select the date:", style: TextStyle(color: Colors.black)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.1 * 255).toInt()),
                        blurRadius: 4,
                        offset: Offset(0, 4), // Offset
                      ),
                    ],
                  ),
                  child: TableCalendar(
                    firstDay: _firstDay,
                    lastDay: _lastDay,
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    enabledDayPredicate: (day) {
                      final today = DateTime.now();
                      if (day.isBefore(
                        DateTime(today.year, today.month, today.day),
                      )) {
                        return false;
                      }
                      if (day.weekday == DateTime.sunday) return false;

                      return _availableDates.any((d) => isSameDay(d, day));
                    },
                    onDaySelected: (selectedDay, focusedDay) async {
                      final bookingsOnDay = _bookingsInMonth!
                          .where(
                            (b) => isSameDay(b.appointmentDate, selectedDay),
                          )
                          .toList();

                      List<DateTime> slots = await getAvailableTimeSlots(
                        bookings: bookingsOnDay,
                        date: selectedDay,
                        newBookingDuration: widget.estimatedDuration,
                      );

                      setState(() {
                        _availableSlots = slots;
                        _selectedSlot = null;
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                        bool isCurrentMonth =
                            focusedDay.year == DateTime.now().year &&
                            focusedDay.month == DateTime.now().month;
                        _getVisibleDatesForMonth(
                          isCurrentMonth ? DateTime.now() : focusedDay,
                        );
                        _getBookingsByMonths();
                      });
                    },
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      leftChevronIcon: Icon(
                        Icons.arrow_left,
                        color: canGoPrev ? Colors.black : Colors.grey,
                        size: 28,
                      ),
                      rightChevronIcon: Icon(
                        Icons.arrow_right,
                        color: canGoNext ? Colors.black : Colors.grey,
                        size: 28,
                      ),
                      formatButtonVisible: false,
                    ),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: TextStyle(color: Colors.black),
                      selectedDecoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 10, top: 20),
            child: _availableSlots == null
                ? Container()
                : Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F7FC),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha((0.1 * 255).toInt()),
                          blurRadius: 4,
                          offset: Offset(0, 4), // Offset
                        ),
                      ],
                    ),
                    child: DropdownButton2<TimeOfDay>(
                      value: _selectedSlot,
                      hint: Text(
                        "Select a slot",
                        style: TextStyle(color: Colors.black),
                      ),
                      onChanged: (value) {
                        setState(() => _selectedSlot = value);
                      },
                      items: _availableSlots?.map((slot) {
                        final time = TimeOfDay.fromDateTime(slot);
                        final label = time.format(context);
                        return DropdownMenuItem<TimeOfDay>(
                          value: time,
                          child: Row(
                            children: [
                              SizedBox(width: 10),
                              Text(
                                label,
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200,
                        decoration: BoxDecoration(color: Colors.blue[100]),
                      ),
                      iconStyleData: const IconStyleData(
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Button(
              backgroundColor: Color(0xFFAFEBFF),
              foregroundColor: Color(0xFF3780B7),
              label: 'Proceed to Summary',
              action: _selectedDay != null && _selectedSlot != null
                  ? () {
                      widget.selectDate(_selectedDay!);
                      widget.selectTime(_selectedSlot!);
                      widget.onNext();
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
