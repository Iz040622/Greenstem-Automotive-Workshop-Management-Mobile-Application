import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mad_assignment/widgets/gradient_scaffold.dart';
import '../model/booking.dart' as booking_model;
import '../model/vehicle.dart';
import '../model/service.dart';
import 'qrcode.dart';
import 'paymentsuccessful.dart';
import 'cardpayment.dart';

class Payment {
  final String paymentId;
  final String paymentMethod;
  final DateTime paymentDate;
  final TimeOfDay paymentTime;
  final double totalAmount;
  final String bookingId;

  Payment({
    required this.paymentId,
    required this.paymentMethod,
    required this.paymentDate,
    required this.paymentTime,
    required this.totalAmount,
    required this.bookingId,
  });

  factory Payment.fromMap(String paymentId, Map<String, dynamic> map) {
    return Payment(
      paymentId: paymentId,
      paymentMethod: map['PaymentMethod'],
      paymentDate: DateFormat("d/M/y").parse(map['PaymentDate']),
      paymentTime: TimeOfDay.fromDateTime(
        DateFormat("h:mma").parse(map['PaymentTime']),
      ),
      totalAmount: (map["TotalAmount"] is int)
          ? (map["TotalAmount"] as int).toDouble()
          : (map["TotalAmount"] as double),
      bookingId: map['BookingId'],
    );
  }

  Map<String, dynamic> toMap() {
    String paymentTimeStr = "";
    if (paymentTime.hour > 12) {
      paymentTimeStr += (paymentTime.hour - 12).toString();
    } else {
      paymentTimeStr += paymentTime.hour.toString();
    }
    paymentTimeStr +=
    ":${paymentTime.minute.toString().padLeft(2, '0')}";
    paymentTime.hour >= 12
        ? paymentTimeStr += "PM"
        : paymentTimeStr += "AM";

    return {
      'PaymentMethod' : paymentMethod,
      'PaymentDate': DateFormat("d/M/y").format(paymentDate),
      'PaymentTime': paymentTimeStr,
      'TotalAmount' : totalAmount,
      'BookingId' : bookingId,
    };
  }
}

class PaymentService{
  static final DatabaseReference dbRef = FirebaseDatabase.instance.ref(
    'Payment',
  );

  //Create payment
  static Future<void> createPayment(Map<String, dynamic> map) async {
    final snapshot = await dbRef.get();

    int count = 0;

    if (snapshot.exists && snapshot.value != null && snapshot.value is Map) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      count = data.length;
    }

    final newPaymentId = 'P${count + 1}';

    await dbRef.child(newPaymentId).set(map);
  }

  //Get payment by Booking ID
  static Future<Payment?> getPaymentByBooking(String bookingId) async {
    final snapshot = await dbRef
        .orderByChild('BookingId')
        .equalTo(bookingId)
        .get();

    if (snapshot.exists) {
      final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      final entry = data.entries.first;
      return Payment.fromMap(entry.key, Map<String, dynamic>.from(entry.value));
    }
    return null;
  }
}

class PaymentPage extends StatelessWidget {
  final booking_model.Booking booking;
  final Vehicle vehicle;
  final List<String> service;

  const PaymentPage({
    Key? key,
    required this.booking,
    required this.vehicle,
    required this.service,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: GradientScaffold.dynamicAppBar(
        context: context,
        widget: const Text("Payment"),
      ),
      body: PaymentDetail(
        booking: booking,
        vehicle: vehicle,
        service: service,
      ),
    );
  }
}

// ------------------------- Payment Detail Section -------------------------
class PaymentDetail extends StatefulWidget {
  final booking_model.Booking booking;
  final Vehicle vehicle;
  final List<String> service;

  const PaymentDetail({
    Key? key,
    required this.booking,
    required this.vehicle,
    required this.service,
  }) : super(key: key);

  @override
  State<PaymentDetail> createState() => _PaymentDetailState();
}

class _PaymentDetailState extends State<PaymentDetail> {
  String? _selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    final Map<String, IconData> serviceIcons = {
      "Oil Change": Icons.water_drop_outlined,
      "Break Service": Icons.settings_suggest_outlined,
      "Tire Rotation": Icons.water_drop_outlined,
      "Battery Replace": Icons.battery_charging_full_outlined,
      "Engine Diagnostic": Icons.water_drop_outlined,
      "Aircond Service": Icons.water_drop_outlined,
      "Transmission Service": Icons.water_drop_outlined,
      "Wheel Alignment": Icons.water_drop_outlined,
      "Full Vehicle Inspection": Icons.water_drop_outlined,
    };

    // Booking/payment details
    final details = {
      "Date": {
        "Icon": Icons.event,
        "Value": DateFormat("d MMMM y").format(widget.booking.appointmentDate).toUpperCase(),
      },
      "Time": {
        "Icon": Icons.access_time_outlined,
        "Value": widget.booking.appointmentTime.format(context),
      },
      "Vehicle": {
        "Icon": Icons.directions_car,
        "Value": widget.vehicle.vehicleModel,
      },
      "Plate Number": {
        "Icon": Icons.confirmation_number,
        "Value": widget.vehicle.carPlateNumber,
      },
      "Service": {
        "Icon": Icons.build_outlined,
        "Value": widget.service,
      }
    };

    final detailsList = details.entries.toList();

    // Invoice Breakdown values - using actual service data
    final invoice = <String, double>{};
    for (String serviceName in widget.service) {
      // You might want to get actual prices from your service data
      // For now, using placeholder values
      switch (serviceName) {
        case "Oil Change":
          invoice[serviceName] = 30.00;
          break;
        case "Break Service":
          invoice[serviceName] = 324.00;
          break;
        case "Battery Replace":
          invoice[serviceName] = 100.00;
          break;
        case "Engine Diagnostic":
          invoice[serviceName] = 50.00;
          break;
        case "Transmission Service":
          invoice[serviceName] = 200.00;
          break;
        case "Full Vehicle Inspection":
          invoice[serviceName] = 80.00;
          break;
        default:
          invoice[serviceName] = 50.00;
      }
    }

    final subtotal = invoice.values.reduce((a, b) => a + b);
    final tax = subtotal * 0.06;
    final grandTotal = subtotal + tax;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Make Payment",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),

          // Single Container for all content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE5EDFB),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 6,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking Details Section
                ...List.generate(detailsList.length, (i) {
                  final entry = detailsList[i];

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            // Left side (Icon + Label)
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.23,
                              child: Row(
                                children: [
                                  Icon(entry.value['Icon'] as IconData,
                                      color: Colors.black),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      softWrap: true,
                                      entry.key,
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Right side (Value)
                            Padding(
                              padding: const EdgeInsets.only(left: 0),
                              child: entry.value['Value'] is List
                                  ? Wrap( // For Service values
                                      spacing: 5,
                                      runSpacing: 10,
                                      children: (entry.value['Value'] as List<String>).map((serviceName) {
                                        return Container(
                                          width: 65, // fixed box size
                                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFA7E7FA),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey.shade300),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                serviceIcons[serviceName] ?? Icons.miscellaneous_services,
                                                size: 28,
                                                color: Colors.black,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                serviceName,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    )
                                  : Align( // For Date, Time, Vehicle, Plate Number
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 20),
                                        child: Text(
                                          entry.value['Value'].toString(),
                                          style: const TextStyle(color: Colors.black54),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                      // Divider unless it's the last item
                      if (i != detailsList.length - 1)
                        const Divider(
                          color: Colors.grey,
                          thickness: 1,
                          height: 35,
                        ),
                    ],
                  );
                }),

                const SizedBox(height: 25),

                // Service items
                ...invoice.entries.map((entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Text(
                            "RM ${entry.value.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),

                const Divider(color: Colors.grey, thickness: 1, height: 30),

                // Subtotal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "Subtotal",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      "RM ${subtotal.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Tax
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "SST Tax (6%)",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      "RM ${tax.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const Divider(color: Colors.grey, thickness: 1, height: 30),

                // Grand Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text(
                        "Grand Total",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      "RM ${grandTotal.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // Payment Method Section
                const Text(
                  "Payment Method",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),

                // Payment Method Options - Horizontal Layout
                Row(
                  children: [
                    // Credit/Debit Card option
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPaymentMethod = 'Credit/Debit Card';
                          });
                        },
                        child: Container(
                          height: 70,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedPaymentMethod == 'Credit/Debit Card' 
                                ? const Color(0xFF4ADBFF) 
                                : const Color(0xFFE1F2FC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedPaymentMethod == 'Credit/Debit Card' 
                                  ? const Color(0xFF4ADBFF) 
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.credit_card,
                                color: _selectedPaymentMethod == 'Credit/Debit Card' 
                                    ? Colors.white 
                                    : Colors.black,
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Flexible(
                                child: Text(
                                  "Credit/Debit Card",
                                  style: TextStyle(
                                    color: _selectedPaymentMethod == 'Credit/Debit Card' 
                                        ? Colors.white 
                                        : Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Scan QR Code option
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPaymentMethod = 'Scan QR Code';
                          });
                        },
                        child: Container(
                          height: 70,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedPaymentMethod == 'Scan QR Code' 
                                ? const Color(0xFF4ADBFF) 
                                : const Color(0xFFE1F2FC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedPaymentMethod == 'Scan QR Code' 
                                  ? const Color(0xFF4ADBFF) 
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code_scanner,
                                color: _selectedPaymentMethod == 'Scan QR Code' 
                                    ? Colors.white 
                                    : Colors.black,
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Flexible(
                                child: Text(
                                  "Scan QR Code",
                                  style: TextStyle(
                                    color: _selectedPaymentMethod == 'Scan QR Code' 
                                        ? Colors.white 
                                        : Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Proceed to Payment Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
              ),
              onPressed: () {
                if (_selectedPaymentMethod == 'Scan QR Code') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QRCodePaymentPage(
                        booking: widget.booking,
                        vehicle: widget.vehicle,
                        service: widget.service,
                      ),
                    ),
                  );
                } else {
                  _processPayment(context);
                }
              },
              child: const Text(
                "Proceed to Payment",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _processPayment(BuildContext context) async {
    final paymentMethod = _selectedPaymentMethod ?? 'Credit/Debit Card';
    
    if (paymentMethod == 'Credit/Debit Card') {
      // Navigate to card payment page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CardPaymentPage(
            booking: widget.booking,
            vehicle: widget.vehicle,
            services: widget.service,
            totalAmount: widget.booking.cost,
          ),
        ),
      );
    } else {
      // For other payment methods, process directly
      try {
        // Create payment record
        final paymentData = {
          'PaymentMethod': paymentMethod,
          'PaymentDate': DateFormat("d/M/y").format(DateTime.now()),
          'PaymentTime': DateFormat("h:mma").format(DateTime.now()),
          'TotalAmount': widget.booking.cost,
          'BookingId': widget.booking.bookingId,
        };

        await PaymentService.createPayment(paymentData);

        // Update booking status to completed
        await booking_model.BookingService.completeBooking(widget.booking.bookingId);

        if (context.mounted) {
          // Navigate to payment successful page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessfulPage(
                booking: widget.booking,
                vehicle: widget.vehicle,
                paymentMethod: paymentMethod,
                totalAmount: widget.booking.cost,
                services: widget.service,
                cardType: null,
              ),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
