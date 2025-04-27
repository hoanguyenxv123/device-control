import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:test_control/screens/start/widgets/button_part.dart';
import 'package:test_control/screens/start/widgets/slogan.dart';

import '../../constant/app_colors.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/logo_start.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Phần nội dung onboarding
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFF5F5F5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25),
                  topLeft: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Expanded(
                    child: PageView(
                      controller: _controller,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        buildPage(
                          title: "Welcome to SmartControl!",
                          subtitle:
                              "Easily manage and control your home devices.",
                          slogan: 'Smart Living, Effortless Control!',
                        ),
                        buildPage(
                          title: "Control at Your Fingertips",
                          subtitle:
                              "Turn your lights, fans, and more on or off with a tap.",
                          slogan: 'Tap. Control. Relax!',
                        ),
                        buildPage(
                          title: "Get Started Now!",
                          subtitle:
                              "Experience the convenience of a smart home.",
                          slogan: 'Simple, Fast, and Smart!',
                        ),
                      ],
                    ),
                  ),

                  // Indicator
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: EdgeInsets.only(right: 30, bottom: 30),
                      child: SmoothPageIndicator(
                        controller: _controller,
                        count: 3,
                        effect: WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor: AppColors.primaryColor,
                          dotColor: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  ButtonPart(),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage({
    required String title,
    required String subtitle,
    required String slogan,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Slogan(slogan: slogan),
          SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
