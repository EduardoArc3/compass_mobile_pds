import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
//Used to convert degrees to radians (because Transform.rotate uses radians)

import 'package:compass_mobile_pds/screens/InitialSplash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart'; //Plugin that gives access to the device compass sensor
//import 'package:permission_handler/permission_handler.dart'; //This Package allow consult and ask for permisson in the phone
import 'package:geolocator/geolocator.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  bool _hasPermissions = false; //begin in false
  String _latitudeText = "--";
  String _longitudeText = "__";
  String _altitudeText = "__";
  StreamSubscription<Position>? _positionReal;

  void _LocationUpdates() {
    _positionReal =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 1,
          ),
        ).listen((Position position) {
          if (mounted) {
            setState(() {
              _latitudeText = position.latitude.toStringAsFixed(5);
              _longitudeText = position.longitude.toStringAsFixed(5);
              _altitudeText = "${position.altitude.toStringAsFixed(2)} m";
            });
          }
        });
  }

  Widget _buildCompassRing(Color ringColor) {
    double size = 280;
    double pointSize = 50;
    double radius = size / 2;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Anillo
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ringColor, width: 3),
            ),
          ),

          // N
          Positioned(
            top: -pointSize / 2,
            left: radius - pointSize / 2,
            child: _buildPoint("N", Colors.blue, pointSize),
          ),

          // S
          Positioned(
            bottom: -pointSize / 2,
            left: radius - pointSize / 2,
            child: _buildPoint(
              "S",
              const Color.fromARGB(255, 89, 225, 170),
              pointSize,
            ),
          ),

          // E
          Positioned(
            right: -pointSize / 2,
            top: radius - pointSize / 2,
            child: _buildPoint("E", Colors.yellow, pointSize),
          ),

          // O
          Positioned(
            left: -pointSize / 2,
            top: radius - pointSize / 2,
            child: _buildPoint("O", Colors.orange, pointSize),
          ),
        ],
      ),
    );
  }

  Widget _buildPoint(String text, Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 12),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildCenterGlobe() {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        color: Colors.orange,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.5),
            blurRadius: 25,
          ),
        ],
      ),

      child: const Icon(Icons.navigation, color: Colors.white, size: 32),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermission();
    });
  }

  //Widget Compass

  Widget _buildCompass() {
    //StreamBuilder listens to real-time compass sensor changes
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error al obtener la orientación: ${snapshot.error}');
        }

        //loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        //Get heading in degrees (0 - 360)
        double? direction = snapshot.data!.heading;

        //if direction is null, then devices does not support this sensor
        if (direction == null) {
          return const Center(child: Text('El dispositivo no tiene sensor'));
        }
        final rData = _getRegionAndData(direction);
        final rText = rData["text"];
        final rColor = rData["color"];
        Color ringColor = _getRingColor(direction);

        return Stack(
          fit: StackFit.expand,
          children: [
            _buildAnimatedBackground(direction),

            Container(color: Colors.black.withValues(alpha: 0.4)),

            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  //Rotates the compass image based on direction
                  //Convert degrees to radians
                  //Multiply by -1 to rotate in correct directio
                  Transform.rotate(
                    angle: direction * (math.pi / 180) * -1,
                    child: _buildCompassRing(ringColor),
                  ),
                  _buildCenterGlobe(),
                ],
              ),
            ),

            //TOP RIGHT BADGE
            Positioned(
              top: 60,
              right: 20,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Container(
                  key: ValueKey(rText),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: rColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: rColor.withOpacity(0.4), blurRadius: 15),
                    ],
                  ),
                  child: Text(
                    rText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGlassCard(title: "Latitud", value: _latitudeText),
                  _buildGlassCard(title: "Longitud", value: _longitudeText),
                  _buildGlassCard(title: "Altitud", value: _altitudeText),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _hasPermissions
              ? _buildCompass()
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _requestPermission,
                        child: const Text("Reintentar"),
                      ),
                    ],
                  ),
                ),
          Positioned(
            top: 50,
            left: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Initialsplash(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Permission
  Future<void> _requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _hasPermissions = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _hasPermissions = true;
      });
    }
    _LocationUpdates();
  }

  Widget _buildGlassCard({required String title, required String value}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: 110,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.location_pin, color: Colors.white),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Text(
                  value,
                  key: ValueKey(value),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(double direction) {
    direction = (direction + 360) % 360;
    String imagePath = _getImageForDirection(direction);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1000),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Image.asset(
        imagePath,
        key: ValueKey<String>(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  String _getImageForDirection(double degrees) {
    if (degrees >= 315 || degrees < 45) {
      return "assets/images/north.png";
    } else if (degrees >= 45 && degrees < 135) {
      return "assets/images/east.png";
    } else if (degrees >= 135 && degrees < 225) {
      return "assets/images/south.jpg";
    } else {
      return "assets/images/west.png";
    }
  }

  Color _getRingColor(double degrees) {
    degrees = (degrees + 360) % 360;

    if (degrees >= 315 || degrees < 45) {
      return Colors.blue;
    } else if (degrees >= 45 && degrees < 135) {
      return Colors.yellow;
    } else if (degrees >= 135 && degrees < 225) {
      return const Color.fromARGB(255, 89, 225, 170);
    } else {
      return Colors.orange;
    }
  }

  Map<String, dynamic> _getRegionAndData(double degrees) {
    degrees = (degrees + 360) % 360;

    if (degrees >= 315 || degrees < 45) {
      return {"text": "Norte - Aurora Boreal", "color": Colors.blue};
    } else if (degrees >= 45 && degrees < 135) {
      return {"text": "Este - Playa", "color": Colors.yellow};
    } else if (degrees >= 135 && degrees < 225) {
      return {
        "text": "Sur - Selva",
        "color": const Color.fromARGB(255, 89, 225, 170),
      };
    } else {
      return {"text": "Oeste - Viejo Oeste", "color": Colors.orange};
    }
  }

  @override
  void dispose() {
    _positionReal?.cancel();
    super.dispose();
  }
}
