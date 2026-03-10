import 'dart:math';
import 'package:flutter/material.dart';

class DynamicParticlesBackground extends StatefulWidget {
  final Color baseColor;

  const DynamicParticlesBackground({super.key, required this.baseColor});

  @override
  State<DynamicParticlesBackground> createState() =>
      _DynamicParticlesBackgroundState();
}

class _DynamicParticlesBackgroundState extends State<DynamicParticlesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        setState(() {
          _updateParticles();
        });
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initParticles(context.size!);
      _controller.repeat();
    });
  }

  void _initParticles(Size size) {
    _particles.clear();
    for (int i = 0; i < 40; i++) {
      _particles.add(
        _Particle(
          x: _random.nextDouble() * size.width,
          y: _random.nextDouble() * size.height,
          radius: _random.nextDouble() * 20 + 10,
          dx: (_random.nextDouble() - 0.5) * 1.5,
          dy: (_random.nextDouble() - 0.5) * 1.5,
          opacity: _random.nextDouble() * 0.4 + 0.1,
        ),
      );
    }
  }

  void _updateParticles() {
    final size = context.size;
    if (size == null) return;

    for (var particle in _particles) {
      particle.x += particle.dx;
      particle.y += particle.dy;

      // Wrap around edges
      if (particle.x > size.width + particle.radius) {
        particle.x = -particle.radius;
      } else if (particle.x < -particle.radius) {
        particle.x = size.width + particle.radius;
      }

      if (particle.y > size.height + particle.radius) {
        particle.y = -particle.radius;
      } else if (particle.y < -particle.radius) {
        particle.y = size.height + particle.radius;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _ParticlesPainter(
        particles: _particles,
        color: widget.baseColor,
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  double radius;
  double dx;
  double dy;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.dx,
    required this.dy,
    required this.opacity,
  });
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;

  _ParticlesPainter({
    required this.particles,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;
// Use a blend mode to make the particles interact with the base color
      paint.blendMode = BlendMode.overlay;

      final starPath = _createStarPath(particle.x, particle.y, particle.radius);
      canvas.drawPath(starPath, paint);
    }
  }

  Path _createStarPath(double x, double y, double radius) {
    const int points = 5;
    final Path path = Path();
    final double innerRadius = radius / 2.5;
    const double angleOffset = -pi / 2; // Pointing upwards
    final double step = pi / points;

    for (int i = 0; i < points * 2; i++) {
      final double r = (i % 2 == 0) ? radius : innerRadius;
      final double a = i * step + angleOffset;
      final px = x + r * cos(a);
      final py = y + r * sin(a);
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true;
}
