import 'package:flutter/material.dart';
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
                  .granted); //If permission is granted, variable is true
        });
      }
    });
  }

  //Widget Compass

  Widget _buildCompass() {
    return Center(
      child: Container(child: Image.asset('assets/images/compass.png')),
    );
  }

  @override
  Widget build(BuildContext context) {
    //Build visual interface
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Builder(
          builder: (context) {
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
