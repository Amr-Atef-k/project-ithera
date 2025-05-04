import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

class SoothingSoundsScreen extends StatefulWidget {
  const SoothingSoundsScreen({super.key});

  @override
  _SoothingSoundsScreenState createState() => _SoothingSoundsScreenState();
}

class _SoothingSoundsScreenState extends State<SoothingSoundsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlaying; // Tracks the currently playing sound

  // List of sounds with their names, asset paths, and background images
  final List<Map<String, String>> _sounds = [
    {
      'name': 'Ocean Waves',
      'path': 'sounds/ocean_waves.mp3',
      'background': 'assets/ocean.jfif',
    },
    {
      'name': 'Forest Ambience',
      'path': 'sounds/forest_ambience.m4a',
      'background': 'assets/forest.jfif',
    },
    {
      'name': 'Rainfall',
      'path': 'sounds/rainfall.m4a',
      'background': 'assets/rain.jpg',
    },
    {
      'name': 'Wind Chimes',
      'path': 'sounds/wind_chimes.m4a',
      'background': 'assets/chimes.jpg',
    },
    {
      'name': 'Bird Songs',
      'path': 'sounds/bird_song.m4a',
      'background': 'assets/bird.jfif',
    },
    {
      'name': 'Fire',
      'path': 'sounds/fire.m4a',
      'background': 'assets/fire.jpg',
    },
  ];

  // Play or stop the sound
  Future<void> _toggleSound(String soundPath, String soundName) async {
    if (_currentlyPlaying == soundName) {
      // Stop the current sound
      await _audioPlayer.stop();
      setState(() {
        _currentlyPlaying = null;
      });
    } else {
      // Stop any currently playing sound
      if (_currentlyPlaying != null) {
        await _audioPlayer.stop();
      }
      // Play the new sound
      await _audioPlayer.play(AssetSource(soundPath));
      setState(() {
        _currentlyPlaying = soundName;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFA3C6C4),
        foregroundColor: const Color(0xFF333333),
        title: Text(
          'Soothing Sounds',
          style: GoogleFonts.lora(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: const Color(0xFFF9E8E8).withOpacity(0.8),
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.75,
          ),
          itemCount: _sounds.length,
          itemBuilder: (context, index) {
            final sound = _sounds[index];
            final isPlaying = _currentlyPlaying == sound['name'];
            return GestureDetector(
              onTap: () => _toggleSound(sound['path']!, sound[' exam name']!),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        sound['background']!,
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.3),
                        colorBlendMode: BlendMode.darken,
                      ),
                    ),
                    // Sound name and play/stop button
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            sound['name']!,
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: Icon(
                              isPlaying ? Icons.stop : Icons.play_arrow,
                              color: Colors.white,
                              size: 40,
                            ),
                            onPressed: () => _toggleSound(sound['path']!, sound['name']!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}