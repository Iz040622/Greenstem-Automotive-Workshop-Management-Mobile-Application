import 'package:flutter/material.dart';
import 'dart:ui';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> with TickerProviderStateMixin {
  int _currentPage = 0;
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _bounceAnimation;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: "Flexible Service Scheduling",
      description: "Easily book, view, and manage your upcoming and past vehicle service appointments – all at your fingertips, anytime.",
      mainIcon: "assets/on_boarding/calender_ob.png",
      topRightIcon: "assets/on_boarding/map_ob.png",
      bottomLeftIcon: "assets/on_boarding/clock_ob.png",
      gradientColors: [
        Color(0xFF8B5CF6), // Light purple
        Color(0xFF7C3AED), // Dark purple
      ],
      buttonColor: Color(0xFF8B5CF6),
      dotColor: Color(0xFF8B5CF6),
    ),
    OnboardingItem(
      title: "Real-Time Service Tracking",
      description: "Stay informed with live updates on your car's servicing progress - from inspection to collection - so you're never left guessing.",
      mainIcon: "assets/on_boarding/mail_ob.png",
      topRightIcon: "assets/on_boarding/compass_ob.png",
      bottomLeftIcon: "assets/on_boarding/clock_ob.png",
      gradientColors: [
        Color(0xFF3B82F6), // Light blue
        Color(0xFF1D4ED8), // Dark blue
      ],
      buttonColor: Color(0xFF3B82F6),
      dotColor: Color(0xFF3B82F6),
    ),
    OnboardingItem(
      title: "Seamless Digital Payment",
      description: "Review your service bills and make secure payments directly in the app – no queues, no hassle.",
      mainIcon: "assets/on_boarding/discount_ob.png",
      topRightIcon: "assets/on_boarding/clock_ob.png",
      bottomLeftIcon: "assets/on_boarding/cash_ob.png",
      gradientColors: [
        Color(0xFF10B981), // Light green
        Color(0xFF059669), // Dark green
      ],
      buttonColor: Color(0xFF10B981),
      dotColor: Color(0xFF10B981),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // Main animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Scale animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Rotation animation controller
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Bounce animation controller
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    // Rotation animation
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.easeInOut,
    ));
    
    // Bounce animation
    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.bounceOut,
    ));
    
    // Start all animations
    _animationController.forward();
    _scaleController.forward();
    _rotateController.forward();
    _bounceController.forward();
    
    // Loop bounce animation
    _bounceController.repeat(reverse: true);
    
    // Loop rotation animation
    _rotateController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingItems.length - 1) {
      // Exaggerated page transition animation
      _animationController.reverse();
      _scaleController.reverse();
      _rotateController.reverse();
      _bounceController.reverse();
      
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _currentPage++;
        });
        
        // Restart all animations
        _animationController.forward();
        _scaleController.forward();
        _rotateController.forward();
        _bounceController.forward();
        
        // Restart loop animations
        _bounceController.repeat(reverse: true);
        _rotateController.repeat(reverse: true);
      });
    } else {
      // Exaggerated Get Started animation
      _animationController.reverse();
      _scaleController.reverse();
      _rotateController.reverse();
      _bounceController.reverse();
      
      Future.delayed(const Duration(milliseconds: 400), () {
        Navigator.pushReplacementNamed(context, '/register');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _onboardingItems[_currentPage].gradientColors,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Top icon area
                    Expanded(
                      flex: 3,
                      child: Stack(
                        children: [
                          // Decorative circle - top left (exaggerated animation)
                          Positioned(
                            top: 120,
                            left: (_currentPage == 0 || _currentPage == 2) ? 60 : null,
                            right: _currentPage == 1 ? 60 : null,
                            child: AnimatedBuilder(
                              animation: _rotateAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotateAnimation.value * 0.5,
                                  child: Transform.scale(
                                    scale: 0.8 + (_rotateAnimation.value * 0.4),
                                    child: Container(
                                      width: 40,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(18),
                                          topRight: Radius.circular(18),
                                          bottomLeft: Radius.circular(22),
                                          bottomRight: Radius.circular(22),
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.2),
                                            Colors.white.withOpacity(0.1),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Decorative circle - bottom right (exaggerated animation)
                          Positioned(
                            bottom: 120,
                            right: (_currentPage == 0 || _currentPage == 2) ? 60 : null,
                            left: _currentPage == 1 ? 60 : null,
                            child: AnimatedBuilder(
                              animation: _bounceAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 0.6 + (_bounceAnimation.value * 0.8),
                                  child: Transform.rotate(
                                    angle: _bounceAnimation.value * 0.4,
                                    child: Container(
                                      width: 35,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.18),
                                            Colors.white.withOpacity(0.09),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.28),
                                          width: 0.9,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Main icon - calendar/mail (exaggerated animation)
                          Center(
                            child: AnimatedBuilder(
                              animation: Listenable.merge([_scaleAnimation, _rotateAnimation, _bounceAnimation]),
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: Transform.rotate(
                                    angle: _rotateAnimation.value * 0.1, // Slight rotation
                                    child: Transform.translate(
                                      offset: Offset(0, _bounceAnimation.value * 10), // Bounce effect
                                      child: Container(
                                        width: 240,
                                        height: 240,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(120),
                                            topRight: Radius.circular(120),
                                            bottomLeft: Radius.circular(140),
                                            bottomRight: Radius.circular(140),
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white.withOpacity(0.3),
                                              Colors.white.withOpacity(0.15),
                                              Colors.white.withOpacity(0.05),
                                            ],
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.4),
                                            width: 1.5,
                                          ),
                                          boxShadow: [
                                            // Soft glow effect
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.15),
                                              blurRadius: 40,
                                              spreadRadius: 10,
                                              offset: const Offset(0, 0),
                                            ),
                                            BoxShadow(
                                              color: Colors.purple.withOpacity(0.1),
                                              blurRadius: 60,
                                              spreadRadius: 20,
                                              offset: const Offset(0, 0),
                                            ),
                                            // Shadow effect
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 30,
                                              spreadRadius: 0,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(120),
                                            topRight: Radius.circular(120),
                                            bottomLeft: Radius.circular(140),
                                            bottomRight: Radius.circular(140),
                                          ),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(120),
                                                  topRight: Radius.circular(120),
                                                  bottomLeft: Radius.circular(140),
                                                  bottomRight: Radius.circular(140),
                                                ),
                                                color: Colors.white.withOpacity(0.1),
                                              ),
                                              child: Center(
                                                child: Container(
                                                  padding: const EdgeInsets.all(20),
                                                                                                                                                       child: Image.asset(
                                                    _onboardingItems[_currentPage].mainIcon,
                                                    width: _currentPage == 1 ? 200 : (_currentPage == 2 ? 180 : 140), // Enlarge mail icon on second page, discount icon on third page
                                                    height: _currentPage == 1 ? 200 : (_currentPage == 2 ? 180 : 140),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          // Top right icon - map/top left icon - compass/clock (exaggerated animation)
                          Positioned(
                            top: 100,
                            right: (_currentPage == 0 || _currentPage == 2) ? 80 : null,
                            left: _currentPage == 1 ? 80 : null,
                            child: AnimatedBuilder(
                              animation: _bounceAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 0.8 + (_bounceAnimation.value * 0.4),
                                  child: Transform.rotate(
                                    angle: _bounceAnimation.value * 0.2,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.3),
                                            Colors.white.withOpacity(0.15),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.4),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 15,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withOpacity(0.1),
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                _onboardingItems[_currentPage].topRightIcon,
                                                width: 45,
                                                height: 45,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Bottom left icon - clock/bottom right icon - clock/cash (exaggerated animation)
                          Positioned(
                            bottom: 100,
                            left: (_currentPage == 0 || _currentPage == 2) ? 80 : null,
                            right: _currentPage == 1 ? 80 : null,
                            child: AnimatedBuilder(
                              animation: _rotateAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 0.7 + (_rotateAnimation.value * 0.6),
                                  child: Transform.rotate(
                                    angle: _rotateAnimation.value * 0.3,
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.3),
                                            Colors.white.withOpacity(0.15),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.4),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 15,
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withOpacity(0.1),
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                _onboardingItems[_currentPage].bottomLeftIcon,
                                                width: 35,
                                                height: 35,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Bottom content area
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title
                              Text(
                                _onboardingItems[_currentPage].title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF2D3748),
                                  fontSize: 24,
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Description
                              Text(
                                _onboardingItems[_currentPage].description,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: const Color(0xFF4A5568),
                                  height: 1.3,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 25),
                              
                              // Pagination indicator (exaggerated animation)
                              AnimatedBuilder(
                                animation: _bounceAnimation,
                                builder: (context, child) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      3,
                                      (index) => Transform.scale(
                                        scale: index == _currentPage 
                                            ? 1.0 + (_bounceAnimation.value * 0.3)
                                            : 1.0,
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                          width: index == _currentPage ? 12 : 8,
                                          height: index == _currentPage ? 12 : 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: index == _currentPage 
                                                ? _onboardingItems[_currentPage].dotColor
                                                : const Color(0xFFE2E8F0),
                                            boxShadow: index == _currentPage ? [
                                              BoxShadow(
                                                color: _onboardingItems[_currentPage].dotColor.withOpacity(0.5),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ] : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              
                              // Button with enhanced styling
                              Container(
                                width: double.infinity,
                                height: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      _onboardingItems[_currentPage].buttonColor,
                                      _onboardingItems[_currentPage].buttonColor.withOpacity(0.8),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _onboardingItems[_currentPage].buttonColor.withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 8),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _nextPage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _currentPage == _onboardingItems.length - 1 ? "Get Started" : "Next",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        _currentPage == _onboardingItems.length - 1 
                                            ? Icons.rocket_launch 
                                            : Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String mainIcon;
  final String topRightIcon;
  final String bottomLeftIcon;
  final List<Color> gradientColors;
  final Color buttonColor;
  final Color dotColor;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.mainIcon,
    required this.topRightIcon,
    required this.bottomLeftIcon,
    required this.gradientColors,
    required this.buttonColor,
    required this.dotColor,
  });
}
