import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../gpa_calculator_screen.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  bool isLastPage = false;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingSeen', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const GpaCalculatorScreen(isGuest: true),
      ),
    );
  }

  Widget _buildPage({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: iconColor ?? Theme.of(context).primaryColor,
          ).animate().scale(duration: 600.ms).fadeIn(),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ).animate().slideY(begin: 0.3),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildPage(
        icon: Icons.calculate_rounded,
        title: "Track your GPA, CGPA and CWA easily",
        subtitle:
            "Get instant, accurate results in seconds. Built with TTU students in mind.",
        iconColor: Colors.blue,
      ),
      _buildPage(
        icon: Icons.trending_up_rounded,
        title: "Monitor Your Progress",
        subtitle:
            "Track your academic journey semester by semester, with detailed analytics and insights.",
        iconColor: Colors.green,
      ),
      _buildPage(
        icon: Icons.offline_bolt_rounded,
        title: "Works Offline",
        subtitle:
            "Access your records anytime, anywhere. No internet required.",
        iconColor: Colors.orange,
      ),
    ];

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.only(bottom: 80),
        child: PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() {
              isLastPage = index == pages.length - 1;
            });
          },
          children: pages,
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(onPressed: () => _finish(), child: const Text("Skip")),
            Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: pages.length,
                effect: WormEffect(
                  spacing: 16,
                  dotColor: Colors.grey.shade300,
                  activeDotColor: Theme.of(context).primaryColor,
                ),
                onDotClicked:
                    (index) => _controller.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    ),
              ),
            ),
            TextButton(
              onPressed: () {
                if (isLastPage) {
                  _finish();
                } else {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Text(isLastPage ? "Done" : "Next"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
