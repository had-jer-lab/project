import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  final String email;

  EditProfileScreen({required this.email});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final supabase = Supabase.instance.client;
  bool isLoading = false;
  bool isPasswordVerified = false;
  bool isPasswordFieldEditable = false;
  String? passwordVerificationMessage; // To store verification message
  Color? passwordVerificationColor; // To store verification color

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _oldPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    setState(() => isLoading = true);

    try {
      final response = await supabase
          .from('users')
          .select('username, phone, dob, email')
          .eq('email', widget.email)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _usernameController.text = response['username'] ?? '';
          _phoneController.text = response['phone'] ?? '';
          _dobController.text = response['dob'] ?? '';
          _emailController.text = response['email'] ?? '';
        });
      }
    } catch (error) {
      showError('error Select : ${error.toString()}');
    }

    setState(() => isLoading = false);
  }

  Future<void> verifyOldPassword() async {
    setState(() => isLoading = true);

    try {
      final response = await supabase
          .from('users')
          .select('password')
          .eq('email', widget.email)
          .maybeSingle();

      if (response != null &&
          response['password'] == _oldPasswordController.text.trim()) {
        setState(() {
          isPasswordVerified = true;
          isPasswordFieldEditable = true;
          passwordVerificationMessage = ' mot passe correct';
          passwordVerificationColor = Colors.green;
        });
      } else {
        setState(() {
          isPasswordVerified = false;
          isPasswordFieldEditable = false;
          passwordVerificationMessage = 'mot passé incorrect';
          passwordVerificationColor = Colors.red;
        });
      }
    } catch (error) {
      showError('failed : ${error.toString()}');
    }

    setState(() => isLoading = false);
  }

  Future<void> saveProfile() async {
    setState(() => isLoading = true);

    try {
      await supabase.from('users').update({
        'username': _usernameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'dob': _dobController.text.trim(),
        'email': _emailController.text.trim(),
        if (isPasswordFieldEditable && _passwordController.text.isNotEmpty)
          'password': _passwordController.text.trim(),
      }).eq('email', widget.email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅✅✅!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      showError('❌❌❌❌: ${error.toString()}');
    }

    setState(() => isLoading = false);
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("edit profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.brown[400]))
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30),
                    // Vibrant profile picture with brown and green tones
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                          'https://th.bing.com/th/id/OIP.9BVL-wy_acR02ymiRXskpQHaHa?w=210&h=209&c=7&r=0&o=5&cb=iwc2&dpr=1.3&pid=1.7'),
                    ),
                    SizedBox(height: 20),
                    _buildProfileField(
                        Icons.person, "Username", _usernameController, true),
                    _buildProfileField(
                        Icons.phone, "Phone", _phoneController, true),
                    _buildProfileField(
                        Icons.cake, "Date of Birth", _dobController, true),
                    _buildProfileField(
                        Icons.email, "Email", _emailController, true),
                    _buildProfileField(
                      Icons.lock,
                      "Old Password",
                      _oldPasswordController,
                      true,
                      obscureText: true,
                      onVerify: verifyOldPassword,
                      showCheckIcon: isPasswordVerified,
                      verificationMessage: passwordVerificationMessage,
                      verificationColor: passwordVerificationColor,
                    ),
                    _buildProfileField(
                      Icons.lock,
                      "New Password",
                      _passwordController,
                      isPasswordFieldEditable,
                      obscureText: true,
                      showCheckIcon: isPasswordVerified,
                    ),
                    SizedBox(
                        height: 20), // Reduced height to move Save button up
                    ElevatedButton(
                      onPressed: saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[200], // Light brown color
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        elevation: 5, // Add shadow for vibrancy
                      ),
                      child: Text(
                        "حفظ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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

  Widget _buildProfileField(IconData icon, String label,
      TextEditingController controller, bool isEditable,
      {bool obscureText = false,
      bool showCheckIcon = false,
      VoidCallback? onVerify,
      String? verificationMessage,
      Color? verificationColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.brown[700]), // Brown for vibrancy
              SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.brown[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  obscureText: obscureText,
                  enabled: isEditable,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                ),
              ),
              if (isEditable)
                IconButton(
                  icon: showCheckIcon
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : Icon(
                          verificationMessage == null
                              ? Icons.edit
                              : Icons.cancel,
                          color: verificationMessage == null
                              ? Colors.grey[600]
                              : Colors.red,
                        ),
                  onPressed: onVerify ?? () {},
                ),
            ],
          ),
          Divider(color: Colors.brown[200]),
          if (verificationMessage != null && label == "Old Password")
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                verificationMessage,
                style: TextStyle(
                  color: verificationColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
