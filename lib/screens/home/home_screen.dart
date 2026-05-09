import 'package:flutter/material.dart';
import 'package:round_timer_app/screens/config/config_drawer.dart';
import 'package:round_timer_app/screens/home/widgets/home_body.dart';
import 'package:round_timer_app/screens/routines/routines_screen.dart';
import 'package:round_timer_app/widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _reloadKey = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ROUNDFLOW'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: ConfigDrawer(onGuardado: () => setState(() => _reloadKey++)),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeBody(key: ValueKey(_reloadKey)),
          RoutinesScreen(onSessionStarted: () => setState(() => _reloadKey++)),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
