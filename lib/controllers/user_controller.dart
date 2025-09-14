import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parknjet_app/services/user_service.dart';

class UserController extends GetxController {
  var isLoading = true.obs;
  var isEditing = false.obs;
  var isChangingPassword = false.obs;
  var successMessageVisible = false.obs;
  var canEditFullNameAndEmail = true.obs;

  RxString userDetailsPasswordError = ''.obs;
  RxString passwordError = ''.obs;
  RxString newPasswordError = ''.obs;
  RxString fullNameError = ''.obs;
  RxString userNameError = ''.obs;

  // Controllers for profile info
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Controllers for password change
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final UserService userService = UserService();

  // Original data
  String originalFullName = '';
  String originalEmail = '';
  String originalPhone = '';

  @override
  void onInit() {
    super.onInit();
    loadUserDetails();
  }

  void setuserNameErrorrMessage(String value) {
    userNameError.value = value; // Set the string value
  }

  void setUserDetailsPasswordErrorrMessage(String value) {
    userDetailsPasswordError.value = value; // Set the string value
  }

  void setPasswordErrorMessage(String value) {
    passwordError.value = value; // Set the string value
  }

  void setNewPasswordErrorMessage(String value) {
    newPasswordError.value = value; // Set the string value
  }

  void setfullNameErrorMessage(String value) {
    fullNameError.value = value; // Set the string value
  }

  void resetUserNameErrorrMessage() {
    userNameError.value = ''; // Set the string value
  }

  void resetUserDetailsPasswordErrorrMessage() {
    userDetailsPasswordError.value = ''; // Reset the string value
  }

  void resetPasswordErrorMessage() {
    passwordError.value = ''; // Reset the string value
  }

  void resetNewPasswordErrorMessage() {
    newPasswordError.value = ''; // Reset the string value
  }

  void resetfulNameErrorMessage() {
    fullNameError.value = ''; // Reset the string value
  }

  Future<void> loadUserDetails() async {
    try {
      isLoading.value = true;
      // Replace with the actual user ID fetching mechanism
      var user = await userService.getUserDetails();
      if (user != null) {
        originalFullName = user.fullName;
        originalEmail = user.userName;
        originalPhone = user.phone;

        fullNameController.text = originalFullName;
        emailController.text = originalEmail;
        phoneController.text = originalPhone;

        if (user.isAppleAuth == 1 ||
            user.isMetaAuth == 1 ||
            user.isGoogleAuth == 1) {
          canEditFullNameAndEmail.value = false;
        } else {
          canEditFullNameAndEmail.value = true;
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load user details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void toggleEdit() {
    if (isEditing.value) {
      // Restore original data
      fullNameController.text = originalFullName;
      emailController.text = originalEmail;
      phoneController.text = originalPhone;
      passwordController.clear();
    }
    isEditing.value = !isEditing.value;
  }

  void togglePasswordChange() {
    isChangingPassword.value = !isChangingPassword.value;
    currentPasswordController.text = "";
    newPasswordController.text = "";
    confirmPasswordController.text = "";
  }

  Future<void> saveDetails(BuildContext context) async {
    resetUserDetailsPasswordErrorrMessage();
    resetfulNameErrorMessage();
    resetUserNameErrorrMessage();
    isLoading.value = true;

    try {
      // Validate fields if needed
      String fullName = fullNameController.text;
      String email = emailController.text;
      String phone = phoneController.text;
      String password = passwordController.text;

      if (canEditFullNameAndEmail.value == true) {
        if (password.isEmpty) {
          isLoading.value = false;
          userDetailsPasswordError.value = "Password is required";
          return;
        } else {
          userDetailsPasswordError.value = "";
        }
      }

      // Replace with the actual user ID fetching mechanism
      var response =
          await userService.updateUser(fullName, email, phone, password);
      final body = jsonDecode(response.body);
      // print(body);
      if (response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "Profile info updated successfully",
          colorText: Colors.green,
          backgroundColor: Colors.green[50],
          snackPosition: SnackPosition.BOTTOM,
        );
        // Update original data
        originalFullName = fullName;
        originalEmail = email;
        originalPhone = phone;

        // Update state with new values
        successMessageVisible.value = true;
        isLoading.value = false;
        toggleEdit();
        // return User.fromJson(jsonDecode(response.body)['data']);
      }

      if (response.statusCode == 422) {
        // print(response.statusCode);
        if (body['message'] is String) {
          setUserDetailsPasswordErrorrMessage(body['message'].toString());
          isLoading.value = false;
        } else {
          if (body['message'].containsKey("full_name")) {
            setfullNameErrorMessage(body['message']['full_name'][0]);
          }
          if (body['message'].containsKey("user_name")) {
            setuserNameErrorrMessage(body['message']['user_name'][0]);
          }
          isLoading.value = false;
        }
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      isLoading.value = false; // userDetailsPasswordError.value = e.toString();
    }
  }

  void cancelEdit() {
    // Restore original data
    fullNameController.text = originalFullName;
    emailController.text = originalEmail;
    phoneController.text = originalPhone;
    passwordController.clear();
    passwordError.value = "";
    isEditing.value = false;
  }

  var passwordConfirmationError = ''.obs;

  Future<void> updatePassword(BuildContext context) async {
    resetNewPasswordErrorMessage();
    resetPasswordErrorMessage();
    String currentPassword = currentPasswordController.text;
    String newPassword = newPasswordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      passwordConfirmationError.value = "Confirm password doesn't match";
      return;
    } else {
      passwordConfirmationError.value = "";
    }
    showDialog(
      context: context,
      barrierDismissible:
          false, // This prevents dismissing the dialog when clicking outside it
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async =>
              false, // Prevents the back button from dismissing the dialog
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
    try {
      // Replace with the actual user ID fetching mechanism
      var response = await userService.updatePassword(
          currentPassword, newPassword, confirmPassword);

      final body = jsonDecode(response.body);
      // print(body);
      if (response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "Password updated successfully",
          colorText: Colors.green,
          backgroundColor: Colors.green[50],
          snackPosition: SnackPosition.BOTTOM,
        );
        isChangingPassword.value = true;
        currentPassword = "";
        currentPasswordController.text = "";
        newPassword = "";
        newPasswordController.text = "";
        confirmPassword = "";
        confirmPasswordController.text = "";
        // Navigator.of(context).pop();
        Navigator.of(context, rootNavigator: true).pop(context);
        togglePasswordChange();
      } else if (response.statusCode == 422) {
        if (body['message'] is String) {
          setPasswordErrorMessage(body['message'].toString());
          isLoading.value = false;
        } else {
          if (body['message'].containsKey("password")) {
            setNewPasswordErrorMessage(body['message']['password'][0]);
          }
        }

        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pop();

        throw Exception('Failed to update password');
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update password: $e");
      Navigator.of(context).pop();
    }
  }
}
