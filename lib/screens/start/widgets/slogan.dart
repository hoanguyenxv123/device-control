import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Slogan extends StatefulWidget {
  final String slogan;
  final List<Color> _colors = [
    Color(0xFF1E88E5),
    Color(0xFF42A5F5),
    Color(0xFF90CAF9),
  ];

  Slogan({super.key, required this.slogan});

  @override
  _SloganState createState() => _SloganState();
}

class _SloganState extends State<Slogan> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeInAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/icons/app_icon.png', width: 40, height: 40),
                const SizedBox(width: 8),
                ShaderMask(
                  shaderCallback:
                      (bounds) => LinearGradient(
                        colors: widget._colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    'Smart Control',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ShaderMask(
                shaderCallback:
                    (bounds) => LinearGradient(
                      colors: widget._colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Text(
                  widget.slogan,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
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
