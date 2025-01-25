import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_colors.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_defaults.dart';
import 'package:sen_gs_1_ca_connector_plugin/localization_service.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/user.dart';
import 'package:sen_gs_1_web/cubit/app_cubit.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;

  String get fullName =>
      "${_firstNameController.text} ${_lastNameController.text}";

  String get nickname =>
      "${_firstNameController.text} ${_lastNameController.text.isNotEmpty ? _lastNameController.text[0] : ''}";

  Future<void> _logout(BuildContext context) async {
    try {
      final appCubit = BlocProvider.of<AppCubit>(context);
      await appCubit.signOut();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _deleteAccount() async {
    try {
      await Amplify.Auth.deleteUser();
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(LocalizationService.getString(
                "error", "delete_account_error"))),
      );
    }
  }

  Future<void> _saveChanges() async {
    try {
      _isLoading = true;
      final firstName = _firstNameController.text;
      final lastName = _lastNameController.text;
      final email = _emailController.text;
      final phoneNumber = _phoneController.text;

      final updatedAttributes = {
        AuthUserAttributeKey.givenName: firstName,
        AuthUserAttributeKey.familyName: lastName,
        AuthUserAttributeKey.email: email,
        AuthUserAttributeKey.phoneNumber: phoneNumber,
      };

      final attributesList = updatedAttributes.entries
          .map((entry) => AuthUserAttribute(
              userAttributeKey: entry.key, value: entry.value))
          .toList();

      await Amplify.Auth.updateUserAttributes(attributes: attributesList);

      final appCubit = BlocProvider.of<AppCubit>(context);

      final updatedUser = appCubit.state.systemResourceState.user?.copyWith(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      );

      if (updatedUser != null) {
        appCubit.updateUser(updatedUser);
        setState(() {
          _isEditing = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(LocalizationService.getString("profile", "success"))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(LocalizationService.getString("error", "profile_error"))),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildActionButton(String text, VoidCallback onPressed,
      {Color? backgroundColor, Color? textColor, bool removeBorder = false}) {
    final isMobile = MediaQuery.of(context).size.width < SensibleDefaults.phoneSize; //TO DO check what is the standard phone width, boothstrap, default waarde, lengte knoppen wanneer mobiel 80%
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      width: isMobile
          ? MediaQuery.of(context).size.width * 0.70
          : MediaQuery.of(context).size.width * 0.14,
      decoration: BoxDecoration(
        border: removeBorder
            ? null
            : Border.all(
                color: SensibleColors.sensibleDeepBlue,
                width: 2,
              ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(
            vertical: 10), // Increase padding for larger buttons
        onPressed: onPressed,
        color: backgroundColor,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color:
                textColor ?? CupertinoTheme.of(context).primaryContrastingColor,
            fontSize: SensibleDefaults.getFontSize(context),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<AppCubit, AppState>(
        builder: (BuildContext context, AppState appState) {
          final user = appState.systemResourceState.user;

          if (user == null) {
            return Center(
              child: Text(
                LocalizationService.getString("error", "no_user_data"),
              ),
            );
          }

          _firstNameController.text = user.firstName ?? '';
          _lastNameController.text = user.lastName ?? '';
          _emailController.text = user.email;
          _phoneController.text = user.phoneNumber ?? '';

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Profile Column Container
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: _buildProfileColumn(user, context),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Details Column Container
                        Center(
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: _buildDetailsColumn(user, context),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Column Container
                        Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          padding: const EdgeInsets.all(10),
                          child: _buildProfileColumn(user, context),
                        ),
                        const SizedBox(width: 20),
                        // Details Column Container
                        Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          padding: const EdgeInsets.all(10),
                          child: _buildDetailsColumn(user, context),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileColumn(User user, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.20,
      color: CupertinoColors.systemGroupedBackground,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: CircleAvatar(
              radius: 75,
              backgroundColor: CupertinoColors.systemGrey,
              child: Center(
                child: Text(
                  user.firstName?.isNotEmpty ?? false
                      ? user.firstName![0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 60,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          _buildActionButton(
            LocalizationService.getString("profile", "change_password"),
            () {},
            textColor: SensibleColors.sensibleDeepBlue,
          ),
          _buildActionButton(
            LocalizationService.getString("profile", "logout"),
            () => _logout(context),
            textColor: SensibleColors.sensibleDeepBlue,
          ),
          _buildActionButton(
            LocalizationService.getString("profile", "delete_account"),
            _deleteAccount,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            removeBorder: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsColumn(User user, BuildContext context) {
  final isMobile = MediaQuery.of(context).size.width < SensibleDefaults.phoneSize; // Check if mobile
  
  return Container(
    width: MediaQuery.of(context).size.width *
        (isMobile ? 0.8 : 0.3),
    color: CupertinoColors.systemGroupedBackground,
    padding: const EdgeInsets.all(10),
    child: SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Use a Column instead of Row for mobile to stack elements
            if (isMobile) 
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocalizationService.getString("profile", "general_info"),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 15),
                  _buildActionButton(
                    _isEditing
                        ? LocalizationService.getString("profile", "cancel_edit")
                        : LocalizationService.getString("profile", "edit_profile"),
                    textColor: SensibleColors.sensibleDeepBlue,
                    () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                  ),
                ],
              )
            else 
              // Desktop layout (Row), showing button beside the text
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      LocalizationService.getString("profile", "general_info"),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildActionButton(
                    _isEditing
                        ? LocalizationService.getString(
                            "profile", "cancel_edit")
                        : LocalizationService.getString(
                            "profile", "edit_profile"),
                    textColor: SensibleColors.sensibleDeepBlue,
                    () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                  ),
                ],
              ),
            const SizedBox(height: 15),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Full Name:",
                        style: TextStyle(
                            fontSize: SensibleDefaults.getFontSize(context),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text("Phone Number:",
                        style: TextStyle(
                            fontSize: SensibleDefaults.getFontSize(context),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text("Email address:",
                        style: TextStyle(
                            fontSize: SensibleDefaults.getFontSize(context),
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text("Nickname:",
                        style: TextStyle(
                            fontSize: SensibleDefaults.getFontSize(context),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: TextStyle(
                            fontSize: SensibleDefaults.getFontSize(context)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _isEditing
                            ? _phoneController.text
                            : (_phoneController.text.isEmpty
                                ? user.phoneNumber ?? ""
                                : _phoneController.text),
                        style: TextStyle(
                            fontSize: SensibleDefaults.getFontSize(context)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _isEditing
                            ? _emailController.text
                            : (_emailController.text.isEmpty
                                ? user.email
                                : _emailController.text),
                        style: TextStyle(
                            fontSize: SensibleDefaults.getFontSize(context)),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        nickname,
                        style: TextStyle(
                            fontSize: SensibleDefaults.getFontSize(context)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isEditing) ...[
              CupertinoTextField(
                controller: _firstNameController,
                placeholder: LocalizationService.getString("profile", "name"),
              ),
              const SizedBox(height: 5),
              CupertinoTextField(
                controller: _lastNameController,
                placeholder:
                    LocalizationService.getString("profile", "surname"),
              ),
              const SizedBox(height: 5),
              CupertinoTextField(
                controller: _emailController,
                placeholder:
                    LocalizationService.getString("profile", "email"),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 5),
              CupertinoTextField(
                controller: _phoneController,
                placeholder:
                    LocalizationService.getString("profile", "phonenumber"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 15),
              CupertinoButton.filled(
                onPressed: _saveChanges,
                child: _isLoading
                    ? const CupertinoActivityIndicator()
                    : Text(LocalizationService.getString("profile", "save"),
                        style: TextStyle(
                            fontSize: SensibleDefaults.getFontSize(context))),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}
}
