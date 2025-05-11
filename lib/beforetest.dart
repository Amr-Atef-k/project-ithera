import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ithera/test.dart';

class BeforeTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA3C6C4),
        foregroundColor: const Color(0xFF333333),
        title: Text(
          "Test agreement",
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
                  Icon(Icons.assignment, size: 80, color: const Color(0xFF333333)),
                  SizedBox(height: 20),
                  _buildBulletPoint("This test will use your camera"),
                  _buildBulletPoint("This test will be 18 questions and will take about 5:7 minutes"),
                  _buildBulletPoint("Questions will be about your feelings and different situations"),
                  _buildBulletPoint("Remember this assessment is a preliminary"),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      final cameras = await availableCameras();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TestPage(cameras: cameras),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3C6C4),
                      foregroundColor: const Color(0xFF333333),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: Text(
                      "Give permission, start the test",
                      style: GoogleFonts.roboto(
                        fontSize: 19,
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
          SizedBox(width: 10),
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