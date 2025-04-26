import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../colors.dart';
import '../widgets.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  const WelcomeScreen({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final isWideScreen = screenWidth > 600;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isWideScreen ? screenWidth * 0.2 : screenWidth * 0.1,
          vertical: screenHeight * 0.1,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Rental Management',
                    style: TextStyle(
                      fontSize: isWideScreen ? 48 : 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Manage your properties and tenants with ease.',
                    style: TextStyle(
                      fontSize: isWideScreen ? 20 : 16,
                      color: AppColors.darkTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            CustomButton(
              text: 'Sign Up',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
              buttonColor: AppColors.secondaryColor,
              textColor: AppColors.lightTextColor,
            ),
            SizedBox(height: screenHeight * 0.02),
            CustomButton(
              text: 'Login',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              buttonColor: AppColors.primaryColor,
              textColor: AppColors.lightTextColor,
            ),
            SizedBox(height: screenHeight * 0.02),
            Center(
              child: IconButton(
                icon: const Icon(Icons.brightness_6),
                onPressed: toggleTheme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
