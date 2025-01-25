import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sen_gs_1_ca_connector_plugin/system_resource_controller.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/system_resource_state.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/user.dart';
import 'package:sen_gs_1_ca_connector_plugin/web_connector_plugin.dart';

part '../cubit/app_state.dart';

class AppCubit extends Cubit<AppState> {
  final SystemResourceController _systemResourceController;
  final WebConnectorPlugin _webConnectorLibrary;

  // Constructor
  AppCubit(this._systemResourceController, this._webConnectorLibrary)
      : super(const AppState.initial()) {
    _observeConnectorState();
  }

  // Initializes the connection manager based on the context (web).
  Future<void> initialize() async {
    await _systemResourceController.initialize();
    _initializeAuthenticationState();
  }

  // Observes the connector state and emits state changes based on events from the connection manager.
  void _observeConnectorState() {
    _systemResourceController.observeConnectorState().then((stream) {
      stream.listen((event) {
        emit(AppState(event)); // Emits the state when the event changes
      });
    }).catchError((error) {
      emit(state.copyWith(
        systemResourceState: state.systemResourceState.copyWith(
          errorMessage: error.toString(),
        ),
      ));
    });
  }

 Future<void> _initializeAuthenticationState() async {
    try {
      final user = await _webConnectorLibrary.initializeAuthenticationState();

      if (user != null) {
        
        // Emit state with authenticated user
        emit(state.copyWith(
          systemResourceState: state.systemResourceState.copyWith(
            cloudAuthenticationState: CloudAuthenticationState.authenticated,
            user: user,
          ),
        ));
      } else {

        // Emit unauthenticated state
        emit(state.copyWith(
          systemResourceState: state.systemResourceState.copyWith(
            cloudAuthenticationState: CloudAuthenticationState.unAuthenticated,
          ),
        ));
      }
    } catch (e) {
      print("Error during authentication initialization: $e");

      // In case of error, treat as unauthenticated
      emit(state.copyWith(
        systemResourceState: state.systemResourceState.copyWith(
          cloudAuthenticationState: CloudAuthenticationState.unAuthenticated,
        ),
      ));
    }
  }

  // Utility method to handle API calls with error management
  Future<void> _handleApiCall(
    Future<void> Function() apiCall, {
    String errorMessage = "An error occurred",
  }) async {
    try {
      await apiCall();
    } catch (e) {
      debugPrint('$errorMessage: $e');
      emit(state.copyWith(
        systemResourceState: state.systemResourceState.copyWith(
          errorMessage: errorMessage,
        ),
      ));
    }
  }

  // Sign in user and fetch user details
  Future<void> signIn(String email, String password) async {
    try {
      await _webConnectorLibrary.signIn(email, password);
      
      // If sign-in is successful, fetch the user details
      var user = await _fetchUserInfo();
      
      // Proceed with the next steps after successfully fetching user details
      if (user != null) {
        // Emit the new state with the user info, no need to manually set `cloudAuthenticationState`
        emit(state.copyWith(
          systemResourceState: state.systemResourceState.copyWith(
            cloudAuthenticationState: CloudAuthenticationState.authenticated,
            user: user,
            errorMessage: null, // Clear any previous error
          ),
        ));
      } else {
        emit(state.copyWith(
          systemResourceState: state.systemResourceState.copyWith(
            cloudAuthenticationState: CloudAuthenticationState.unAuthenticated,
            errorMessage: 'Failed to retrieve user information.',
          ),
        ));
      }
    } catch (e) {
      debugPrint('Sign-in failed: $e');
      emit(state.copyWith(
        systemResourceState: state.systemResourceState.copyWith(
          cloudAuthenticationState: CloudAuthenticationState.unAuthenticated,
          errorMessage: 'Failed to sign in. Please try again.',
        ),
      ));
    }
  }

  // Fetch user info after sign-in
  Future<User?> _fetchUserInfo() async {
    try {
      return await _webConnectorLibrary.fetchUser();
    } catch (e) {
      debugPrint('Error fetching user info: $e');
      return null;
    }
  }

  // Sign up a new user
  Future<void> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    String dateOfBirth,
    String phoneNumber,
  ) async {
    await _handleApiCall(
      () => _webConnectorLibrary.signUp(
        email,
        password,
        firstName,
        lastName,
        dateOfBirth,
        phoneNumber,
        "default-photo",
      ),
      errorMessage: "Failed to sign up. Please try again.",
    );
  }

  // Sign out the current user
  Future<void> signOut() async {
    try {
      await _webConnectorLibrary.signOut();
      emit(state.copyWith(
        systemResourceState: state.systemResourceState.copyWith(
          cloudAuthenticationState: CloudAuthenticationState.unAuthenticated,
          user: null, // Clear the user data on sign out
          errorMessage: null, // Clear any previous error
        ),
      ));
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  // Confirm account after sign-up
  Future<void> confirmAccount(String email, String verificationCode) async {
    await _handleApiCall(
      () => _webConnectorLibrary.confirmAccount(email, verificationCode),
      errorMessage: "Failed to confirm account",
    );
  }

  // Resend confirmation code to the user
  Future<void> resendConfirmationCode(String email) async {
    await _handleApiCall(
      () => _webConnectorLibrary.resendConfirmationCode(email),
      errorMessage: "Failed to resend confirmation code",
    );
  }

  // Initiate password reset process
  Future<void> forgotPassword(String email) async {
    await _handleApiCall(
      () => _webConnectorLibrary.forgotPassword(email),
      errorMessage: "Failed to initiate password reset",
    );
  }

  // Confirm password reset with new password and verification code
  Future<void> confirmPasswordReset(
    String email,
    String verificationCode,
    String password,
  ) async {
    await _handleApiCall(
      () => _webConnectorLibrary.confirmPasswordReset(
        email,
        verificationCode,
        password,
      ),
      errorMessage: "Failed to reset password",
    );
  }

  // Update user information locally in the app state
  void updateUser(User updatedUser) {
    emit(state.copyWith(
      systemResourceState:
          state.systemResourceState.copyWith(user: updatedUser),
    ));
  }
}
