import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mad_assignment/widgets/gradient_scaffold.dart';
import '../model/booking.dart' as booking_model;
import '../model/vehicle.dart';
import 'paymentsuccessful.dart';

class CardPaymentPage extends StatefulWidget {
  final booking_model.Booking booking;
  final Vehicle vehicle;
  final List<String> services;
  final double totalAmount;

  const CardPaymentPage({
    Key? key,
    required this.booking,
    required this.vehicle,
    required this.services,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<CardPaymentPage> createState() => _CardPaymentPageState();
}

class _CardPaymentPageState extends State<CardPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardNameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expDateController = TextEditingController();
  final _cvvController = TextEditingController();

  String? _cardType;
  Map<String, String> _errors = {};

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_onCardNumberChanged);
  }

  @override
  void dispose() {
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _expDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _onCardNumberChanged() {
    String cardNumber = _cardNumberController.text.replaceAll(' ', '');
    setState(() {
      if (cardNumber.startsWith('5')) {
        _cardType = 'master';
      } else if (cardNumber.startsWith('4')) {
        _cardType = 'visa';
      } else {
        _cardType = null;
      }
    });
  }

  String? _validateCardName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the card name';
    }
    if (value.trim().length < 2) {
      return 'Card name must be at least 2 characters';
    }
    return null;
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the card number';
    }
    String cardNumber = value.replaceAll(' ', '');
    if (cardNumber.length != 16) {
      return 'Card number must be 16 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(cardNumber)) {
      return 'Card number must contain only digits';
    }
    return null;
  }

  String? _validateExpDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter expiry date';
    }
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
      return 'Please enter in MM/YY format';
    }
    
    List<String> parts = value.split('/');
    int month = int.tryParse(parts[0]) ?? 0;
    int year = int.tryParse(parts[1]) ?? 0;
    
    if (month < 1 || month > 12) {
      return 'Invalid month';
    }
    
    int currentYear = DateTime.now().year % 100;
    if (year < currentYear) {
      return 'Card expired';
    }
    
    return null;
  }

  String? _validateCVV(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter CVV';
    }
    if (value.length < 3 || value.length > 4) {
      return 'Please enter a valid CVV';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'CVV must contain only digits';
    }
    return null;
  }

  void _formatCardNumber(String value) {
    String cardNumber = value.replaceAll(' ', '');
    String formatted = '';
    
    for (int i = 0; i < cardNumber.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += cardNumber[i];
    }
    
    _cardNumberController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _formatExpDate(String value) {
    String expDate = value.replaceAll('/', '');
    String formatted = '';
    
    for (int i = 0; i < expDate.length && i < 4; i++) {
      if (i == 2) {
        formatted += '/';
      }
      formatted += expDate[i];
    }
    
    _expDateController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _processPayment() async {
    if (_formKey.currentState!.validate()) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Processing payment...'),
              ],
            ),
          );
        },
      );

      try {
        // Simulate payment processing
        await Future.delayed(const Duration(seconds: 2));

        // Update booking status to completed
        await booking_model.BookingService.completeBooking(widget.booking.bookingId);

        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          
          // Navigate to payment successful page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessfulPage(
                booking: widget.booking,
                vehicle: widget.vehicle,
                paymentMethod: 'Credit/Debit Card',
                totalAmount: widget.totalAmount,
                services: widget.services,
                cardType: _cardType,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
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

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: GradientScaffold.dynamicAppBar(
        context: context,
        widget: const Text("Payment"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Payment Title
              const Text(
                "Card Payment",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Card Payment Illustration
              Center(
                child: Image.asset(
                  'assets/images/cardpayment.png',
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Payment Form Card
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
                    // Card Name Field
                    const Text(
                      "Card Name:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _cardNameController,
                      decoration: InputDecoration(
                        hintText: "Enter cardholder name",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                      ),
                      style: const TextStyle(color: Colors.black),
                      validator: _validateCardName,
                      textCapitalization: TextCapitalization.characters,
                    ),
                    if (_errors['cardName'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          _errors['cardName']!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    
                    // Card Number Field
                    const Text(
                      "Card Number:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: InputDecoration(
                        hintText: "1234 5678 9012 3456",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 12,
                        ),
                        suffixIcon: _cardType != null
                            ? Padding(
                                padding: const EdgeInsets.all(12),
                                child: Image.asset(
                                  'assets/images/${_cardType}.png',
                                  width: 30,
                                  height: 20,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : null,
                      ),
                      style: const TextStyle(color: Colors.black),
                      validator: _validateCardNumber,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
                      onChanged: (value) {
                        _formatCardNumber(value);
                      },
                    ),
                    if (_errors['cardNumber'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          _errors['cardNumber']!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    
                    // Exp Date and CVV Row
                    Row(
                      children: [
                        // Exp Date Field
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Exp. Date",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _expDateController,
                                decoration: InputDecoration(
                                  hintText: "MM/YY",
                                  hintStyle: TextStyle(color: Colors.grey.shade500),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 12,
                                  ),
                                ),
                                style: const TextStyle(color: Colors.black),
                                validator: _validateExpDate,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                onChanged: (value) {
                                  _formatExpDate(value);
                                },
                              ),
                              if (_errors['expDate'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    _errors['expDate']!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 15),
                        
                        // CVV Field
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "CVV",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _cvvController,
                                decoration: InputDecoration(
                                  hintText: "123",
                                  hintStyle: TextStyle(color: Colors.grey.shade500),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 12,
                                  ),
                                ),
                                style: const TextStyle(color: Colors.black),
                                validator: _validateCVV,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                obscureText: true,
                              ),
                              if (_errors['cvv'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    _errors['cvv']!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Make Payment Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 3,
                        ),
                        onPressed: _processPayment,
                        child: const Text(
                          "Make Payment",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
