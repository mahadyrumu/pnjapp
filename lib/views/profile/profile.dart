import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:parknjet_app/config/utils.dart';
import 'package:parknjet_app/controllers/user_controller.dart';
import 'package:parknjet_app/views/home/homepage.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserController userController = Get.put(UserController());

  final _formKeyProfile = GlobalKey<FormState>();

  final _formKeyPass = GlobalKey<FormState>();
  final _formKeyDeleteAcc = GlobalKey<FormState>();

  // Mask Formatter for US Phone Number (e.g., (123) 456-7890)
  final maskFormatter = MaskTextInputFormatter(
    mask: '(###) ###-####',
    filter: {'#': RegExp(r'[0-9]')}, // Only allow digits
    type: MaskAutoCompletionType.lazy,
  );

  // Reset the formatter when needed
  void resetFormatter() {
    maskFormatter.clear();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.loadUserDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    double currentScale = MediaQuery.textScalerOf(context).textScaleFactor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile Information',
          textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            // Change the route or perform any action here
            Get.to(() => HomePage(), transition: Transition.leftToRight);
          },
        ),
      ),
      body: Obx(
        () {
          if (userController.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Information Card
                Stack(
                  children: [
                    Card(
                      elevation: 4.0,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKeyProfile,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Gap(40.0),
                              Text(
                                'Profile Information',
                                textScaler: TextScaler.linear(
                                    getTextScale(currentScale, 1.65)),
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                  height:
                                      16.0), // To provide space for the button
                              if (!userController.isEditing.value)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    buildProfileInfo(
                                        'Full Name:',
                                        userController.fullNameController.text,
                                        currentScale),
                                    const SizedBox(height: 8.0),
                                    buildProfileInfo(
                                        'Email:',
                                        userController.emailController.text,
                                        currentScale),
                                    const SizedBox(height: 8.0),
                                    buildProfileInfo(
                                        'Phone Number:',
                                        userController.phoneController.text,
                                        currentScale),
                                    const SizedBox(height: 16.0),
                                  ],
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Obx(() {
                                      return userController
                                                  .canEditFullNameAndEmail ==
                                              true
                                          ? buildEditableField(
                                              'Full Name',
                                              userController.fullNameController,
                                              currentScale)
                                          : buildNonEditableField(
                                              'Full Name',
                                              userController.fullNameController,
                                              currentScale);
                                    }),
                                    Obx(() {
                                      return userController
                                              .fullNameError.value.isNotEmpty
                                          ? Text(
                                              userController
                                                  .fullNameError.value,
                                              style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 176, 15, 3)),
                                            )
                                          : Container();
                                    }),
                                    const SizedBox(height: 10),
                                    Obx(() {
                                      return userController
                                                  .canEditFullNameAndEmail ==
                                              true
                                          ? buildEditableField(
                                              'Email',
                                              userController.emailController,
                                              currentScale)
                                          : buildNonEditableField(
                                              'Email',
                                              userController.emailController,
                                              currentScale);
                                    }),
                                    Obx(() {
                                      return userController
                                              .userNameError.value.isNotEmpty
                                          ? Text(
                                              userController
                                                  .userNameError.value,
                                              style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 176, 15, 3)),
                                            )
                                          : Container();
                                    }),
                                    const SizedBox(height: 10),
                                    buildEditablePhoneField(
                                        'Phone Number',
                                        userController.phoneController,
                                        currentScale),
                                    const SizedBox(height: 16.0),
                                    Obx(() {
                                      return userController
                                                  .canEditFullNameAndEmail ==
                                              true
                                          ? Column(
                                              children: [
                                                const Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    'Enter your password to make changes',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.normal),
                                                  ),
                                                ),
                                                TextFormField(
                                                  controller: userController
                                                      .passwordController,
                                                  decoration: InputDecoration(
                                                    errorMaxLines: 2,
                                                    hintText: 'Password',
                                                    errorText: userController
                                                            .userDetailsPasswordError
                                                            .value
                                                            .isNotEmpty
                                                        ? userController
                                                            .userDetailsPasswordError
                                                            .value
                                                        : null,
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Password is required';
                                                    }
                                                    return null;
                                                  },
                                                  obscureText: true,
                                                ),
                                              ],
                                            )
                                          : Container();
                                    }),
                                    const SizedBox(height: 16.0),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            userController.saveDetails(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: Text(
                                            'Save Details',
                                            textScaler: TextScaler.linear(
                                                getTextScale(
                                                    currentScale, 1.65)),
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(width: 16.0),
                                        ElevatedButton(
                                          onPressed: userController.cancelEdit,
                                          style: ElevatedButton.styleFrom(
                                            elevation: 3.0,
                                            backgroundColor: Colors.grey[300],
                                          ),
                                          child: Text(
                                            'Cancel',
                                            textScaler: TextScaler.linear(
                                                getTextScale(
                                                    currentScale, 1.65)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!userController.isEditing.value)
                      Positioned(
                        top: 8.0, // Adjusted to account for padding
                        right: 16.0,
                        child: TextButton.icon(
                          onPressed: () {
                            resetFormatter();
                            userController.toggleEdit();
                          },
                          icon: const Icon(Icons.edit, color: Colors.white),
                          label: Text(
                            'Edit Profile',
                            textScaler: TextScaler.linear(
                                getTextScale(currentScale, 1.65)),
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                        ),
                      ),
                  ],
                ),

                Obx(() {
                  return userController.canEditFullNameAndEmail.value == true
                      ?
                      // Password Update Card
                      Form(
                          key: _formKeyPass,
                          child: Stack(
                            children: [
                              Card(
                                elevation: 4.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 40.0),
                                      Text(
                                        'Update Password',
                                        textScaler: TextScaler.linear(
                                            getTextScale(currentScale, 1.65)),
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'Ensure your account is using a long, random password to stay secure.',
                                        textScaler: TextScaler.linear(
                                            getTextScale(currentScale, 1.65)),
                                      ),
                                      const SizedBox(height: 16.0),
                                      if (userController
                                          .isChangingPassword.value)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            buildPasswordField(
                                                'Current Password',
                                                userController
                                                    .currentPasswordController,
                                                currentScale),
                                            Obx(() {
                                              return userController
                                                      .passwordError
                                                      .value
                                                      .isNotEmpty
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5),
                                                      child: Text(
                                                        userController
                                                            .passwordError
                                                            .value,
                                                        style: const TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    )
                                                  : Container();
                                            }),
                                            const SizedBox(height: 8.0),
                                            buildPasswordField(
                                                'New Password',
                                                userController
                                                    .newPasswordController,
                                                currentScale),
                                            Obx(() {
                                              return userController
                                                      .newPasswordError
                                                      .value
                                                      .isNotEmpty
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5),
                                                      child: Text(
                                                        userController
                                                            .newPasswordError
                                                            .value,
                                                        style: const TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    )
                                                  : Container();
                                            }),
                                            const SizedBox(height: 8.0),
                                            buildPasswordField(
                                                'Confirm Password',
                                                userController
                                                    .confirmPasswordController,
                                                currentScale),
                                            if (userController
                                                .passwordConfirmationError
                                                .value
                                                .isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                  userController
                                                      .passwordConfirmationError
                                                      .value,
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(height: 16.0),
                                            Row(
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    if (_formKeyPass
                                                        .currentState!
                                                        .validate()) {
                                                      userController
                                                          .updatePassword(
                                                              context);
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                  ),
                                                  child: Text(
                                                    'Update',
                                                    textScaler:
                                                        TextScaler.linear(
                                                            getTextScale(
                                                                currentScale,
                                                                1.65)),
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                const SizedBox(width: 16.0),
                                                ElevatedButton(
                                                  onPressed: userController
                                                      .togglePasswordChange,
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 3.0,
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                  ),
                                                  child: Text(
                                                    'Cancel',
                                                    textScaler:
                                                        TextScaler.linear(
                                                            getTextScale(
                                                                currentScale,
                                                                1.65)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!userController.isChangingPassword.value)
                                Positioned(
                                  top: 8.0, // Adjusted to account for padding
                                  right: 16.0,
                                  child: TextButton.icon(
                                    onPressed:
                                        userController.togglePasswordChange,
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white),
                                    label: Text(
                                      'Change Password',
                                      textScaler: TextScaler.linear(
                                          getTextScale(currentScale, 1.65)),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : Container();
                }),
                Obx(() {
                  return userController.canEditFullNameAndEmail.value == true
                      ?
                      // Account Delete Card
                      Form(
                          key: _formKeyDeleteAcc,
                          child: Stack(
                            children: [
                              Card(
                                elevation: 4.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 40.0),
                                      Text(
                                        'Delete Profile',
                                        textScaler: TextScaler.linear(
                                            getTextScale(currentScale, 1.65)),
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        'You can delete your profile and all associated information from our database at any time by clicking the button below.',
                                        textScaler: TextScaler.linear(
                                            getTextScale(currentScale, 1.65)),
                                      ),
                                      const SizedBox(height: 16.0),
                                      if (userController
                                          .isChangingPassword.value)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            buildPasswordField(
                                                'Current Password',
                                                userController
                                                    .currentPasswordController,
                                                currentScale),
                                            Obx(() {
                                              return userController
                                                      .passwordError
                                                      .value
                                                      .isNotEmpty
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5),
                                                      child: Text(
                                                        userController
                                                            .passwordError
                                                            .value,
                                                        style: const TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    )
                                                  : Container();
                                            }),
                                            const SizedBox(height: 8.0),
                                            buildPasswordField(
                                                'New Password',
                                                userController
                                                    .newPasswordController,
                                                currentScale),
                                            Obx(() {
                                              return userController
                                                      .newPasswordError
                                                      .value
                                                      .isNotEmpty
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5),
                                                      child: Text(
                                                        userController
                                                            .newPasswordError
                                                            .value,
                                                        style: const TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    )
                                                  : Container();
                                            }),
                                            const SizedBox(height: 8.0),
                                            buildPasswordField(
                                                'Confirm Password',
                                                userController
                                                    .confirmPasswordController,
                                                currentScale),
                                            if (userController
                                                .passwordConfirmationError
                                                .value
                                                .isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                  userController
                                                      .passwordConfirmationError
                                                      .value,
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 14.0,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(height: 16.0),
                                            Row(
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () {
                                                    if (_formKeyDeleteAcc
                                                        .currentState!
                                                        .validate()) {
                                                      userController
                                                          .updatePassword(
                                                              context);
                                                    }
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                  ),
                                                  child: Text(
                                                    'Update',
                                                    textScaler:
                                                        TextScaler.linear(
                                                            getTextScale(
                                                                currentScale,
                                                                1.65)),
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                                const SizedBox(width: 16.0),
                                                ElevatedButton(
                                                  onPressed: userController
                                                      .togglePasswordChange,
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 3.0,
                                                    backgroundColor:
                                                        Colors.grey[300],
                                                  ),
                                                  child: Text(
                                                    'Cancel',
                                                    textScaler:
                                                        TextScaler.linear(
                                                            getTextScale(
                                                                currentScale,
                                                                1.65)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!userController.isChangingPassword.value)
                                Positioned(
                                  top: 8.0, // Adjusted to account for padding
                                  right: 16.0,
                                  child: TextButton.icon(
                                    onPressed:
                                        userController.togglePasswordChange,
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white),
                                    label: Text(
                                      'Delete Account',
                                      textScaler: TextScaler.linear(
                                          getTextScale(currentScale, 1.65)),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : Container();
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildProfileInfo(String label, String value, currentScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textScaler: TextScaler.linear(getTextScale(currentScale, 1.65)),
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEditablePhoneField(
      String label, TextEditingController controller, currentScale) {
    return TextField(
      style: TextStyle(
        fontSize: getHintTextScale(currentScale, 0.65, 16),
      ),
      controller: controller,
      inputFormatters: [maskFormatter],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: getHintTextScale(currentScale, 0.65, 16),
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget buildEditableField(
      String label, TextEditingController controller, currentScale) {
    return TextField(
      style: TextStyle(
        fontSize: getHintTextScale(currentScale, 0.65, 16),
      ),
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: getHintTextScale(currentScale, 0.65, 16),
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget buildNonEditableField(
      String label, TextEditingController controller, currentScale) {
    return TextField(
      style: TextStyle(
        fontSize: getHintTextScale(currentScale, 0.65, 16),
      ),
      controller: controller,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: getHintTextScale(currentScale, 0.65, 16),
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget buildPasswordField(
      String label, TextEditingController controller, currentScale) {
    return TextFormField(
      style: TextStyle(
        fontSize: getHintTextScale(currentScale, 0.65, 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: getHintTextScale(currentScale, 0.65, 16),
        ),
        border: const OutlineInputBorder(),
      ),
      obscureText: true,
    );
  }
}
