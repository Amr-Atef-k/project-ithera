import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'database_helper.dart';
import 'class/users.dart';
import 'class/report.dart';
import 'services/user_prefs.dart';
import 'old_reports.dart';
import 'home.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? currentUser;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final userId = await UserPrefs.getUserId();
    if (userId != null) {
      final dbHelper = DatabaseHelper();
      final user = await dbHelper.getUserById(userId);
      setState(() {
        currentUser = user;
      });
    }
  }

  Future<List<Report>> _fetchReports() async {
    final userId = await UserPrefs.getUserId();
    if (userId == null) {
      throw Exception('User not logged in');
    }
    final dbHelper = DatabaseHelper();
    return await dbHelper.getReportsForUser(userId);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<String?> _saveImage(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = path.join(directory.path, fileName);
    await File(image.path).copy(filePath);
    return filePath;
  }

  void _showEditDialog() {
    if (currentUser == null) return;
    _firstNameController.text = currentUser!.firstName;
    _lastNameController.text = currentUser!.lastName;
    _selectedImage = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF9E8E8),
          title: Text(
            'Edit Profile',
            style: GoogleFonts.lora(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      labelStyle: GoogleFonts.roboto(
                        color: const Color(0xFF333333).withValues(alpha: 0.6),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      labelStyle: GoogleFonts.roboto(
                        color: const Color(0xFF333333).withValues(alpha: 0.6),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA3C6C4),
                      foregroundColor: const Color(0xFF333333),
                    ),
                    onPressed: _pickImage,
                    child: Text(
                      _selectedImage == null ? 'Upload Photo' : 'Change Photo',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Selected: ${_selectedImage!.name}',
                        style: GoogleFonts.roboto(
                          color: const Color(0xFF333333),
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.roboto(
                  color: const Color(0xFF333333),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA3C6C4),
                foregroundColor: const Color(0xFF333333),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    String? photoPath = currentUser!.photoPath;
                    if (_selectedImage != null) {
                      photoPath = await _saveImage(_selectedImage!);
                    }
                    final updatedUser = User(
                      id: currentUser!.id,
                      firstName: _firstNameController.text,
                      lastName: _lastNameController.text,
                      email: currentUser!.email,
                      password: currentUser!.password,
                      photoPath: photoPath,
                    );
                    final dbHelper = DatabaseHelper();
                    await dbHelper.updateUser(updatedUser);
                    setState(() {
                      currentUser = updatedUser;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error updating profile: $e')),
                    );
                  }
                }
              },
              child: Text(
                'Save',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                ),
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFA3C6C4),
        foregroundColor: const Color(0xFF333333),
        title: Text(
          "Profile",
          style: GoogleFonts.lora(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: const Color(0xFFF9E8E8).withOpacity(0.8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5D5D5).withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: currentUser?.photoPath != null &&
                      File(currentUser!.photoPath!).existsSync()
                      ? ClipOval(
                    child: Image.file(
                      File(currentUser!.photoPath!),
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    ),
                  )
                      : const Icon(
                    Icons.person_outline,
                    size: 50,
                    color: Color(0xFF333333),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      currentUser != null
                          ? "${currentUser!.firstName} ${currentUser!.lastName}"
                          : "User",
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                _buildButton("Edit", _showEditDialog),
                SizedBox(height: 15),
                _buildButton("Old Reports", () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final reports = await _fetchReports();
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OLDReportScreen(reports: reports),
                      ),
                    );
                  } catch (e) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Error loading reports: $e')),
                    );
                  }
                }),
                SizedBox(height: 15),
                _buildButton("Report a problem", () {
                  final Uri mailtoUri = Uri(
                    scheme: 'mailto',
                    path: 'support@ithera.com',
                    queryParameters: {
                      'subject': 'I got this problem with the app iThera',
                    },
                  );
                  HomeScreen.launchURL(context, mailtoUri);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 240,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA3C6C4),
          foregroundColor: const Color(0xFF333333),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: GoogleFonts.roboto(
            fontSize: 18,
            color: const Color(0xFF333333),
          ),
        ),
      ),
    );
  }
}