import 'package:flutter/material.dart';
import 'package:mad_assignment/Profile/profile.dart';

import '../booking_list.dart';
import '../home.dart';
import '../make_booking.dart';
import 'gradient_scaffold.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Page> pages = [
      Page(
        body: HomeScreen(goToBookings: (){
          setState(() {
            _selectedIndex = 1;
          });
        }),
        title: Image.asset(
          'assets/images/logo.png',
          width: 120,
          height: 100,
        ),
        icon: Icons.home,
        label: 'Home',
        color: Color(0xFF5B37B7),
      ),
      Page(
        body: BookingList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MakeBooking(),
              ),
            );
          },
          child: Icon(Icons.add),
        ),
        title: Text("Booking"),
        icon: Icons.event,
        label: 'Booking',
        color: Color(0xFFB73737),
      ),
      Page(
        body: ProfilePage(),
        title: Text("Profile"),
        icon: Icons.person,
        label: 'Profile',
        color: Color(0xFF374EB7),
      ),
    ];

    final currentPage = pages[_selectedIndex];

    return GradientScaffold(
      appBar: GradientScaffold.dynamicAppBar(
          context: context,
          widget: currentPage.title
      ),
      body: currentPage.body,
      floatingActionButton: currentPage.floatingActionButton,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3EFFC), Color(0xFF6F7BF7)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(pages.length, (index) {
                  bool selected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = index),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 150),
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? currentPage.color.withAlpha((0.2 * 255).toInt())
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: selected ? currentPage.color : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            pages[index].icon,
                            color: selected ? currentPage.color : Colors.grey,
                          ),
                          if (selected) ...[
                            SizedBox(width: 8),
                            Text(
                              currentPage.label,
                              style: TextStyle(
                                color: currentPage.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class Page {
  final Widget body;
  final Widget? floatingActionButton;
  final Widget title;
  final IconData icon;
  final String label;
  final Color color;

  Page({required this.body, this.floatingActionButton, required this.title, required this.icon, required this.label, required this.color});
}

