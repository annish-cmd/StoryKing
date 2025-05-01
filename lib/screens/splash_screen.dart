/*
 * SPLASH SCREEN
 * ------------
 * This screen is displayed when the app first launches, showing a visually
 * appealing animation while authentication state is checked.
 * 
 * Key functionality:
 * 1. Displays app branding and animations during startup
 * 2. Checks user authentication state in the background
 * 3. Redirects to appropriate screen based on auth state:
 *    - If logged in: MainScreen
 *    - If not logged in: AuthScreen
 * 
 * Visual features:
 * - Animated logo with scale and fade effects
 * - Particle system animations for dynamic background
 * - Text animations with typewriter effect
 * - Smooth transitions to next screen
 * 
 * Technical implementation:
 * - Uses multiple animation controllers for complex animations
 * - Performs authentication check concurrently with animations
 * - Uses page route transitions for smooth navigation
 */

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
// import 'package:animated_text_kit/animated_text_kit.dart';
import 'auth_screen.dart';
import 'main_screen.dart';
// import '../services/auth_service.dart';
import '../services/auth/auth_service.dart';

class SplashScreen extends StatefulWidget {
  final AuthService authService;
  final Function toggleTheme;
  final Function(double) setTextScaleFactor;

  const SplashScreen({
    Key? key,
    required this.authService,
    required this.toggleTheme,
    required this.setTextScaleFactor,
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _particleController;
  late AnimationController _textController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _textOpacity;
  final List<Particle> particles = [];
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeParticles();
    _checkAuthAndNavigate();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _showText = true;
        });
        _textController.forward();
      }
    });
  }

  void _initializeParticles() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      particles.add(
        Particle(
          position: Offset(
            random.nextDouble() * 400 - 200,
            random.nextDouble() * 400 - 200,
          ),
          color: Color.lerp(
            const Color(0xFFE0F7FA),
            const Color(0xFF1a237e),
            random.nextDouble(),
          )!,
          size: random.nextDouble() * 8 + 2,
        ),
      );
    }
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for all animations to complete with a smoother timing
    await Future.delayed(const Duration(milliseconds: 4200));

    if (!mounted) return;

    final currentUser = await widget.authService.getCurrentUser();
    if (!mounted) return;

    if (currentUser != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MainScreen(
            authService: widget.authService,
            toggleTheme: widget.toggleTheme,
            setTextScaleFactor: widget.setTextScaleFactor,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => AuthScreen(
            authService: widget.authService,
            toggleTheme: widget.toggleTheme,
            setTextScaleFactor: widget.setTextScaleFactor,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    _textController.dispose();
    super.dispose();
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
                colors: [
                  Color(0xFF1a237e),
                  Color(0xFF0277bd),
                  Color(0xFF00bcd4),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: BackgroundPainter(),
                  ),
                ),
                AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ParticlePainter(
                        particles: particles,
                        progress: _particleController.value,
                      ),
                      size: Size.infinite,
                    );
                  },
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _slideAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.flutter_dash,
                                  size: 80,
                                  color: Color(0xFF1a237e),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 70),
                      if (_showText)
                        FadeTransition(
                          opacity: _textOpacity,
                          child: Column(
                            children: [
                              const Text(
                                'Together',
                                style: TextStyle(
                                  fontSize: 44,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                  letterSpacing: 4,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: Offset(2, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'we are',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w200,
                                  color: Colors.white.withOpacity(0.95),
                                  letterSpacing: 8,
                                ),
                              ),
                              const SizedBox(height: 30),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Color(0xFFE0F7FA),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ).createShader(bounds),
                                child: const Text(
                                  'ENET',
                                  style: TextStyle(
                                    fontSize: 72,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 10,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        offset: Offset(3, 3),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Particle {
  Offset position;
  Color color;
  double size;

  Particle({
    required this.position,
    required this.color,
    required this.size,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity((1 - progress) * 0.7)
        ..style = PaintingStyle.fill;

      final position = center + particle.position * progress;
      canvas.drawCircle(position, particle.size * (1 - progress * 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(0, size.height * 0.2)
      ..quadraticBezierTo(
          size.width * 0.5, size.height * 0.1, size.width, size.height * 0.3)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    final path2 = Path()
      ..moveTo(size.width, size.height * 0.8)
      ..quadraticBezierTo(
          size.width * 0.5, size.height * 0.9, 0, size.height * 0.7)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
