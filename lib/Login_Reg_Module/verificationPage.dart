import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../services/auth_service.dart';
import 'registrationSuccessPage.dart';

class VerificationPage extends StatefulWidget {
  final String email;
  const VerificationPage({super.key, required this.email});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final TextEditingController pinController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _submitting = false;

  Future<void> _verifyOtp() async {
    if (pinController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit code.')),
      );
      return;
    }
    setState(() { _submitting = true; });
    final ok = await _authService.verifyOTP(widget.email, pinController.text.trim());
    setState(() { _submitting = false; });
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => RegistrationSuccessPage(email: widget.email)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid or expired code. Please try again.')),
      );
    }
  }

  Future<void> _resendOtp() async {
    final otp = await _authService.sendOTPEmail(widget.email, username: 'User');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(otp.isNotEmpty ? 'A new code has been sent.' : 'Failed to send code.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                transform: GradientRotation(137 * 3.1415926 / 180),
                colors: [
                  Color.fromRGBO(247, 240, 227, 1),
                  Color.fromRGBO(203, 211, 250, 1),
                  Color.fromRGBO(247, 240, 227, 1),
                ],
                stops: [0.01, 1.0, 0.27],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),

                                     const Text(
                     "Almost There",
                     style: TextStyle(
                       fontSize: 28,
                       fontWeight: FontWeight.bold,
                       color: Colors.black,
                     ),
                   ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Please enter the 6-digit code sent to your email ",
                          style: TextStyle(color: Colors.black54, fontSize: 14),
                        ),
                        TextSpan(
                          text: widget.email,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: " for verification.",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                                     Pinput(
                     controller: pinController,
                     length: 6,
                                           defaultPinTheme: PinTheme(
                        width: 56,
                        height: 56,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 56,
                        height: 56,
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                      ),
                                      ),
                   const SizedBox(height: 30),

                   // Email sent confirmation box
                   Container(
                     width: double.infinity,
                     padding: const EdgeInsets.all(20),
                     decoration: BoxDecoration(
                       color: Colors.white.withOpacity(0.9),
                       borderRadius: BorderRadius.circular(12),
                       border: Border.all(color: Colors.grey.shade200),
                       boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.05),
                           blurRadius: 10,
                           offset: const Offset(0, 2),
                         ),
                       ],
                     ),
                     child: Row(
                       children: [
                         Container(
                           padding: const EdgeInsets.all(12),
                           decoration: BoxDecoration(
                             color: const Color(0xFF246BFD).withOpacity(0.1),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: const Icon(
                             Icons.email_outlined,
                             color: Color(0xFF246BFD),
                             size: 24,
                           ),
                         ),
                         const SizedBox(width: 16),
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               const Text(
                                 "Verification Email Sent",
                                 style: TextStyle(
                                   fontSize: 16,
                                   fontWeight: FontWeight.w600,
                                   color: Colors.black,
                                 ),
                               ),
                               const SizedBox(height: 4),
                               Text(
                                 "We have successfully sent a 6-digit code to ${widget.email}",
                                 style: const TextStyle(
                                   fontSize: 14,
                                   color: Colors.grey,
                                   height: 1.3,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ],
                     ),
                   ),
                   const SizedBox(height: 25),

                   // Verify 按钮
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF246BFD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _submitting ? null : _verifyOtp,
                      child: _submitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Verify",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Resend link
                  Center(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: _resendOtp,
                          child: const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "Didn't receive any code? ",
                                  style: TextStyle(color: Colors.black54),
                                ),
                                TextSpan(
                                  text: "Resend Again",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Request new code if not received",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 20,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
