import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../common_widget/custom_dialog.dart';
import '../../common_widget/custom_icon.dart';
import '../../common_widget/custom_text_field.dart';
import '../../common_widget/primary_button.dart';
import '../../constant/app_colors.dart';
import '../../data/firebase/auth_service.dart';
import '../dashboard_screen.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.isLogin});

  final bool isLogin;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool isLogin;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    isLogin = widget.isLogin;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    isLogin ? 'Login here' : 'Create an account',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    textAlign: TextAlign.center,
                    isLogin
                        ? "Welcome back you've\nbeen missed!"
                        : "Create an account so you can\nexplore all the exciting jobs",
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: isLogin ? 22 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    title: 'Email',
                    textEditingController: emailController,
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    title: 'Password',
                    passCheck: true,
                    textEditingController: passwordController,
                  ),
                  if (!isLogin) ...[
                    SizedBox(height: 20),
                    CustomTextField(
                      title: 'Confirm Password',
                      passCheck: true,
                      textEditingController: confirmPasswordController,
                    ),
                  ],
                  SizedBox(height: 10),
                  if (isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot your password?',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 30),
                  PrimaryButton(
                    title: isLogin ? 'Sign in' : 'Sign up',
                    onTap: () async {
                      String email = emailController.text.trim();
                      String password = passwordController.text.trim();
                      String confirmPassword =
                          confirmPasswordController.text.trim();

                      try {
                        String? errorMessage = await _validateSignupForm(
                          password: password,
                          confirmPassword: confirmPassword,
                          email: email,
                        );
                        if (errorMessage != null) {
                          _showErrorDialog(context, errorMessage);
                          return;
                        }

                        if (isLogin) {
                          var user = await _authService.signIn(
                            email: email,
                            password: password,
                          );
                          if (user != null) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => DashboardScreen(),
                              ),
                            );
                          }
                        } else {
                          var user = await _authService.createUser(
                            email: email,
                            password: password,
                          );
                          if (user != null) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => DashboardScreen(),
                              ),
                            );
                          }
                        }
                      } on FirebaseAuthException catch (e) {
                        _showErrorDialog(
                          context,
                          e.message ?? 'Lỗi không xác định',
                        );
                      } catch (e) {
                        _showErrorDialog(
                          context,
                          'Đã xảy ra lỗi không xác định',
                        );
                      }
                    },
                  ),
                  SizedBox(height: 30),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                        emailController.clear();
                        passwordController.clear();
                        confirmPasswordController.clear();
                      });
                    },
                    child: Text(
                      isLogin ? "Create an account" : "Already have an account",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Or continue with',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIcon(
                        icon: FaIcon(FontAwesomeIcons.google, size: 20),
                      ),
                      CustomIcon(icon: Icon(Icons.facebook)),
                      CustomIcon(icon: Icon(Icons.apple, size: 26)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(message: message),
    );
  }

  Future<String?> _validateSignupForm({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    email = email.trim();
    password = password.trim();
    confirmPassword = confirmPassword.trim();

    if (email.isEmpty || password.isEmpty) {
      return 'Email or Password fields cannot be empty.';
    }
    if (!EmailValidator.validate(email)) {
      return 'Email address is not formatted correctly!';
    }

    if (!isLogin && confirmPassword.isEmpty) {
      return 'Confirm Password cannot be empty.';
    }

    if (!isLogin && password != confirmPassword) {
      return 'Passwords do not match.';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    return null;
  }
}
