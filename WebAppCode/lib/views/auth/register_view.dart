import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_defaults.dart';
import 'package:sen_gs_1_ca_connector_plugin/localization_service.dart';
import 'package:sen_gs_1_web/controls/buttons/auth_button.dart';
import 'package:sen_gs_1_web/controls/helpers/custom_text_field.dart';
import 'package:sen_gs_1_web/cubit/app_cubit.dart';
import 'package:sen_gs_1_web/views/auth/confirm_account_view.dart';
import 'package:sen_gs_1_web/controls/helpers/create_fade_route.dart';

class RegisterView extends StatefulWidget {
  final VoidCallback? onLogin;

  const RegisterView({super.key, this.onLogin});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  bool isLoading = false;
  bool isAgreedToPrivacyPolicy = false;
  String? messageText;
  bool isError = false;
  final Map<String, String?> errorMessages = {
    'email': null,
    'password': null,
    'firstName': null,
    'lastName': null,
    'dateOfBirth': null,
    'phoneNumber': null,
  };

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    dateOfBirthController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1924),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void validateFields() {
    errorMessages.forEach((key, value) => errorMessages[key] = null);
    isError = false;

    RegExp emailPattern =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

    if (emailController.text.isEmpty) {
      isError = true;
      errorMessages['email'] = "Email cannot be empty.";
    } else if (!emailPattern.hasMatch(emailController.text)) {
      isError = true;
      errorMessages['email'] = "Email must be a valid email address.";
    }

    if (passwordController.text.isEmpty) {
      isError = true;
      errorMessages['password'] = "Password cannot be empty.";
    }

    if (firstNameController.text.isEmpty) {
      isError = true;
      errorMessages['firstName'] = "First name cannot be empty.";
    }

    if (lastNameController.text.isEmpty) {
      isError = true;
      errorMessages['lastName'] = "Last name cannot be empty.";
    }

    if (dateOfBirthController.text.isEmpty) {
      isError = true;
      errorMessages['dateOfBirth'] = "Date of birth cannot be empty.";
    }

    if (phoneNumberController.text.isEmpty) {
      isError = true;
      errorMessages['phoneNumber'] = "Phone number cannot be empty.";
    }

    if (isError) {
      messageText = "One or more parameters are incorrect.";
    }
  }

  void signUp() {
    setState(() {
      isLoading = true;
      messageText = null;
      isError = false;
    });

    validateFields();

    if (!isError) {
      context
          .read<AppCubit>()
          .signUp(
              emailController.text,
              passwordController.text,
              firstNameController.text,
              lastNameController.text,
              dateOfBirthController.text,
              phoneNumberController.text)
          .then((_) {
        Navigator.of(context).pushReplacement(
          createFadeRoute(
            ConfirmAccountView(),
          ),
        );
      }).catchError((error) {
        setState(() {
          isError = true;
          messageText = error.message;
          // handle error messages here if needed
        });
      }).whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
Widget build(BuildContext context) {
  // Get the screen width
  final screenWidth = MediaQuery.of(context).size.width;

  // Determine if the screen is mobile
  final isMobile = screenWidth < SensibleDefaults.phoneSize;

  return Scaffold(
    body: SingleChildScrollView(  // Make sure to wrap the entire body in SingleChildScrollView
      padding: EdgeInsets.symmetric(horizontal: SensibleDefaults.getPadding(context)),
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.1), // Top padding
              Text(
                LocalizationService.getString("register", "welcome"),
                style: TextStyle(
                  fontSize: SensibleDefaults.getFontSize(context, baseSize: 18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
              if (isError) ...[
                Text(
                  messageText ?? '',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: SensibleDefaults.getFontSize(context, baseSize: 14),
                  ),
                ),
                SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Added to space out fields
                children: [
                  // First Name Field
                  Expanded(
                    child: SizedBox(
                      width: isMobile ? screenWidth * 0.9 : 300, // 90% width on mobile
                      child: CustomTextField(
                        key: const Key("FirstName"),
                        label: LocalizationService.getString("register", "name"),
                        controller: firstNameController,
                        isError: errorMessages['firstName'] != null,
                        errorMessage: errorMessages['firstName'],
                      ),
                    ),
                  ),
                  SizedBox(width: SensibleDefaults.getPadding(context) * 0.05), // Space between fields
                  // Last Name Field
                  Expanded(
                    child: SizedBox(
                      width: isMobile ? screenWidth * 0.9 : 300,
                      child: CustomTextField(
                        key: const Key("LastName"),
                        label: LocalizationService.getString("register", "surname"),
                        controller: lastNameController,
                        isError: errorMessages['lastName'] != null,
                        errorMessage: errorMessages['lastName'],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
              // Email Field
              SizedBox(
                width: isMobile ? screenWidth * 0.9 : 300, // 90% width on mobile
                child: CustomTextField(
                  key: const Key("Email"),
                  label: LocalizationService.getString("login", "email"),
                  controller: emailController,
                  isError: errorMessages['email'] != null,
                  errorMessage: errorMessages['email'],
                ),
              ),
              SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
              // Date of Birth Field
              GestureDetector(
                onTap: () => selectDate(context),
                child: AbsorbPointer(
                  child: SizedBox(
                    width: isMobile ? screenWidth * 0.9 : 300, // 90% width on mobile
                    child: CustomTextField(
                      key: const Key("DateOfBirth"),
                      label: LocalizationService.getString("register", "birthdate"),
                      controller: dateOfBirthController,
                      isError: errorMessages['dateOfBirth'] != null,
                      errorMessage: errorMessages['dateOfBirth'],
                    ),
                  ),
                ),
              ),
              SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
              // Phone Number Field
              SizedBox(
                width: isMobile ? screenWidth * 0.9 : 300, // 90% width on mobile
                child: CustomTextField(
                  key: const Key("PhoneNumber"),
                  label: LocalizationService.getString("register", "phonenumber"),
                  controller: phoneNumberController,
                  isError: errorMessages['phoneNumber'] != null,
                  errorMessage: errorMessages['phoneNumber'],
                ),
              ),
              SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
              // Password Field
              SizedBox(
                width: isMobile ? screenWidth * 0.9 : 300, // 90% width on mobile
                child: CustomTextField(
                  key: const Key("Password"),
                  label: LocalizationService.getString("login", "password"),
                  controller: passwordController,
                  obscureText: true,
                  isError: errorMessages['password'] != null,
                  errorMessage: errorMessages['password'],
                ),
              ),
              SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
              CheckboxListTile(
                value: isAgreedToPrivacyPolicy,
                title: Text(
                  LocalizationService.getString("register", "terms"),
                  style: TextStyle(fontSize: SensibleDefaults.getFontSize(context, baseSize: 14)),
                ),
                onChanged: (newValue) {
                  setState(() {
                    isAgreedToPrivacyPolicy = newValue ?? false;
                  });
                },
              ),
              SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
              if (isLoading) const Center(child: CircularProgressIndicator()),
              if (!isLoading)
                SizedBox(
                  width: isMobile ? screenWidth * 0.9 : null, // 90% width on mobile
                  child: AuthButton(
                    key: const Key("Register"),
                    onPressed: isAgreedToPrivacyPolicy ? signUp : () {},
                    text: LocalizationService.getString("register", "create_account"),
                  ),
                ),
              SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
              TextButton(
                onPressed: widget.onLogin,
                child: Text(
                  LocalizationService.getString("register", "already_user"),
                  style: TextStyle(fontSize: SensibleDefaults.getFontSize(context)),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
}
