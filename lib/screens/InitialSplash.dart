import 'dart:math' as math;
import 'dart:ui';
import 'package:compass_mobile_pds/screens/CompasScreen.dart';
import 'package:flutter/material.dart';

class Initialsplash extends StatelessWidget {
  const Initialsplash({super.key});

  static const Color _bluePrimary = Color(0xFF003DA5);
  static const Color _blueMid = Color(0xFF002A75);
  static const Color _blueDark = Color(0xFF001F5C);
  static const Color _yellowAccent = Color(0xFFF8B700);
  static const Color _yellowLight = Color(0xFFFFD700);
  static const Color _white = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bluePrimary, _blueMid, _blueDark],
          ),
        ),
        child: Stack(
          children: [
            // Elementos decorativos de fondo
            _buildBackgroundDecorations(),
            // Contenido principal
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Icono de brújula decorativo superior
                    _buildCompassIcon(),
                    const SizedBox(height: 24),
                    // Logo UNISON
                    _buildUnisonLogo(),
                    const SizedBox(height: 24),
                    const Text(
                      'Brújula - App',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subtítulo
                    Text(
                      'Universidad de Sonora',
                      style: TextStyle(
                        color: _yellowAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Características
                    _buildFeatureCard(
                      icon: Icons.explore,
                      title: 'Orientación en tiempo real',
                      subtitle: 'Usando una rosa de los vientos',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureCard(
                      icon: Icons.location_on,
                      title: 'Coordenadas',
                      subtitle: 'Latitud, longitud y altitud exactas',
                    ),
                    const SizedBox(height: 32),
                    // Botón para iniciar la brujula
                    _buildStartButton(context),
                    const SizedBox(height: 32),
                    // equipo de desarrollo
                    _buildTeamSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Rosa de los vientos decorativa del fondo
          Center(
            child: Opacity(
              opacity: 0.05,
              child: SizedBox(
                width: 320,
                height: 320,
                child: CustomPaint(
                  painter: _CompassRosePainter(),
                ),
              ),
            ),
          ),
          // puntos del fondo 
          Positioned(top: 80, left: 40, child: _buildFloatingDot(8, _yellowAccent, 0.4)),
          Positioned(top: 160, right: 64, child: _buildFloatingDot(12, Colors.white, 0.3)),
          Positioned(bottom: 200, left: 48, child: _buildFloatingDot(8, _yellowAccent, 0.4)),
          Positioned(bottom: 280, right: 40, child: _buildFloatingDot(8, Colors.white, 0.3)),
        ],
      ),
    );
  }

  Widget _buildFloatingDot(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildCompassIcon() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
          ),
          child: const Icon(Icons.explore, size: 36, color: _yellowAccent),
        ),
      ),
    );
  }

  Widget _buildUnisonLogo() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/Logouson.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _yellowAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: _bluePrimary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CompassScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_yellowAccent, _yellowLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: _yellowAccent.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: _yellowLight.withOpacity(0.5), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Iniciar',
              style: TextStyle(
                color: _white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSection() {
    return Column(
      children: [
        Text(
          'Equipo',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, color: _yellowAccent, size: 16),
            const SizedBox(width: 6),
            const Text(
              'Arce Gaxiola Angel Eduardo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, color: _yellowAccent, size: 16),
            const SizedBox(width: 6),
            const Text(
              'Montaño Lares Jessica',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// lineas del fondo para la rosa
class _CompassRosePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, size.width / 2 - (i * 20), paint);
    }

    for (int i = 0; i < 4; i++) {
      final angle = (i * 45) * (math.pi / 180);
      final radius = size.width / 2;
      final dx = radius * math.cos(angle);
      final dy = radius * math.sin(angle);
      canvas.drawLine(
        center - Offset(dx, dy),
        center + Offset(dx, dy),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
