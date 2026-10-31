import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:mad_assignment/widgets/gradient_scaffold.dart';
import '../model/booking.dart' as booking_model;
import '../model/vehicle.dart';

class InvoicePage extends StatelessWidget {
  final booking_model.Booking booking;
  final Vehicle vehicle;
  final String paymentMethod;
  final double totalAmount;
  final List<String> services;

  const InvoicePage({
    Key? key,
    required this.booking,
    required this.vehicle,
    required this.paymentMethod,
    required this.totalAmount,
    required this.services,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: GradientScaffold.dynamicAppBar(
        context: context,
        widget: const Text("Invoice"),
      ),
      body: InvoiceDetail(
        booking: booking,
        vehicle: vehicle,
        paymentMethod: paymentMethod,
        totalAmount: totalAmount,
        services: services,
      ),
    );
  }
}

class InvoiceDetail extends StatelessWidget {
  final booking_model.Booking booking;
  final Vehicle vehicle;
  final String paymentMethod;
  final double totalAmount;
  final List<String> services;

  const InvoiceDetail({
    Key? key,
    required this.booking,
    required this.vehicle,
    required this.paymentMethod,
    required this.totalAmount,
    required this.services,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate invoice details
    final subtotal = totalAmount / 1.06; // Remove 6% tax
    final tax = totalAmount - subtotal;
    
    // Generate invoice number
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final invoiceNumber = "INV-${timestamp.length > 8 ? timestamp.substring(timestamp.length - 8) : timestamp}";
    final referenceNumber = "REF-${booking.bookingId.length >= 8 ? booking.bookingId.substring(0, 8).toUpperCase() : booking.bookingId.toUpperCase()}";

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
      child: Column(
        children: [
          // Invoice Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "CarVista Car Service Sdn Bhd",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Business address",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            "Setapak, 53300 Kuala Lumpur",
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
                
                const SizedBox(height: 25),
                
                // Billed From Section
                const Text(
                  "Billed from",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "CarVista Car Service Sdn Bhd",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  "Setapak, 53300 Kuala Lumpur",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Invoice Details Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Invoice number",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "#$invoiceNumber",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Invoice date",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat("dd MMM, yyyy").format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 15),
                
                // Reference
                const Text(
                  "Reference",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  referenceNumber,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                
                const SizedBox(height: 25),
                
                // Services Table Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          "ITEM DETAIL",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "QTY",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          "AMOUNT (RM)",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Services List
                ..._buildServiceItems(),
                
                const SizedBox(height: 20),
                
                // Summary Section
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow("Subtotal", subtotal),
                      const SizedBox(height: 8),
                      _buildSummaryRow("Tax (6%)", tax),
                      const SizedBox(height: 12),
                      Container(
                        height: 1,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow("Total", totalAmount, isTotal: true),
                    ],
                  ),
                ),
                
                const SizedBox(height: 25),
                
                // Thank you message
                const Center(
                  child: Text(
                    "Thanks for the business.",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Download PDF Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade100,
                foregroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
              ),
              onPressed: () {
                _downloadAsPDF(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.download,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Download as PDF",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<Widget> _buildServiceItems() {
    // Use services from parameter
    List<String> serviceList = List<String>.from(services);
    
    // Default services if none provided
    if (serviceList.isEmpty) {
      serviceList = ["Oil Change", "Break Service", "Battery Replace"];
    }
    
    // Calculate individual service prices
    final serviceCount = serviceList.length;
    final basePrice = (totalAmount / 1.06) / serviceCount; // Remove tax and divide by service count
    
    return serviceList.map((service) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Text(
                service,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                "1",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "RM${basePrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: Colors.black,
          ),
        ),
        Text(
          "RM${amount.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Future<void> _downloadAsPDF(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Generating PDF...'),
            ],
          ),
        );
      },
    );

    try {
      // Generate PDF
      final pdf = pw.Document();
      
      // Add page to PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return _buildPDFContent();
          },
        ),
      );

      // Get directory for saving
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Invoice_${booking.bookingId.length >= 8 ? booking.bookingId.substring(0, 8) : booking.bookingId}.pdf';
      final file = File('${directory.path}/$fileName');
      
      // Save PDF
      await file.writeAsBytes(await pdf.save());
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Open PDF
      await OpenFile.open(file.path);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('PDF downloaded successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
      
      // Haptic feedback
      HapticFeedback.lightImpact();
      
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  pw.Widget _buildPDFContent() {
    final subtotal = totalAmount / 1.06;
    final tax = totalAmount - subtotal;
    final serviceCount = services.length;
    final basePrice = subtotal / serviceCount;
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Company Header
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text(
                'CarVista Car Service Sdn Bhd',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                '123, Jalan Teknologi, Taman Teknologi Malaysia,\n47810 Petaling Jaya, Selangor, Malaysia',
                style: pw.TextStyle(fontSize: 12),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
        ),
        
        pw.SizedBox(height: 30),
        
        // Invoice Details
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Invoice Number: INV-${DateTime.now().millisecondsSinceEpoch.toString().length > 8 ? DateTime.now().millisecondsSinceEpoch.toString().substring(DateTime.now().millisecondsSinceEpoch.toString().length - 8) : DateTime.now().millisecondsSinceEpoch.toString()}'),
                pw.Text('Invoice Date: ${DateFormat("d/M/y").format(DateTime.now())}'),
                pw.Text('Reference: REF-${booking.bookingId.length >= 8 ? booking.bookingId.substring(0, 8).toUpperCase() : booking.bookingId.toUpperCase()}'),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Bill To:'),
                pw.Text('${vehicle.vehicleModel}'),
                pw.Text('Plate: ${vehicle.carPlateNumber}'),
                pw.Text('Date: ${DateFormat("d/M/y").format(booking.appointmentDate)}'),
                pw.Text('Time: ${DateFormat("h:mma").format(DateTime(2024, 1, 1, booking.appointmentTime.hour, booking.appointmentTime.minute))}'),
              ],
            ),
          ],
        ),
        
        pw.SizedBox(height: 30),
        
        // Services Table
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('ITEM DETAIL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('QTY', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('AMOUNT (RM)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ),
              ],
            ),
            // Service Items
            ...services.map((service) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(service),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('1'),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('RM${basePrice.toStringAsFixed(2)}'),
                ),
              ],
            )).toList(),
          ],
        ),
        
        pw.SizedBox(height: 20),
        
        // Summary
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Subtotal: RM${subtotal.toStringAsFixed(2)}'),
              pw.Text('Tax (6%): RM${tax.toStringAsFixed(2)}'),
              pw.SizedBox(height: 10),
              pw.Text(
                'Total: RM${totalAmount.toStringAsFixed(2)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
        
        pw.SizedBox(height: 30),
        
        // Payment Method
        pw.Center(
          child: pw.Text(
            'Payment Method: $paymentMethod',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        
        pw.SizedBox(height: 20),
        
        // Thank you message
        pw.Center(
          child: pw.Text(
            'Thanks for the business.',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
