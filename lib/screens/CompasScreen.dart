import 'dart:math' as math;
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

        return Center(
          child: Container(
            padding: const EdgeInsets.all(25),
            //Rotates the compass image based on direction
            //Convert degrees to radians
            //Multiply by -1 to rotate in correct directio
            child: Transform.rotate(
              angle: direction * (math.pi / 180) * -1,

              child: Image.asset(
                'assets/images/compass.png',
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //Build visual interface
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Initialsplash()),
              );
            },
          ),
        ),
        body: Builder(
          builder: (context) {
            //If permission granted, show compass
            if (_hasPermissions) {
              //if is true
              return _buildCompass(); //return
            } else {
              return _buildPermission();
            }
          },
        ),
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
}
