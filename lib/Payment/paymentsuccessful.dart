import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mad_assignment/widgets/gradient_scaffold.dart';
import '../model/booking.dart' as booking_model;
import '../model/vehicle.dart';
import 'invoice.dart';
import '../home.dart';

class PaymentSuccessfulPage extends StatelessWidget {
  final booking_model.Booking booking;
  final Vehicle vehicle;
  final String paymentMethod;
  final double totalAmount;
  final List<String> services;
  final String? cardType;

  const PaymentSuccessfulPage({
    Key? key,
    required this.booking,
    required this.vehicle,
    required this.paymentMethod,
    required this.totalAmount,
    required this.services,
    this.cardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: GradientScaffold.dynamicAppBar(
        context: context,
        widget: const Text("Payment"),
      ),
      body: PaymentSuccessfulDetail(
        booking: booking,
        vehicle: vehicle,
        paymentMethod: paymentMethod,
        totalAmount: totalAmount,
        services: services,
        cardType: cardType,
      ),
    );
  }
}

class PaymentSuccessfulDetail extends StatelessWidget {
  final booking_model.Booking booking;
  final Vehicle vehicle;
  final String paymentMethod;
  final double totalAmount;
  final List<String> services;
  final String? cardType;

  const PaymentSuccessfulDetail({
    Key? key,
    required this.booking,
    required this.vehicle,
    required this.paymentMethod,
    required this.totalAmount,
    required this.services,
    this.cardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Success Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Thank you message
                const Text(
                  "Thank you!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                const Text(
                  "Your transaction was successful",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Transaction Details
                _buildDetailRow("Date", DateFormat("dd/MM/yyyy").format(DateTime.now())),
                const SizedBox(height: 15),
                _buildDetailRow("Time", DateFormat("h:mm a").format(DateTime.now())),
                const SizedBox(height: 15),
                _buildDetailRow("To", "CarVista Car Service Sdn. Bhd."),
                
                const SizedBox(height: 20),
                
                // Divider
                Container(
                  height: 1,
                  color: Colors.grey.shade300,
                ),
                
                const SizedBox(height: 20),
                
                // Total Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      "RM ${totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Payment Method Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      // Payment method icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: paymentMethod == 'Credit/Debit Card' && cardType != null
                            ? Padding(
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  'assets/images/$cardType.png',
                                  fit: BoxFit.contain,
                                ),
                              )
                            : Icon(
                                _getPaymentIcon(paymentMethod),
                                color: Colors.blue.shade700,
                                size: 24,
                              ),
                      ),
                      
                      const SizedBox(width: 15),
                      
                      // Payment method details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              paymentMethod,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getPaymentDetails(paymentMethod),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // View Invoice Button
          Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
                  _showInvoiceDialog(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt,
                      color: Colors.green.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "View Invoice",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Completed Button
          Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4B0082), Color(0xFF6A5ACD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4B0082).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {
Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                },
                child: const Center(
                  child: Text(
                    "Completed",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  IconData _getPaymentIcon(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'credit card':
      case 'credit/debit card':
        return Icons.credit_card;
      case 'qr code':
        return Icons.qr_code;
      case 'cash':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentDetails(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'credit card':
      case 'credit/debit card':
        return 'Mastercard **58';
      case 'qr code':
        return 'QR Code Payment';
      case 'cash':
        return 'Cash Payment';
      default:
        return 'Payment Completed';
    }
  }

  void _showInvoiceDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoicePage(
          booking: booking,
          vehicle: vehicle,
          paymentMethod: paymentMethod,
          totalAmount: totalAmount,
          services: services,
        ),
      ),
    );
  }
}
