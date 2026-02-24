import 'dart:math' as math;
import 'dart:ui';
//Used to convert degrees to radians (because Transform.rotate uses radians)

import 'package:compass_mobile_pds/screens/InitialSplash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart'; //Plugin that gives access to the device compass sensor
import 'package:permission_handler/permission_handler.dart'; //This Package allow consult and ask for permisson in the phone

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  bool _hasPermissions = false; //begin in false

  Widget _buildCompassRing() {
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
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueAccent, width: 3),
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
            child: _buildPoint("S", Colors.green, pointSize),
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

  Widget _buildPointsNSEO(String text, Alignment alignment, Color color) {
    return Align(
      alignment: alignment,

      child: Transform.translate(
        offset: const Offset(0, 0),

        child: Container(
          width: 50,
          height: 50,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 15),
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
    // TODO: implement initState
    super.initState();
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((value) {
      //Check the current status of the location permit.
      if (mounted) {
        //if widget still active in the screen
        setState(() {
          //something changed
          _hasPermissions =
              (value ==
              PermissionStatus
                  .granted); //If permission is granted, variable is true //otherwise, variable is false
        });
      }
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
                    child: _buildCompassRing(),
                  ),
                  _buildCenterGlobe(),
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
      backgroundColor: const Color.fromARGB(255, 249, 247, 247),
      body: Stack(
        children: [
          _hasPermissions ? _buildCompass() : _buildPermission(),

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
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
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

  Widget _buildPermission() {
    return Center(
      child: ElevatedButton(
        child: Text('Request Permission'),
        onPressed: () {
          Permission.locationWhenInUse.request().then((value) {
            _fetchPermissionStatus();
          });
        },
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
}
