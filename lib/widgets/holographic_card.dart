import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class HolographicCard extends StatefulWidget {
  final Widget child;
  final bool isEnabled;

  const HolographicCard({
    super.key,
    required this.child,
    this.isEnabled = true,
  });

  @override
  State<HolographicCard> createState() => _HolographicCardState();
}

class _HolographicCardState extends State<HolographicCard> {
  double _xTilt = 0.0;
  double _yTilt = 0.0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.isEnabled) {
      _initSensors();
    }
  }

  void _initSensors() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      if (mounted) {
        setState(() {
          // Normalize tilt values between -1.0 and 1.0 (roughly)
          // X corresponds to left/right tilt
          // Y corresponds to up/down tilt
          _xTilt = (event.x / 10).clamp(-1.0, 1.0);
          _yTilt = (event.y / 10).clamp(-1.0, 1.0);
        });
      }
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HolographicCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled && !oldWidget.isEnabled) {
      _initSensors();
    } else if (!widget.isEnabled && oldWidget.isEnabled) {
      _accelerometerSubscription?.cancel();
      _accelerometerSubscription = null;
      setState(() {
        _xTilt = 0.0;
        _yTilt = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) return widget.child;

    return ShaderMask(
      blendMode: BlendMode.overlay,
      shaderCallback: (bounds) {
        return LinearGradient(
          // Move the gradient based on tilt
          begin: Alignment(
            _xTilt * 2 - 1,
            _yTilt * 2 - 1,
          ),
          end: Alignment(
            _xTilt * 2 + 1,
            _yTilt * 2 + 1,
          ),
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.6),
            Colors.purpleAccent.withOpacity(0.3),
            Colors.cyanAccent.withOpacity(0.3),
            Colors.white.withOpacity(0.6),
            Colors.white.withOpacity(0.0),
          ],
          stops: const [
            0.0,
            0.2,
            0.4,
            0.6,
            0.8,
            1.0,
          ],
        ).createShader(bounds);
      },
      child: widget.child,
    );
  }
}
