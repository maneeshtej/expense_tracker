import 'package:expense_tracker/screens/Home%20Page/Dashboard/dashboard.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animation = _tabController.animation!;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: const [
              DashboardPage(),
              Center(
                child: Text(
                  "Visualizer Page",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),

          // 🎯 This is the animated pill
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final alignX = 1.0 - (_animation.value * 2);
              return Align(
                alignment: Alignment(alignX, 1.0),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GestureDetector(
                    onTap: () {
                      final newIndex = _tabController.index == 0 ? 1 : 0;
                      _tabController.animateTo(newIndex);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        spacing: 10,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_tabController.index == 1)
                            const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                          if (_tabController.index == 1)
                            const Icon(Icons.dashboard, color: Colors.white),

                          if (_tabController.index == 0)
                            const Icon(Icons.pie_chart, color: Colors.white),

                          if (_tabController.index == 0)
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
