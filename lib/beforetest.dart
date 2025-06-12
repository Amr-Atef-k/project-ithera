import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ithera/test.dart';
import 'package:permission_handler/permission_handler.dart';

class BeforeTest extends StatelessWidget {
  const BeforeTest({super.key});

  // Request camera permission and handle the response
  Future<bool> _requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      return true;
    } else {
      // Show a SnackBar if permission is denied or permanently denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status.isPermanentlyDenied
                ? 'Camera permission is permanently denied. Please enable it in Settings.'
                : 'Camera permission is required to start the test.',
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF333333),
          action: status.isPermanentlyDenied
              ? SnackBarAction(
            label: 'Open Settings',
            textColor: const Color(0xFFA3C6C4),
            onPressed: () {
              openAppSettings(); // Open device settings
            },
          )
              : null,
          duration: const Duration(seconds: 4),
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA3C6C4),
        foregroundColor: const Color(0xFF333333),
        title: Text(
          "Test Agreement",
          style: GoogleFonts.lora(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: const Color(0xFFF9E8E8).withOpacity(0.8),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.assignment, size: 80, color: Color(0xFF333333)),
                  const SizedBox(height: 20),
                  _buildBulletPoint("This test will use your camera"),
                  _buildBulletPoint("This test will be 18 questions and will take about 5-7 minutes"),
                  _buildBulletPoint("Questions will be about your feelings and different situations"),
                  _buildBulletPoint("Remember this assessment is a preliminary"),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      // Request camera permission
                      final hasPermission = await _requestCameraPermission(context);
                      if (hasPermission) {
                        final cameras = await availableCameras();
                        if (cameras.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Test(cameras: cameras),
                            ),
                          );
                        } else {
                          // Show SnackBar if no cameras are available
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'No camera available on this device.',
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: const Color(0xFF333333),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3C6C4),
                      foregroundColor: const Color(0xFF333333),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: Text(
                      "Give Permission, Start the Test",
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "•",
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: const Color(0xFF333333),
              ),
            ),
          ),
        ],
      ),
    );
  }
}