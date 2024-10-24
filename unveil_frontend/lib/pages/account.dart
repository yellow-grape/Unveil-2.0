import 'package:flutter/material.dart';
import 'package:unveil_frontend/services/AuthService.dart';
import 'package:unveil_frontend/services/ProflleService.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  String? username;
  String? email;
  int? lifetimeLikes;

  final ProfileService profileService = ProfileService(); // Create an instance of ProfileService

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Fetch user profile when the widget initializes
  }

  Future<void> _fetchUserProfile() async {
    try {
      final profile = await AuthService().fetchUserInfo(); // Fetch the user info without userId
      setState(() {
        username = profile['username']; // Set username from the profile
        email = profile['email']; // Set email from the profile
        lifetimeLikes = profile['lifetime_likes']; // Set lifetime likes from the profile
      });
    } catch (e) {
      // Handle error (You might want to show a message to the user)
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
            borderRadius: BorderRadius.circular(0),
            border: Border.all(
              color: isDarkMode ? Colors.white : Colors.black,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.black,
                child: Icon(
                  Icons.account_circle,
                  size: 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                username ?? 'Loading...', // Show loading text until the username is fetched
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                email ?? 'Loading...', // Show loading text until the email is fetched
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                lifetimeLikes != null ? '$lifetimeLikes lifetime likes' : 'Loading...', // Show loading text until the likes are fetched
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Handle account settings action
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                child: const Text('Account Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
