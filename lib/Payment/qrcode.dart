import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mad_assignment/widgets/gradient_scaffold.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../model/booking.dart' as booking_model;
import '../model/vehicle.dart';
import 'payment.dart';
import 'paymentsuccessful.dart';

// ------------------------- QR Code Payment Page -------------------------
class QRCodePaymentPage extends StatelessWidget {
  final booking_model.Booking booking;
  final Vehicle vehicle;
  final List<String> service;

  const QRCodePaymentPage({
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
      body: QRCodePaymentDetail(
        booking: booking,
        vehicle: vehicle,
        service: service,
      ),
    );
  }
}

class QRCodePaymentDetail extends StatefulWidget {
  final booking_model.Booking booking;
  final Vehicle vehicle;
  final List<String> service;

  const QRCodePaymentDetail({
    Key? key,
    required this.booking,
    required this.vehicle,
    required this.service,
  }) : super(key: key);

  @override
  State<QRCodePaymentDetail> createState() => _QRCodePaymentDetailState();
}

class _QRCodePaymentDetailState extends State<QRCodePaymentDetail> {
  MobileScannerController controller = MobileScannerController();
  bool _isScanning = true;
  bool _hasPermission = false;
  final String _validQRCode = "00020201021126520014A000000615000101068900530220MDN168057952929178945204739953034585802MY5910LAUAIKHUNG6011KUALALUMPUR630401DE";

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status == PermissionStatus.granted;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return _buildPermissionRequest();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Scan QR Payment",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),

          // QR Scanner Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
                // Real QR Scanner Area
                Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(0xFFFF6B35), // Orange border
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _isScanning
                        ? MobileScanner(
                            controller: controller,
                            onDetect: _onDetect,
                          )
                        : Container(
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: Icon(
                                Icons.qr_code_scanner,
                                size: 80,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Toggle Camera Button
                GestureDetector(
                  onTap: _toggleCamera,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _isScanning ? Colors.red.shade400 : Colors.green.shade400,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isScanning ? Icons.stop : Icons.play_arrow,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Instructions
                Text(
                  _isScanning 
                      ? "Position QR code within the frame to scan" 
                      : "Tap the button to start scanning",
                  style: TextStyle(
                    fontSize: 16,
                    color: _isScanning ? const Color(0xFFFF6B35) : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Payment Summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE5EDFB),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Payment Summary",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Vehicle:",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      widget.vehicle.vehicleModel,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Plate Number:",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      widget.vehicle.carPlateNumber,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Amount:",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "RM ${widget.booking.cost.toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _handleQRCode(barcode.rawValue!);
        break; // Only process the first detected QR code
      }
    }
  }

  void _toggleCamera() {
    setState(() {
      _isScanning = !_isScanning;
    });
    
    if (_isScanning) {
      controller.start();
    } else {
      controller.stop();
    }
  }

  void _handleQRCode(String qrCode) {
    // Stop scanning when QR code is detected
    setState(() {
      _isScanning = false;
    });
    controller.stop();

    if (qrCode == _validQRCode) {
      // Valid QR code - process payment
      _processQRPayment();
    } else {
      // Invalid QR code
      _showInvalidQRDialog();
    }
  }

  Widget _buildPermissionRequest() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Scan QR Payment",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Camera Permission Required",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "This app needs camera access to scan QR codes for payment.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _requestCameraPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Grant Permission",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processQRPayment() async {
    try {
      // Create payment record
      final paymentData = {
        'PaymentMethod': 'QR Code',
        'PaymentDate': DateFormat("d/M/y").format(DateTime.now()),
        'PaymentTime': DateFormat("h:mma").format(DateTime.now()),
        'TotalAmount': widget.booking.cost,
        'BookingId': widget.booking.bookingId,
      };

      await PaymentService.createPayment(paymentData);

      // Update booking status to completed
      await booking_model.BookingService.completeBooking(widget.booking.bookingId);

      if (mounted) {
        // Navigate to payment successful page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessfulPage(
              booking: widget.booking,
              vehicle: widget.vehicle,
              paymentMethod: 'QR Code',
              totalAmount: widget.booking.cost,
              services: widget.service,
              cardType: null,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showInvalidQRDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid QR Code'),
          content: const Text('The scanned QR code is not valid. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
