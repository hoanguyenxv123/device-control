import 'package:flutter/material.dart';

import '../../../common_widget/primary_button.dart';
import '../../../constant/app_colors.dart';
import '../../auth/auth_screen.dart';

class ButtonPart extends StatelessWidget {
  const ButtonPart({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: PrimaryButton(
              title: 'Login',
              onTap: () {
                Navigator.of(context, rootNavigator: true).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => AuthScreen(isLogin: true),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => AuthScreen(isLogin: false),
                  ),
                );
              },
              child: Text(
                'Register',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
