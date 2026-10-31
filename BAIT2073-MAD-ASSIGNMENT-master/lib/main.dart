import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mad_assignment/widgets/bottom_nav_bar.dart';
import 'onboarding/onboarding_page.dart';
import 'Login_Reg_Module/registerPage.dart';
import 'Login_Reg_Module/loginPage.dart';
import 'Login_Reg_Module/verificationPage.dart';
import 'Login_Reg_Module/forgotPassword.dart';
import 'services/user_storage_service.dart';
import 'notification.dart';

// Global navigator key for navigation from outside the widget tree
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Global Firebase API instance for notifications
final FirebaseAPI firebaseAPI = FirebaseAPI();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize user storage service
  await UserStorageService.init();
  
  // Initialize notifications
  await firebaseAPI.initNotification();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Greenstem Car Service',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF4B0082),
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        // When navigating to verify, pass the email via arguments or push with constructor.
        '/verify': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
          return VerificationPage(email: args ?? '');
        },
        '/home': (context) => const BottomNavBar(),
      },
    );
  }
}
