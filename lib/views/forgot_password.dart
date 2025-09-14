import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:parknjet_app/services/forget_password_service.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<StatefulWidget> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response =
          await ForgetPasswordService.forgetPassword(_emailController.text);
      final body = response.body;
      final json = jsonDecode(body);
      if (response.statusCode == 200) {
        setState(() {
          _successMessage = 'Password reset link sent successfully!';
          _emailController.clear();
        });
      } else if (response.statusCode == 403) {
        setState(() {
          _errorMessage = json['message'];
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = json['message'];
        });
      } else if (response.statusCode == 422) {
        setState(() {
          _errorMessage = json['message']['user_name'][0];
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to send password reset link. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: AppBar(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: SizedBox(
              child: Card(
                shadowColor: Colors.white,
                elevation: 10.0,
                surfaceTintColor: Colors.white70,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 50),
                        child: const Text(
                          'Forgot your Password?',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w400),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5, bottom: 10),
                        child: const Text(
                          'No problem. Just let us know your email address and we will send a password reset link that will allow you to choose a new one.',
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(top: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Email',
                              style: TextStyle(fontSize: 18),
                              textScaleFactor: 1.75,
                            ),
                            const Gap(10),
                            TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.only(left: 5),
                              ),
                            ),
                            if (_errorMessage != null) ...[
                              const Gap(10),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Gap(20),
                      GestureDetector(
                        onTap: _isLoading ? null : _submit,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: Colors.red,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.all(6),
                                child: const Text(
                                  'Password reset link',
                                  style: TextStyle(
                                    fontFamily: 'SF PRO DISPLAY',
                                    fontSize: 19,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  textScaleFactor: 1.75,
                                ),
                              ),
                              if (_isLoading)
                                Container(
                                  margin: const EdgeInsets.only(left: 5),
                                  child: const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                      strokeWidth: 2.0,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  margin: const EdgeInsets.only(left: 5),
                                  child: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (_successMessage != null) ...[
                        const Gap(20),
                        Center(
                          child: Text(
                            _successMessage!,
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
