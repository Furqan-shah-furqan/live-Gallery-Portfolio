import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'scroll_reveal.dart';

/// Reusable styling tokens for the Bento OS widgets matching Reference Image 2
abstract final class BentoStyle {
  static const double cardRadius = 38.0;
  static const Color darkCard = Color(0xFF0D0F16);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0x1AFFFFFF);
  static const Color lightCardBorder = Color(0x0F000000);
  static const Color neonLime = Color(0xFFD4FF00);
  static const Color safetyOrange = Color(0xFFFF5722);
  static const Color cyberBlue = Color(0xFF2563EB);
  static const Color textMuted = Color(0xFF8E95A5);
  static const Color textDark = Color(0xFF0E1118);
}

/// 1. WiFi Status Widget (White Card)
class BentoWifiWidget extends StatefulWidget {
  const BentoWifiWidget({super.key});

  @override
  State<BentoWifiWidget> createState() => _BentoWifiWidgetState();
}

class _BentoWifiWidgetState extends State<BentoWifiWidget> {
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BentoStyle.lightCard,
        borderRadius: BorderRadius.circular(BentoStyle.cardRadius),
        border: Border.all(color: BentoStyle.lightCardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: BentoStyle.cyberBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wifi, color: Colors.white, size: 22),
              ),
              const Icon(Icons.north_east_rounded, size: 18, color: BentoStyle.textMuted),
            ],
          ),
          const Spacer(),
          const Text(
            'WiFi',
            style: TextStyle(
              color: BentoStyle.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _enabled ? 'On .alpha\'s_wifi' : 'Disconnected',
            style: const TextStyle(
              color: BentoStyle.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () => setState(() => _enabled = !_enabled),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                width: 44,
                height: 24,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: _enabled ? const Color(0xFF4ADE80) : const Color(0xFFE2E8F0),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  alignment: _enabled ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Color(0x20000000),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 2. Arrival Flight / Pipeline Timeline Widget (Black Card)
class BentoFlightWidget extends StatelessWidget {
  const BentoFlightWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BentoStyle.darkCard,
        borderRadius: BorderRadius.circular(BentoStyle.cardRadius),
        border: Border.all(color: BentoStyle.cardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Arrival in',
            style: TextStyle(
              color: BentoStyle.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Text(
            '53mins',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('14:30', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('LHD', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                  Text('London', style: TextStyle(color: BentoStyle.textMuted, fontSize: 9)),
                ],
              ),
              Icon(Icons.flight_rounded, color: Color(0xFF38BDF8), size: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text('14:30', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('LHD', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900)),
                  Text('Paris', style: TextStyle(color: BentoStyle.textMuted, fontSize: 9)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Orange progress line with nodes
          Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 80,
                height: 3,
                decoration: BoxDecoration(
                  color: BentoStyle.safetyOrange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Positioned(
                left: 74,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: BentoStyle.safetyOrange,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 3. Speed & System Metrics Gauge Widget (Wide White Card)
class BentoSpeedGaugeWidget extends StatelessWidget {
  const BentoSpeedGaugeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 170,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: BentoStyle.lightCard,
        borderRadius: BorderRadius.circular(BentoStyle.cardRadius),
        border: Border.all(color: BentoStyle.lightCardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                '2.8km',
                style: TextStyle(
                  color: BentoStyle.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: BentoStyle.textDark, width: 2),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '64',
                      style: TextStyle(
                        color: BentoStyle.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'km',
                      style: TextStyle(
                        color: BentoStyle.textMuted,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const <Widget>[
              _MetricColumn(label: 'Duration', value: '08:21'),
              _MetricColumn(label: 'Avg.speed', value: '187km/h'),
              _MetricColumn(label: 'Calories', value: '134kcal'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: BentoStyle.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: BentoStyle.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

/// 4. Habits Daily Writing Widget (Black Card)
class BentoHabitsWidget extends StatelessWidget {
  const BentoHabitsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BentoStyle.darkCard,
        borderRadius: BorderRadius.circular(BentoStyle.cardRadius),
        border: Border.all(color: BentoStyle.cardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Habits',
            style: TextStyle(
              color: BentoStyle.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Daily Writing',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            '10m left',
            style: TextStyle(
              color: BentoStyle.safetyOrange,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              width: 38,
              height: 38,
              child: CustomPaint(
                painter: _ArcProgressPainter(
                  progress: 0.72,
                  color: BentoStyle.safetyOrange,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcProgressPainter extends CustomPainter {
  _ArcProgressPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;
    final bgPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final progPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

/// 5. Live Analog Clock Widget (White Card)
class BentoLiveClockWidget extends StatefulWidget {
  const BentoLiveClockWidget({super.key});

  @override
  State<BentoLiveClockWidget> createState() => _BentoLiveClockWidgetState();
}

class _BentoLiveClockWidgetState extends State<BentoLiveClockWidget> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BentoStyle.lightCard,
        borderRadius: BorderRadius.circular(BentoStyle.cardRadius),
        border: Border.all(color: BentoStyle.lightCardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 130,
          height: 130,
          child: CustomPaint(
            painter: _AnalogClockPainter(now: _now),
          ),
        ),
      ),
    );
  }
}

class _AnalogClockPainter extends CustomPainter {
  _AnalogClockPainter({required this.now});

  final DateTime now;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer clock face
    final facePaint = Paint()..color = const Color(0xFFF8FAFC);
    canvas.drawCircle(center, radius, facePaint);

    // Numerals: XII, III, VI, IX
    const numerals = <String>['XII', 'III', 'VI', 'IX'];
    final offsets = <Offset>[
      Offset(center.dx, center.dy - radius + 18),
      Offset(center.dx + radius - 18, center.dy),
      Offset(center.dx, center.dy + radius - 18),
      Offset(center.dx - radius + 18, center.dy),
    ];

    for (int i = 0; i < 4; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: numerals[i],
          style: const TextStyle(
            color: BentoStyle.textDark,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          offsets[i].dx - textPainter.width / 2,
          offsets[i].dy - textPainter.height / 2,
        ),
      );
    }

    // Hour hand
    final hour = now.hour % 12 + now.minute / 60.0;
    final hourAngle = (hour * math.pi / 6) - math.pi / 2;
    final hourPaint = Paint()
      ..color = BentoStyle.textDark
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx + 30 * math.cos(hourAngle), center.dy + 30 * math.sin(hourAngle)),
      hourPaint,
    );

    // Minute hand
    final minAngle = (now.minute * math.pi / 30) - math.pi / 2;
    final minPaint = Paint()
      ..color = BentoStyle.textDark
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx + 44 * math.cos(minAngle), center.dy + 44 * math.sin(minAngle)),
      minPaint,
    );

    // Second hand (Red)
    final secAngle = (now.second * math.pi / 30) - math.pi / 2;
    final secPaint = Paint()
      ..color = BentoStyle.safetyOrange
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx + 48 * math.cos(secAngle), center.dy + 48 * math.sin(secAngle)),
      secPaint,
    );

    // Center pin
    canvas.drawCircle(center, 3.5, Paint()..color = BentoStyle.safetyOrange);
  }

  @override
  bool shouldRepaint(covariant _AnalogClockPainter oldDelegate) => true;
}

/// 6. Audio Player Scrubber Widget (Wide White Pill Card)
class BentoAudioPlayerWidget extends StatefulWidget {
  const BentoAudioPlayerWidget({super.key});

  @override
  State<BentoAudioPlayerWidget> createState() => _BentoAudioPlayerWidgetState();
}

class _BentoAudioPlayerWidgetState extends State<BentoAudioPlayerWidget> {
  bool _isPlaying = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 170,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: BentoStyle.lightCard,
        borderRadius: BorderRadius.circular(BentoStyle.cardRadius),
        border: Border.all(color: BentoStyle.lightCardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFFF97316), Color(0xFFFB923C)],
                  ),
                ),
                child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'UP!',
                      style: TextStyle(
                        color: BentoStyle.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Forrest frank',
                      style: TextStyle(
                        color: BentoStyle.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.graphic_eq_rounded, color: Color(0xFF10B981), size: 20),
            ],
          ),
          const Spacer(),
          // Progress bar
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const <Widget>[
                  Text('1:25', style: TextStyle(color: BentoStyle.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text('2:35', style: TextStyle(color: BentoStyle.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Container(
                    width: 140,
                    height: 4,
                    decoration: BoxDecoration(
                      color: BentoStyle.textDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Positioned(
                    left: 136,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: BentoStyle.textDark,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const Icon(Icons.shuffle_rounded, size: 18, color: BentoStyle.textMuted),
              const Icon(Icons.skip_previous_rounded, size: 22, color: BentoStyle.textDark),
              GestureDetector(
                onTap: () => setState(() => _isPlaying = !_isPlaying),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: BentoStyle.textDark,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const Icon(Icons.skip_next_rounded, size: 22, color: BentoStyle.textDark),
              const Icon(Icons.repeat_rounded, size: 18, color: BentoStyle.textMuted),
            ],
          ),
        ],
      ),
    );
  }
}

/// 7. Battery Power Status Widget (White Card with Orange Bars)
class BentoPowerWidget extends StatelessWidget {
  const BentoPowerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BentoStyle.lightCard,
        borderRadius: BorderRadius.circular(BentoStyle.cardRadius),
        border: Border.all(color: BentoStyle.lightCardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: const <Widget>[
              Icon(Icons.bolt_rounded, color: BentoStyle.safetyOrange, size: 20),
              SizedBox(width: 4),
              Text(
                '57%',
                style: TextStyle(
                  color: BentoStyle.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Spacer(),
          // 4 vertical battery level bars matching Reference 2
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const <Widget>[
              _BatteryBar(height: 48, active: true),
              _BatteryBar(height: 58, active: true),
              _BatteryBar(height: 34, active: true),
              _BatteryBar(height: 52, active: false),
            ],
          ),
          const Spacer(),
          const Text(
            '~5 hours',
            style: TextStyle(
              color: BentoStyle.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BatteryBar extends StatelessWidget {
  const _BatteryBar({required this.height, required this.active});

  final double height;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: height,
      decoration: BoxDecoration(
        color: active ? BentoStyle.safetyOrange : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

/// 8. Daily Activities Calendar Heatmap Widget (Large Black Card)
class BentoActivitiesCalendarWidget extends StatelessWidget {
  const BentoActivitiesCalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 355,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BentoStyle.darkCard,
        borderRadius: BorderRadius.circular(BentoStyle.cardRadius),
        border: Border.all(color: BentoStyle.cardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x35000000),
            blurRadius: 32,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Daily\nActivities',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: const <Widget>[
                    Icon(Icons.calendar_month_rounded, size: 13, color: Colors.white70),
                    SizedBox(width: 6),
                    Text(
                      'August | 2026',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Day grid (circular nodes with lime green & orange highlights)
          Expanded(
            child: GridView.count(
              crossAxisCount: 7,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: List<Widget>.generate(28, (index) {
                final day = index + 1;
                // Specific highlights matching reference image: 2, 5, 6 (lime), 7 (orange)
                Color? highlight;
                Color textColor = Colors.white70;

                if (day == 2 || day == 5 || day == 6) {
                  highlight = BentoStyle.neonLime;
                  textColor = Colors.black;
                } else if (day == 7) {
                  highlight = BentoStyle.safetyOrange;
                  textColor = Colors.white;
                }

                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: highlight ?? const Color(0xFF1E2230),
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// 9. Camera Status Widget (White Card with Red Record Button)
class BentoCameraWidget extends StatelessWidget {
  const BentoCameraWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: BentoStyle.lightCard,
        borderRadius: BorderRadius.circular(BentoStyle.cardRadius),
        border: Border.all(color: BentoStyle.lightCardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFF38BDF8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: BentoStyle.safetyOrange,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.stop_rounded, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'Camera',
            style: TextStyle(
              color: BentoStyle.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Recordings',
            style: TextStyle(
              color: BentoStyle.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Text(
            '00.12.30',
            style: TextStyle(
              color: BentoStyle.textMuted,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 10. Gate / Terminal Widget (White Square Card)
class BentoGateWidget extends StatelessWidget {
  const BentoGateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BentoStyle.lightCard,
        borderRadius: BorderRadius.circular(BentoStyle.cardRadius),
        border: Border.all(color: BentoStyle.lightCardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Align(
            alignment: Alignment.topRight,
            child: Icon(Icons.north_east_rounded, size: 18, color: BentoStyle.textDark),
          ),
          const Spacer(),
          const Text(
            'B18',
            style: TextStyle(
              color: BentoStyle.textDark,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Gate opens',
            style: TextStyle(
              color: BentoStyle.textDark,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Gate department in 20mins',
            style: TextStyle(
              color: BentoStyle.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 11. Audio Recorder / Waveform Widget (Black Square Card)
class BentoNewAudioWidget extends StatelessWidget {
  const BentoNewAudioWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BentoStyle.darkCard,
        borderRadius: BorderRadius.circular(BentoStyle.cardRadius),
        border: Border.all(color: BentoStyle.cardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const <Widget>[
              Text(
                'New Audio',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Icon(Icons.tune_rounded, size: 16, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            '12.4.24',
            style: TextStyle(
              color: BentoStyle.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Soundwave waveform with red playhead
          Row(
            children: <Widget>[
              Container(width: 3, height: 10, color: Colors.white38),
              const SizedBox(width: 3),
              Container(width: 3, height: 16, color: Colors.white54),
              const SizedBox(width: 3),
              Container(width: 3, height: 8, color: Colors.white38),
              const SizedBox(width: 3),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: BentoStyle.safetyOrange,
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Container(
                  height: 2,
                  color: Colors.white24,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                '01:12:30',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: BentoStyle.safetyOrange,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.pause_rounded, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 12. Navigation / ETA Route Widget (Black Card)
class BentoRouteWidget extends StatelessWidget {
  const BentoRouteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 170,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: BentoStyle.darkCard,
        borderRadius: BorderRadius.circular(BentoStyle.cardRadius),
        border: Border.all(color: BentoStyle.cardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                '300 m',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white30, width: 2),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '64',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'km',
                      style: TextStyle(
                        color: BentoStyle.textMuted,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const <Widget>[
              _DarkMetricColumn(label: 'ETA', value: '08:21'),
              _DarkMetricColumn(label: 'Time left', value: '187km/h'),
              _DarkMetricColumn(label: 'Distance left', value: '134kcal'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DarkMetricColumn extends StatelessWidget {
  const _DarkMetricColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            color: BentoStyle.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

/// 13. Dual Timezone Status Widget (Abuja, Nigeria WAT +9 Feb 23)
class BentoDualTimeWidget extends StatelessWidget {
  const BentoDualTimeWidget({super.key, this.isDark = false});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? BentoStyle.darkCard : BentoStyle.lightCard;
    final border = isDark ? BentoStyle.cardBorder : BentoStyle.lightCardBorder;
    final text = isDark ? Colors.white : BentoStyle.textDark;

    return Container(
      width: 170,
      height: 170,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(BentoStyle.cardRadius),
        border: Border.all(color: border),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: isDark ? const Color(0x30000000) : const Color(0x0C000000),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Abuja, Nigeria',
            style: TextStyle(
              color: text,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'WAT • 9 Feb 23',
            style: TextStyle(
              color: BentoStyle.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          // Red-Orange timeline scrubber line with marker nodes
          Row(
            children: <Widget>[
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: BentoStyle.safetyOrange,
                ),
              ),
              Expanded(
                child: Container(
                  height: 2,
                  color: BentoStyle.safetyOrange,
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: BentoStyle.safetyOrange,
                ),
              ),
              Expanded(
                child: Container(
                  height: 2,
                  color: isDark ? Colors.white24 : const Color(0xFFE2E8F0),
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.white38 : const Color(0xFFCBD5E1),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'PM',
                    style: TextStyle(
                      color: BentoStyle.textMuted,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '10:25',
                    style: TextStyle(
                      color: text,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Container(
                width: 32,
                height: 18,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: BentoStyle.safetyOrange,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 14. Uber Ride Status Widget (White Square Card)
class BentoUberWidget extends StatelessWidget {
  const BentoUberWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BentoStyle.lightCard,
        borderRadius: BorderRadius.circular(BentoStyle.cardRadius),
        border: Border.all(color: BentoStyle.lightCardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Uber',
                style: TextStyle(
                  color: BentoStyle.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '2 mins',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          const Center(
            child: Icon(
              Icons.directions_car_filled_rounded,
              size: 42,
              color: BentoStyle.textDark,
            ),
          ),
          const Spacer(),
          const Text(
            'Meet me at',
            style: TextStyle(
              color: BentoStyle.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Text(
            'gbagada',
            style: TextStyle(
              color: BentoStyle.textDark,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Text(
            'mazda380 AZS9980',
            style: TextStyle(
              color: BentoStyle.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 15. EV Charging Status Widget (Black Square Card)
class BentoChargingWidget extends StatelessWidget {
  const BentoChargingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BentoStyle.darkCard,
        borderRadius: BorderRadius.circular(BentoStyle.cardRadius),
        border: Border.all(color: BentoStyle.cardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: const <Widget>[
              Icon(Icons.bolt_rounded, color: BentoStyle.neonLime, size: 16),
              SizedBox(width: 4),
              Text(
                'Charging...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            '68% . 37mins left',
            style: TextStyle(
              color: BentoStyle.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const <Widget>[
              Text('0', style: TextStyle(color: BentoStyle.textMuted, fontSize: 8, fontWeight: FontWeight.bold)),
              Text('50', style: TextStyle(color: BentoStyle.textMuted, fontSize: 8, fontWeight: FontWeight.bold)),
              Text('100', style: TextStyle(color: BentoStyle.textMuted, fontSize: 8, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          // Horizontal battery meter
          Container(
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  decoration: BoxDecoration(
                    color: BentoStyle.neonLime,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Text(
                      'I',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
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

/// 16. Electric Scooter Stats Widget (Wide White Card)
class BentoScooterWidget extends StatelessWidget {
  const BentoScooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 170,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: BentoStyle.lightCard,
        borderRadius: BorderRadius.circular(BentoStyle.cardRadius),
        border: Border.all(color: BentoStyle.lightCardBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Text(
                    'Electric Scooter',
                    style: TextStyle(
                      color: BentoStyle.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '12 Aug 2024',
                    style: TextStyle(
                      color: BentoStyle.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: BentoStyle.safetyOrange,
                  shape: BoxShape.circle,
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'km',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const <Widget>[
              _MetricColumn(label: 'Duration', value: '08:21'),
              _MetricColumn(label: 'Avg.speed', value: '187km/h'),
              _MetricColumn(label: 'Calories', value: '134kcal'),
            ],
          ),
        ],
      ),
    );
  }
}

/// 17. Complete Bento OS Showcase Section combining all widgets with animations on scroll
class BentoOSWidgetSection extends StatelessWidget {
  const BentoOSWidgetSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Section Header with ScrollAwareReveal
            ScrollAwareReveal(
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.dashboard_customize_rounded, size: 13, color: BentoStyle.neonLime),
                        SizedBox(width: 7),
                        Text(
                          'SYSTEM TELEMETRY // BENTO OS',
                          style: TextStyle(
                            color: BentoStyle.neonLime,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ScrollAwareReveal(
              delay: const Duration(milliseconds: 60),
              child: const Text(
                'Continuous Live System Controls.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.6,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ScrollAwareReveal(
              delay: const Duration(milliseconds: 120),
              child: const Text(
                'High-contrast bento widgets in polar white and obsidian black with strict 38px–45px squircle curves.',
                style: TextStyle(
                  color: BentoStyle.textMuted,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Bento Grid of interactive widgets with staggered scroll reveals
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: <Widget>[
                // Row 1 elements
                ScrollAwareReveal(
                  delay: const Duration(milliseconds: 60),
                  child: const BentoWifiWidget(),
                ),
                ScrollAwareReveal(
                  delay: const Duration(milliseconds: 100),
                  child: const BentoFlightWidget(),
                ),
                ScrollAwareReveal(
                  delay: const Duration(milliseconds: 140),
                  child: const BentoSpeedGaugeWidget(),
                ),
                ScrollAwareReveal(
                  delay: const Duration(milliseconds: 180),
                  child: const BentoHabitsWidget(),
                ),
                ScrollAwareReveal(
                  delay: const Duration(milliseconds: 220),
                  child: const BentoGateWidget(),
                ),

                // Row 2 elements
                ScrollAwareReveal(
                  delay: const Duration(milliseconds: 260),
                  child: const BentoNewAudioWidget(),
                ),
                ScrollAwareReveal(
                  delay: const Duration(milliseconds: 300),
                  child: const BentoRouteWidget(),
                ),
                ScrollAwareReveal(
                  delay: const Duration(milliseconds: 340),
                  child: const BentoPowerWidget(),
                ),
                ScrollAwareReveal(
                  delay: const Duration(milliseconds: 380),
                  child: const BentoAudioPlayerWidget(),
                ),

                // Row 3 elements
                ScrollAwareReveal(
                  delay: const Duration(milliseconds: 420),
                  child: const BentoLiveClockWidget(),
                ),
                ScrollAwareReveal(
                  delay: const Duration(milliseconds: 460),
                  child: const BentoCameraWidget(),
                ),
                ScrollAwareReveal(
                  delay: const Duration(milliseconds: 500),
                  child: const BentoActivitiesCalendarWidget(),
                ),
                ScrollAwareReveal(
                  delay: const Duration(milliseconds: 540),
                  child: const BentoDualTimeWidget(isDark: false),
                ),
                ScrollAwareReveal(
                  delay: const Duration(milliseconds: 580),
                  child: const BentoDualTimeWidget(isDark: true),
                ),

                // Row 4 elements
                ScrollAwareReveal(
                  delay: const Duration(milliseconds: 620),
                  child: const BentoUberWidget(),
                ),
                ScrollAwareReveal(
                  delay: const Duration(milliseconds: 660),
                  child: const BentoChargingWidget(),
                ),
                ScrollAwareReveal(
                  delay: const Duration(milliseconds: 700),
                  child: const BentoScooterWidget(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
