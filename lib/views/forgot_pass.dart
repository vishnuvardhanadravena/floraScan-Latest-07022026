import 'package:aiplantidentifier/providers/auth_provider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String username;
  const ForgotPasswordPage({super.key, required this.username});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return isMobile
        ? ForgotPasswordMobileView(username: widget.username)
        : ForgotPasswordMobileView(username: widget.username);
    //  const ForgotPasswordTabletView();
  }
}

class ForgotPasswordMobileView extends StatefulWidget {
  final String username;
  const ForgotPasswordMobileView({super.key, required this.username});

  @override
  State<ForgotPasswordMobileView> createState() =>
      _ForgotPasswordMobileViewState();
}

class _ForgotPasswordMobileViewState extends State<ForgotPasswordMobileView> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  int currentStep = 2;
  bool isLoading = false;
  String userEmail = '';

  late List<TextEditingController> otpControllers;
  late final ForgotPasswordProvider provider;

  @override
  void initState() {
    super.initState();

    emailController = TextEditingController()..text = widget.username;
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    otpControllers = List.generate(6, (_) => TextEditingController());

    /// Runs AFTER widget is attached to the tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider = context.read<ForgotPasswordProvider>(); // ✅ safe
      provider.currentStep = 2;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleSendEmail() {
    provider.sendOtp(emailController.text.trim());
    // if (emailController.text.isEmpty) {
    //   AppToast.error('Please enter your email address');
    //   return;
    // }

    // setState(() => isLoading = true);

    // Future.delayed(const Duration(seconds: 2), () {
    //   setState(() {
    //     isLoading = false;
    //     provider.currentStep = 1;
    //     userEmail = emailController.text;
    //   });
    // });
  }

  void _handleVerifyOTP() {
    String otp = otpControllers.map((c) => c.text).join();
    provider.verifyOtp(otp);

    // if (otp.length != 6) {
    //   AppToast.error('Please enter all 6 digits');
    //   return;
    // }

    // setState(() => isLoading = true);

    // Future.delayed(const Duration(seconds: 2), () {
    //   setState(() {
    //     isLoading = false;
    //     provider.currentStep = 2;
    //   });
    // });
  }

  void _handleResetPassword() {
    provider.resetPassword(
      passwordController.text,
      confirmPasswordController.text,
    );
    // if (passwordController.text.isEmpty) {
    //   AppToast.error('Please enter a new password');
    //   return;
    // }

    // if (passwordController.text.length < 8) {
    //   AppToast.error('Password must be at least 8 characters');
    //   return;
    // }

    // if (passwordController.text != confirmPasswordController.text) {
    //   AppToast.error('Passwords do not match');
    //   return;
    // }

    // setState(() => isLoading = true);

    // Future.delayed(const Duration(seconds: 2), () {
    //   setState(() {
    //     isLoading = false;
    //     provider.currentStep = 3;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ForgotPasswordProvider>(
        builder: (context, provider, child) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/login_screen_background.png'),
                fit: BoxFit.cover,
              ),
              // border: Border.all(width: 10),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFD4E8D4),
                  const Color(0xFFE8F0E8),
                  Colors.white,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.00,
                    left: 0,
                    right: 0,
                    child: Image.asset(
                      'images/login_bottom_flowers.png',
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                  Column(
                    children: [
                      if (provider.currentStep != 3)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: GestureDetector(
                              onTap: () => provider.goBack(context),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Color(0xFF1B4D1B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 20,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // if (provider.currentStep == 0) ...[
                                  //   const Text(
                                  //     'Forgot Password?',
                                  //     style: TextStyle(
                                  //       fontSize: 32,
                                  //       fontWeight: FontWeight.bold,
                                  //       color: Color(0xFF1B4D1B),
                                  //     ),
                                  //   ),
                                  //   const SizedBox(height: 12),
                                  //   const Text(
                                  //     'No worries! We\'ll send you a password reset link to your email address.',
                                  //     textAlign: TextAlign.center,
                                  //     style: TextStyle(
                                  //       fontSize: 14,
                                  //       color: Colors.black54,
                                  //       height: 1.6,
                                  //     ),
                                  //   ),
                                  //   const SizedBox(height: 40),
                                  //   Container(
                                  //     decoration: BoxDecoration(
                                  //       color: Colors.white.withOpacity(0.85),
                                  //       borderRadius: BorderRadius.circular(20),
                                  //       boxShadow: [
                                  //         BoxShadow(
                                  //           color: Colors.black.withOpacity(
                                  //             0.1,
                                  //           ),
                                  //           blurRadius: 20,
                                  //           offset: const Offset(0, 10),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //     padding: const EdgeInsets.all(24),
                                  //     width: double.infinity,
                                  //     child: Column(
                                  //       crossAxisAlignment:
                                  //           CrossAxisAlignment.start,
                                  //       children: [
                                  //         const Text(
                                  //           'Email Address*',
                                  //           style: TextStyle(
                                  //             fontSize: 14,
                                  //             fontWeight: FontWeight.w600,
                                  //             color: Colors.black87,
                                  //           ),
                                  //         ),
                                  //         const SizedBox(height: 8),
                                  //         TextField(
                                  //           style: TextStyle(
                                  //             color: Colors.black,
                                  //           ),
                                  //           controller: emailController,
                                  //           keyboardType:
                                  //               TextInputType.emailAddress,
                                  //           decoration: InputDecoration(
                                  //             hintText: 'Enter your email',
                                  //             hintStyle: TextStyle(
                                  //               color: Colors.black,
                                  //             ),
                                  //             contentPadding:
                                  //                 const EdgeInsets.symmetric(
                                  //                   horizontal: 16,
                                  //                   vertical: 12,
                                  //                 ),
                                  //             border: OutlineInputBorder(
                                  //               borderRadius:
                                  //                   BorderRadius.circular(12),
                                  //               borderSide: BorderSide(
                                  //                 color: Colors.grey[300]!,
                                  //               ),
                                  //             ),
                                  //             enabledBorder: OutlineInputBorder(
                                  //               borderRadius:
                                  //                   BorderRadius.circular(12),
                                  //               borderSide: BorderSide(
                                  //                 color: Colors.grey[300]!,
                                  //               ),
                                  //             ),
                                  //             focusedBorder: OutlineInputBorder(
                                  //               borderRadius:
                                  //                   BorderRadius.circular(12),
                                  //               borderSide: const BorderSide(
                                  //                 color: Color(0xFF1B4D1B),
                                  //                 width: 2,
                                  //               ),
                                  //             ),
                                  //             errorBorder: OutlineInputBorder(
                                  //               borderRadius:
                                  //                   BorderRadius.circular(12),
                                  //               borderSide: BorderSide(
                                  //                 color: Colors.grey[300]!,
                                  //               ),
                                  //             ),
                                  //             focusedErrorBorder:
                                  //                 OutlineInputBorder(
                                  //                   borderRadius:
                                  //                       BorderRadius.circular(
                                  //                         12,
                                  //                       ),
                                  //                   borderSide:
                                  //                       const BorderSide(
                                  //                         color: Color(
                                  //                           0xFF1B4D1B,
                                  //                         ),
                                  //                         width: 2,
                                  //                       ),
                                  //                 ),
                                  //             suffixIcon: const Padding(
                                  //               padding: EdgeInsets.all(12),
                                  //               child: Icon(
                                  //                 Icons.mail_outline,
                                  //                 color: Color(0xFF1B4D1B),
                                  //               ),
                                  //             ),
                                  //           ),
                                  //         ),
                                  //         const SizedBox(height: 24),
                                  //         SizedBox(
                                  //           width: double.infinity,
                                  //           child: ElevatedButton(
                                  //             onPressed:
                                  //                 provider.isLoading
                                  //                     ? null
                                  //                     : _handleSendEmail,
                                  //             style: ElevatedButton.styleFrom(
                                  //               backgroundColor: const Color(
                                  //                 0xFF1B4D1B,
                                  //               ),
                                  //               disabledBackgroundColor:
                                  //                   const Color(0xFF1B4D1B),
                                  //               disabledForegroundColor:
                                  //                   Colors.white,
                                  //               padding:
                                  //                   const EdgeInsets.symmetric(
                                  //                     vertical: 14,
                                  //                   ),
                                  //               shape: RoundedRectangleBorder(
                                  //                 borderRadius:
                                  //                     BorderRadius.circular(12),
                                  //               ),
                                  //               elevation: 3,
                                  //             ),
                                  //             child:
                                  //                 provider.isLoading
                                  //                     ? const SizedBox(
                                  //                       height: 20,
                                  //                       width: 20,
                                  //                       child: CircularProgressIndicator(
                                  //                         valueColor:
                                  //                             AlwaysStoppedAnimation<
                                  //                               Color
                                  //                             >(Colors.green),
                                  //                         strokeWidth: 2,
                                  //                       ),
                                  //                     )
                                  //                     : const Text(
                                  //                       'Send OTP',
                                  //                       style: TextStyle(
                                  //                         fontSize: 16,
                                  //                         fontWeight:
                                  //                             FontWeight.w600,
                                  //                         color: Colors.white,
                                  //                       ),
                                  //                     ),
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ]
                                  // // Step 1: OTP
                                  // else
                                  //  if (provider.currentStep == 1) ...[
                                  //   const Text(
                                  //     'Verify OTP',
                                  //     style: TextStyle(
                                  //       fontSize: 32,
                                  //       fontWeight: FontWeight.bold,
                                  //       color: Color(0xFF1B4D1B),
                                  //     ),
                                  //   ),
                                  //   const SizedBox(height: 12),
                                  //   Text(
                                  //     'We\'ve sent a 6-digit OTP to\n$userEmail',
                                  //     textAlign: TextAlign.center,
                                  //     style: const TextStyle(
                                  //       fontSize: 14,
                                  //       color: Colors.black54,
                                  //       height: 1.6,
                                  //     ),
                                  //   ),
                                  //   const SizedBox(height: 40),
                                  //   Container(
                                  //     decoration: BoxDecoration(
                                  //       color: Colors.white.withOpacity(0.85),
                                  //       borderRadius: BorderRadius.circular(20),
                                  //       boxShadow: [
                                  //         BoxShadow(
                                  //           color: Colors.black.withOpacity(
                                  //             0.1,
                                  //           ),
                                  //           blurRadius: 20,
                                  //           offset: const Offset(0, 10),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //     padding: const EdgeInsets.all(24),
                                  //     width: double.infinity,
                                  //     child: Column(
                                  //       children: [
                                  //         const Text(
                                  //           'Enter 6-Digit OTP*',
                                  //           style: TextStyle(
                                  //             fontSize: 14,
                                  //             fontWeight: FontWeight.w600,
                                  //             color: Colors.black87,
                                  //           ),
                                  //         ),
                                  //         const SizedBox(height: 20),
                                  //         Row(
                                  //           mainAxisAlignment:
                                  //               MainAxisAlignment.spaceEvenly,
                                  //           children: List.generate(
                                  //             6,
                                  //             (index) => SizedBox(
                                  //               width: 50,
                                  //               height: 50,
                                  //               child: TextField(
                                  //                 style: TextStyle(
                                  //                   color: Colors.black,
                                  //                 ),
                                  //                 controller:
                                  //                     otpControllers[index],
                                  //                 maxLength: 1,
                                  //                 textAlign: TextAlign.center,
                                  //                 keyboardType:
                                  //                     TextInputType.number,
                                  //                 decoration: InputDecoration(
                                  //                   counterText: '',
                                  //                   border: OutlineInputBorder(
                                  //                     borderRadius:
                                  //                         BorderRadius.circular(
                                  //                           12,
                                  //                         ),
                                  //                     borderSide: BorderSide(
                                  //                       color:
                                  //                           Colors.grey[300]!,
                                  //                     ),
                                  //                   ),
                                  //                   enabledBorder:
                                  //                       OutlineInputBorder(
                                  //                         borderRadius:
                                  //                             BorderRadius.circular(
                                  //                               12,
                                  //                             ),
                                  //                         borderSide: BorderSide(
                                  //                           color:
                                  //                               Colors
                                  //                                   .grey[300]!,
                                  //                         ),
                                  //                       ),
                                  //                   focusedBorder:
                                  //                       OutlineInputBorder(
                                  //                         borderRadius:
                                  //                             BorderRadius.circular(
                                  //                               12,
                                  //                             ),
                                  //                         borderSide:
                                  //                             const BorderSide(
                                  //                               color: Color(
                                  //                                 0xFF1B4D1B,
                                  //                               ),
                                  //                               width: 2,
                                  //                             ),
                                  //                       ),
                                  //                 ),
                                  //                 onChanged: (value) {
                                  //                   if (value.isNotEmpty &&
                                  //                       index < 5) {
                                  //                     FocusScope.of(
                                  //                       context,
                                  //                     ).nextFocus();
                                  //                   }
                                  //                 },
                                  //               ),
                                  //             ),
                                  //           ),
                                  //         ),
                                  //         const SizedBox(height: 24),
                                  //         SizedBox(
                                  //           width: double.infinity,
                                  //           child: ElevatedButton(
                                  //             onPressed:
                                  //                 provider.isLoading
                                  //                     ? null
                                  //                     : _handleVerifyOTP,
                                  //             style: ElevatedButton.styleFrom(
                                  //               backgroundColor: const Color(
                                  //                 0xFF1B4D1B,
                                  //               ),
                                  //               disabledBackgroundColor:
                                  //                   const Color(0xFF1B4D1B),
                                  //               disabledForegroundColor:
                                  //                   Colors.white,
                                  //               padding:
                                  //                   const EdgeInsets.symmetric(
                                  //                     vertical: 14,
                                  //                   ),
                                  //               shape: RoundedRectangleBorder(
                                  //                 borderRadius:
                                  //                     BorderRadius.circular(12),
                                  //               ),
                                  //               elevation: 3,
                                  //             ),
                                  //             child:
                                  //                 provider.isLoading
                                  //                     ? const SizedBox(
                                  //                       height: 20,
                                  //                       width: 20,
                                  //                       child: CircularProgressIndicator(
                                  //                         valueColor:
                                  //                             AlwaysStoppedAnimation<
                                  //                               Color
                                  //                             >(Colors.white),
                                  //                         strokeWidth: 2,
                                  //                       ),
                                  //                     )
                                  //                     : const Text(
                                  //                       'Verify OTP',
                                  //                       style: TextStyle(
                                  //                         fontSize: 16,
                                  //                         fontWeight:
                                  //                             FontWeight.w600,
                                  //                         color: Colors.white,
                                  //                       ),
                                  //                     ),
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ]
                                  // // Step 2: Password
                                  // else
                                  if (provider.currentStep == 2) ...[
                                    const Text(
                                      'Set New Password',
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B4D1B),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Create a new password for your account',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                        height: 1.6,
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.85),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(24),
                                      width: double.infinity,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'New Password*',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextField(
                                            controller: passwordController,
                                            obscureText: true,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Enter new password',
                                              hintStyle: TextStyle(
                                                color: Colors.black.withOpacity(
                                                  0.5,
                                                ),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFF1B4D1B),
                                                  width: 2,
                                                ),
                                              ),
                                              suffixIcon: const Padding(
                                                padding: EdgeInsets.all(12),
                                                child: Icon(
                                                  Icons.lock_outline,
                                                  color: Color(0xFF1B4D1B),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Confirm Password*',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          TextField(
                                            controller:
                                                confirmPasswordController,
                                            obscureText: true,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: 'Confirm password',
                                              hintStyle: TextStyle(
                                                color: Colors.black.withOpacity(
                                                  0.5,
                                                ),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFF1B4D1B),
                                                  width: 2,
                                                ),
                                              ),
                                              suffixIcon: const Padding(
                                                padding: EdgeInsets.all(12),
                                                child: Icon(
                                                  Icons.lock_outline,
                                                  color: Color(0xFF1B4D1B),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed:
                                                  provider.isLoading
                                                      ? null
                                                      : _handleResetPassword,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF1B4D1B,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 14,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                elevation: 3,
                                              ),
                                              child:
                                                  provider.isLoading
                                                      ? const SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child: CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                Color
                                                              >(Colors.white),
                                                          strokeWidth: 2,
                                                        ),
                                                      )
                                                      : const Text(
                                                        'Reset Password',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  // Step 3: Success
                                  // else if (provider.currentStep == 3) ...[
                                  //   Container(
                                  //     decoration: BoxDecoration(
                                  //       color: const Color(
                                  //         0xFF1B4D1B,
                                  //       ).withOpacity(0.1),
                                  //       shape: BoxShape.circle,
                                  //     ),
                                  //     padding: const EdgeInsets.all(32),
                                  //     child: const Icon(
                                  //       Icons.check_circle_outline,
                                  //       size: 80,
                                  //       color: Color(0xFF1B4D1B),
                                  //     ),
                                  //   ),
                                  //   const SizedBox(height: 32),
                                  //   const Center(
                                  //     child: Text(
                                  //       'Password Reset Successfully!',
                                  //       style: TextStyle(
                                  //         fontSize: 24,
                                  //         fontWeight: FontWeight.bold,
                                  //         color: Color(0xFF1B4D1B),
                                  //       ),
                                  //     ),
                                  //   ),
                                  //   const SizedBox(height: 16),
                                  //   const Center(
                                  //     child: Text(
                                  //       'Your password has been successfully updated. You can now login with your new password.',
                                  //       textAlign: TextAlign.center,
                                  //       style: TextStyle(
                                  //         fontSize: 14,
                                  //         color: Colors.black54,
                                  //         height: 1.6,
                                  //       ),
                                  //     ),
                                  //   ),
                                  //   const SizedBox(height: 40),
                                  //   SizedBox(
                                  //     width: double.infinity,
                                  //     child: ElevatedButton(
                                  //       onPressed: () => Navigator.pop(context),
                                  //       style: ElevatedButton.styleFrom(
                                  //         backgroundColor: const Color(
                                  //           0xFF1B4D1B,
                                  //         ),
                                  //         padding: const EdgeInsets.symmetric(
                                  //           vertical: 14,
                                  //         ),
                                  //         shape: RoundedRectangleBorder(
                                  //           borderRadius: BorderRadius.circular(
                                  //             12,
                                  //           ),
                                  //         ),
                                  //         elevation: 3,
                                  //       ),
                                  //       child: const Text(
                                  //         'Back to Login',
                                  //         style: TextStyle(
                                  //           fontSize: 16,
                                  //           fontWeight: FontWeight.w600,
                                  //           color: Colors.white,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ],
                                ],
                              ),
                            ),
                          ),
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
    );
  }
}

class ForgotPasswordTabletView extends StatefulWidget {
  const ForgotPasswordTabletView({super.key});

  @override
  State<ForgotPasswordTabletView> createState() =>
      _ForgotPasswordTabletViewState();
}

class _ForgotPasswordTabletViewState extends State<ForgotPasswordTabletView> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late final ForgotPasswordProvider provider;
  int currentStep = 0;
  bool isLoading = false;
  String userEmail = '';

  late List<TextEditingController> otpControllers;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<ForgotPasswordProvider>(context, listen: false);
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    otpControllers = List.generate(6, (_) => TextEditingController());
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleSendEmail() {
    provider.sendOtp(emailController.text);
    // if (emailController.text.isEmpty) {
    //   _showSnackBar('Please enter your email address');
    //   return;
    // }

    // setState(() => isLoading = true);

    // Future.delayed(const Duration(seconds: 2), () {
    //   setState(() {
    //     isLoading = false;
    //     provider.currentStep = 1;
    //     userEmail = emailController.text;
    //   });
    // });
  }

  void _handleVerifyOTP() {
    String otp = otpControllers.map((c) => c.text).join();
    provider.verifyOtp(otp);

    // if (otp.length != 6) {
    //   _showSnackBar('Please enter all 6 digits');
    //   return;
    // }

    // setState(() => isLoading = true);

    // Future.delayed(const Duration(seconds: 2), () {
    //   setState(() {
    //     isLoading = false;
    //     provider.currentStep = 2;
    //   });
    // });
  }

  void _handleResetPassword() {
    provider.resetPassword(
      passwordController.text,
      confirmPasswordController.text,
    );
    // if (passwordController.text.isEmpty) {
    //   _showSnackBar('Please enter a new password');
    //   return;
    // }

    // if (passwordController.text.length < 8) {
    //   _showSnackBar('Password must be at least 8 characters');
    //   return;
    // }

    // if (passwordController.text != confirmPasswordController.text) {
    //   _showSnackBar('Passwords do not match');
    //   return;
    // }

    // setState(() => isLoading = true);

    // Future.delayed(const Duration(seconds: 2), () {
    //   setState(() {
    //     isLoading = false;
    //     provider.currentStep = 3;
    //   });
    // });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1B4D1B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ForgotPasswordProvider>(
        builder: (context, provider, child) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/login_screen_background_tab.png'),
                fit: BoxFit.cover,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFD4E8D4),
                  const Color(0xFFE8F0E8),
                  Colors.white,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Image.asset(
                      'images/login_bottom_flowers.png',
                      fit: BoxFit.cover,
                      // height: MediaQuery.of(context).size.height / 2,
                      width: double.infinity,
                    ),
                  ),
                  Column(
                    children: [
                      if (provider.currentStep != 3)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: GestureDetector(
                              onTap: () => provider.goBack(context),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(10),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Color(0xFF1B4D1B),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Middle Content - Centered
                      Expanded(
                        child: SingleChildScrollView(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 60,
                                vertical: 20,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Step 0: Email
                                  if (provider.currentStep == 0) ...[
                                    const Text(
                                      'Forgot Your Password?',
                                      style: TextStyle(
                                        fontSize: 44,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B4D1B),
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Don\'t worry, it happens to the best of us. We\'ll send you a link to reset your password.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                        height: 1.8,
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: 500,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.85),
                                        borderRadius: BorderRadius.circular(25),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 30,
                                            offset: const Offset(0, 15),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(40),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Email Address*',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: emailController,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            decoration: InputDecoration(
                                              hintText: 'Enter your email',
                                              hintStyle: TextStyle(
                                                color: Colors.black.withOpacity(
                                                  0.5,
                                                ),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 18,
                                                    vertical: 14,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFF1B4D1B),
                                                  width: 2,
                                                ),
                                              ),
                                              suffixIcon: const Padding(
                                                padding: EdgeInsets.all(14),
                                                child: Icon(
                                                  Icons.mail_outline,
                                                  color: Color(0xFF1B4D1B),
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 32),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed:
                                                  provider.isLoading
                                                      ? null
                                                      : _handleSendEmail,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF1B4D1B,
                                                ),
                                                disabledBackgroundColor:
                                                    const Color(0xFF1B4D1B),
                                                disabledForegroundColor:
                                                    Colors.white,

                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                                elevation: 3,
                                              ),
                                              child:
                                                  provider.isLoading
                                                      ? const SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child: CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                Color
                                                              >(Colors.white),
                                                          strokeWidth: 2,
                                                        ),
                                                      )
                                                      : const Text(
                                                        'Send OTP',
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]
                                  // Step 1: OTP
                                  else if (provider.currentStep == 1) ...[
                                    const Text(
                                      'Verify OTP',
                                      style: TextStyle(
                                        fontSize: 44,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B4D1B),
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'We\'ve sent a 6-digit OTP to\n$userEmail',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                        height: 1.8,
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: 500,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.85),
                                        borderRadius: BorderRadius.circular(25),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 30,
                                            offset: const Offset(0, 15),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(40),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'Enter 6-Digit OTP*',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: List.generate(
                                              6,
                                              (index) => SizedBox(
                                                width: 60,
                                                height: 60,
                                                child: TextField(
                                                  controller:
                                                      otpControllers[index],
                                                  maxLength: 1,
                                                  textAlign: TextAlign.center,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  decoration: InputDecoration(
                                                    counterText: '',
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            14,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color:
                                                            Colors.grey[300]!,
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                14,
                                                              ),
                                                          borderSide: BorderSide(
                                                            color:
                                                                Colors
                                                                    .grey[300]!,
                                                          ),
                                                        ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                14,
                                                              ),
                                                          borderSide:
                                                              const BorderSide(
                                                                color: Color(
                                                                  0xFF1B4D1B,
                                                                ),
                                                                width: 2,
                                                              ),
                                                        ),
                                                  ),
                                                  onChanged: (value) {
                                                    if (value.isNotEmpty &&
                                                        index < 5) {
                                                      FocusScope.of(
                                                        context,
                                                      ).nextFocus();
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 32),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed:
                                                  provider.isLoading
                                                      ? null
                                                      : _handleVerifyOTP,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF1B4D1B,
                                                ),
                                                disabledBackgroundColor:
                                                    const Color(0xFF1B4D1B),
                                                disabledForegroundColor:
                                                    Colors.white,

                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                                elevation: 3,
                                              ),
                                              child:
                                                  provider.isLoading
                                                      ? const SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child: CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                Color
                                                              >(Colors.white),
                                                          strokeWidth: 2,
                                                        ),
                                                      )
                                                      : const Text(
                                                        'Verify OTP',
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]
                                  // Step 2: Password
                                  else if (provider.currentStep == 2) ...[
                                    const Text(
                                      'Set New Password',
                                      style: TextStyle(
                                        fontSize: 44,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1B4D1B),
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Create a new password for your account',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                        height: 1.8,
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    Container(
                                      constraints: const BoxConstraints(
                                        maxWidth: 500,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.85),
                                        borderRadius: BorderRadius.circular(25),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 30,
                                            offset: const Offset(0, 15),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(40),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'New Password*',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: passwordController,
                                            obscureText: true,
                                            decoration: InputDecoration(
                                              hintText: 'Enter new password',
                                              hintStyle: TextStyle(
                                                color: Colors.black.withOpacity(
                                                  0.5,
                                                ),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 18,
                                                    vertical: 14,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFF1B4D1B),
                                                  width: 2,
                                                ),
                                              ),
                                              suffixIcon: const Padding(
                                                padding: EdgeInsets.all(14),
                                                child: Icon(
                                                  Icons.lock_outline,
                                                  color: Color(0xFF1B4D1B),
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          const Text(
                                            'Confirm Password*',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller:
                                                confirmPasswordController,
                                            obscureText: true,
                                            decoration: InputDecoration(
                                              hintText: 'Confirm password',
                                              hintStyle: TextStyle(
                                                color: Colors.black.withOpacity(
                                                  0.5,
                                                ),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 18,
                                                    vertical: 14,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                borderSide: const BorderSide(
                                                  color: Color(0xFF1B4D1B),
                                                  width: 2,
                                                ),
                                              ),
                                              suffixIcon: const Padding(
                                                padding: EdgeInsets.all(14),
                                                child: Icon(
                                                  Icons.lock_outline,
                                                  color: Color(0xFF1B4D1B),
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 32),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed:
                                                  provider.isLoading
                                                      ? null
                                                      : _handleResetPassword,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF1B4D1B,
                                                ),
                                                disabledBackgroundColor:
                                                    const Color(0xFF1B4D1B),
                                                disabledForegroundColor:
                                                    Colors.white,

                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                                elevation: 3,
                                              ),
                                              child:
                                                  provider.isLoading
                                                      ? const SizedBox(
                                                        height: 20,
                                                        width: 20,
                                                        child: CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                Color
                                                              >(Colors.white),
                                                          strokeWidth: 2,
                                                        ),
                                                      )
                                                      : const Text(
                                                        'Reset Password',
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]
                                  // Step 3: Success
                                  else if (provider.currentStep == 3) ...[
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF1B4D1B,
                                        ).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(40),
                                      child: const Icon(
                                        Icons.check_circle_outline,
                                        size: 100,
                                        color: Color(0xFF1B4D1B),
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    const Center(
                                      child: Text(
                                        'Password Reset Successfully!',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1B4D1B),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Center(
                                      child: Text(
                                        'Your password has been successfully updated. You can now login with your new password.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                          height: 1.6,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 40),
                                    SizedBox(
                                      width: 300,
                                      child: ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF1B4D1B,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          elevation: 3,
                                        ),
                                        child: const Text(
                                          'Back to Login',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
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
    );
  }
}
