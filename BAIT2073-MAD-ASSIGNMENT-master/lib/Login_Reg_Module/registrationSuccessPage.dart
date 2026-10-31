import 'package:flutter/material.dart';

class RegistrationSuccessPage extends StatelessWidget {
  final String email;
  const RegistrationSuccessPage({Key? key, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SuccessScreen(email: email);
  }
}

class SuccessScreen extends StatelessWidget {
  final String email;
  const SuccessScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            transform: GradientRotation(320 * 3.1415926 / 180),
            colors: [
              Color.fromRGBO(247, 240, 227, 1),
              Color.fromRGBO(203, 211, 250, 1),
              Color.fromRGBO(247, 240, 227, 1),
            ],
            stops: [0.01, 1.0, 0.27],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
               Expanded(
                 flex: 3,
                 child: Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 20),
                   child: Center(
                     child: Image.asset(
                       'assets/success_pic.png',
                       width: double.infinity,
                       height: double.infinity,
                       fit: BoxFit.cover,
                     ),
                   ),
                 ),
               ),
              
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text(
                        "Successfully",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      const Text(
                        "Discover the application right now !",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/home');
                          },
                          child: const Text(
                            "Explore Now!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


