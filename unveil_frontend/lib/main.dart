import 'package:flutter/material.dart';
import 'package:unveil_frontend/pages/UploadArt.dart';
import 'package:unveil_frontend/pages/ViewArtWork.dart';
import 'package:unveil_frontend/pages/account.dart';
import 'package:unveil_frontend/pages/login.dart';
import 'package:unveil_frontend/pages/signup.dart';

void main() {
  // Set isAuthenticated to true or false based on your logic
  bool isAuthenticated = false; // Change to true if the user is authenticated

  runApp(MainView(isAuthenticated: isAuthenticated));
}

class MainView extends StatefulWidget {
  final bool isAuthenticated;

  const MainView({super.key, required this.isAuthenticated});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int currentIndex = 0;

  // Authenticated pages
  final List<Widget> authPages = [
    const ViewArt(),
    const UploadArt(),
    Account(),
  ];

  // Unauthenticated pages
  late final List<Widget> unauthPages = _getUnauthPages();

  // Method to create unauthenticated pages
  List<Widget> _getUnauthPages() {
    return [
      LoginPage(
        onLoginSuccess: () {
          setState(() {
            currentIndex = 0; // Go to the first page of authenticated users
          });
        },
      ),
      const SignUpPage(),
    ];
  }

  void _onPageSelected(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Art Gallery")),
      body: IndexedStack(
        index: currentIndex,
        children: widget.isAuthenticated ? authPages : unauthPages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: widget.isAuthenticated
            ? [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.art_track),
                  label: 'View',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.upload),
                  label: 'Upload',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.account_circle),
                  label: 'Account',
                ),
              ]
            : [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.login),
                  label: 'Login',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_add),
                  label: 'Sign Up',
                ),
              ],
        currentIndex: currentIndex,
        onTap: _onPageSelected,
      ),
    );
  }
}
