// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sen_gs_1_ca_connector_plugin/consent/consent_models.dart';
import 'package:sen_gs_1_ca_connector_plugin/consent/consent_service.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_defaults.dart';
import 'package:sen_gs_1_ca_connector_plugin/localization_service.dart';

class ConsentFunctions {
  List<LocalConsentRecord> outboundItems = [];
  List<LocalConsentRecord> inboundItems = [];

  Future<void> addConsentRequest(BuildContext context, String userId,
      String userEmail, String? message, List<String> dataTypeIds,
      {DateTime? expiry}) async {
    try {
      final consentService = ConsentService();
      InboundEntityType inboundEntityType = InboundEntityType.USER;

      final consentItems = dataTypeIds
          .map((dataTypeId) => LocalConsentItem(
                dataType: DataTypeInfo(
                  id: dataTypeId,
                  friendlyName: 'Friendly Name',
                  dataFormat: DataFormat.NUMBER,
                ),
                status: ConsentItemStatus.PENDING,
                from: DateTime.now().toUtc().millisecondsSinceEpoch,
                expiry: expiry?.toUtc().millisecondsSinceEpoch ??
                    DateTime.now()
                        .add(const Duration(days: 14))
                        .toUtc()
                        .millisecondsSinceEpoch,
                history: [
                  ConsentItemEvent(
                    eventTime: DateTime.now().toUtc().millisecondsSinceEpoch,
                    newStatus: ConsentItemStatus.PENDING,
                    oldStatus: null,
                    description: message ?? 'Consent request from $userEmail',
                  )
                ],
              ))
          .toList();

      final consentRequest = LocalConsentRequest(
        inboundEntityId: userId,
        outboundEmail: userEmail,
        inboundEntityType: inboundEntityType,
        consentItems: consentItems,
      );

      await consentService.addConsentRequest(consentRequest);

      _showDialog(
        context,
        title: LocalizationService.getString('general', 'success'),
        message: LocalizationService.getString("consent", "request_success"),
      );
    } catch (e) {
      print('Error adding consent request: $e');
      showErrorDialog(
          context,
          LocalizationService.getString("general", "error"),
          LocalizationService.getString("error", "consent_request_error"));
    }
  }

  void _showDialog(BuildContext context,
      {required String title, required String message}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(LocalizationService.getString('general', 'okay')),
            ),
          ],
        );
      },
    );
  }

  void showConsentDetailsDialog(BuildContext context, LocalConsentRecord item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocalizationService.getString("general", "details")),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${LocalizationService.getString("consent", "my_name")}: ${item.inboundEntity.displayName}',
                  style: TextStyle(
                      fontSize: SensibleDefaults.getFontSize(context),
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
                Text(
                  '${LocalizationService.getString("consent", "other")}: ${item.outboundEntity.email}',
                  style: TextStyle(
                      fontSize: SensibleDefaults.getFontSize(context)),
                ),
                SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
                Text(
                  '${LocalizationService.getString("consent", "requested_data")}: ${item.consentItems.first.dataType.id}',
                  style: TextStyle(
                      fontSize: SensibleDefaults.getFontSize(context)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> confirmConsent(
      BuildContext context, LocalConsentRecord item) async {
    try {
      final consentService = ConsentService();

      await consentService.confirmConsentRequest(item);

      _showDialog(
        context,
        title: LocalizationService.getString('general', 'success'),
        message: LocalizationService.getString("consent", "confirm_success"),
      );
    } catch (e) {
      print('Error confirming consent: $e');
      showErrorDialog(
          context,
          LocalizationService.getString("general", "error"),
          LocalizationService.getString("error", "consent_confirm_error"));
    }
  }

  Future<void> revokeConsent(
      BuildContext context, LocalConsentRecord consentRecord) async {
    try {
      String reason =
          LocalizationService.getString("consent", "default_revoke_message");
      reason = await _showRevokeDialog(context) ?? reason;

      if (reason.isNotEmpty) {
        final consentService = ConsentService();
        await consentService.revokeConsent(
          consentRecord.inboundEntity.id,
          consentRecord.consentItems.map((item) => item.dataType.id).toList(),
          reason: reason,
        );

        _showDialog(
          context,
          title: LocalizationService.getString('general', 'success'),
          message: LocalizationService.getString("consent", "revoke_success"),
        );
      }
    } catch (e) {
      print('Error revoking consent: $e');
      showErrorDialog(
          context,
          LocalizationService.getString("general", "error"),
          'Failed to revoke consent');
    }
  }

  Future<String?> _showRevokeDialog(BuildContext context) {
    TextEditingController reasonController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocalizationService.getString("consent", "revoke")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(LocalizationService.getString(
                  "consent", "revoke_reason_request")),
              SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText:
                      LocalizationService.getString("consent", "revoke_reason"),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: Text(LocalizationService.getString("general", "back")),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                    context,
                    reasonController.text.trim().isEmpty
                        ? LocalizationService.getString(
                            "consent", "default_revoke_message")
                        : reasonController.text.trim());
              },
              child: Text(LocalizationService.getString("general", "submit")),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showAddConsentRequestDialog(
    BuildContext context,
    TextEditingController emailController,
    TextEditingController messageController,
    DateTime? selectedExpiryDate,
    Function(String email, String message, DateTime expiry) onSubmit,
  ) async {
    bool isChecked = false; // State for the checkbox

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Stack(
              children: [
                // Blurred Background
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                // Dialog Box
                Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isPhone =
                          constraints.maxWidth <= SensibleDefaults.phoneSize;

                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isPhone
                              ? MediaQuery.of(context).size.width * 0.9
                              : MediaQuery.of(context).size.width * 0.6,
                          maxHeight: MediaQuery.of(context).size.height * 0.9,
                        ),
                        child: SingleChildScrollView(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blue,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Title
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    LocalizationService.getString(
                                        "consent", "add_request"),
                                    style: TextStyle(
                                      fontSize:
                                          SensibleDefaults.getFontSize(context),
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                // Content (Email, Message, Expiry Date)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        LocalizationService.getString("consent",
                                            "consent_confirmation_person"),
                                        style:
                                            const TextStyle(color: Colors.grey),
                                      ),
                                      SizedBox(
                                          height: SensibleDefaults
                                                  .getVerticalSpacing(context) *
                                              2),
                                      isPhone
                                          ? Column(
                                              children: [
                                                TextField(
                                                  controller: emailController,
                                                  decoration: InputDecoration(
                                                    labelText:
                                                        LocalizationService
                                                            .getString(
                                                                "consent",
                                                                "user"),
                                                    border:
                                                        const OutlineInputBorder(),
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: SensibleDefaults
                                                            .getVerticalSpacing(
                                                                context) *
                                                        2),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    minimumSize: const Size(
                                                        double.infinity, 54),
                                                    backgroundColor:
                                                        Colors.blue,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4.0),
                                                    ),
                                                  ),
                                                  onPressed: isChecked
                                                      ? () {
                                                          final email =
                                                              emailController
                                                                  .text
                                                                  .trim();
                                                          final message =
                                                              messageController
                                                                      .text
                                                                      .trim()
                                                                      .isEmpty
                                                                  ? null
                                                                  : messageController
                                                                      .text
                                                                      .trim();

                                                          if (email
                                                              .isNotEmpty) {
                                                            final expiry = selectedExpiryDate ??
                                                                DateTime.now().add(
                                                                    const Duration(
                                                                        days:
                                                                            14));
                                                            onSubmit(
                                                                email,
                                                                message ?? '',
                                                                expiry);
                                                            Navigator.pop(
                                                                context);
                                                          } else {
                                                            showErrorDialog(
                                                              context,
                                                              LocalizationService
                                                                  .getString(
                                                                      "error",
                                                                      "empty_email"),
                                                              LocalizationService
                                                                  .getString(
                                                                      "error",
                                                                      "empty_email_message"),
                                                            );
                                                          }
                                                        }
                                                      : null,
                                                  child: Text(
                                                    LocalizationService
                                                        .getString("consent",
                                                            "accept"),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: SensibleDefaults
                                                          .getFontSize(context),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                Expanded(
                                                  flex: 35,
                                                  child: TextField(
                                                    controller: emailController,
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          LocalizationService
                                                              .getString(
                                                                  "consent",
                                                                  "user"),
                                                      border:
                                                          const OutlineInputBorder(),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16.0),
                                                Expanded(
                                                  flex: 35,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      minimumSize: const Size(
                                                          double.infinity, 54),
                                                      backgroundColor:
                                                          Colors.blue,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                    ),
                                                    onPressed: isChecked
                                                        ? () {
                                                            final email =
                                                                emailController
                                                                    .text
                                                                    .trim();
                                                            final message =
                                                                messageController
                                                                        .text
                                                                        .trim()
                                                                        .isEmpty
                                                                    ? null
                                                                    : messageController
                                                                        .text
                                                                        .trim();

                                                            if (email
                                                                .isNotEmpty) {
                                                              final expiry = selectedExpiryDate ??
                                                                  DateTime.now().add(
                                                                      const Duration(
                                                                          days:
                                                                              30));
                                                              onSubmit(
                                                                  email,
                                                                  message ?? '',
                                                                  expiry);
                                                              Navigator.pop(
                                                                  context);
                                                            } else {
                                                              showErrorDialog(
                                                                context,
                                                                LocalizationService
                                                                    .getString(
                                                                        "error",
                                                                        "empty_email"),
                                                                LocalizationService
                                                                    .getString(
                                                                        "error",
                                                                        "empty_email_message"),
                                                              );
                                                            }
                                                          }
                                                        : null,
                                                    child: Text(
                                                      LocalizationService
                                                          .getString("consent",
                                                              "accept"),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize:
                                                            SensibleDefaults
                                                                .getFontSize(
                                                                    context),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      SizedBox(
                                          height: SensibleDefaults
                                                  .getVerticalSpacing(context) *
                                              2),
                                      TextField(
                                        controller: messageController,
                                        decoration: InputDecoration(
                                          labelText:
                                              LocalizationService.getString(
                                                  "consent", "message"),
                                          border: const OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(
                                          height: SensibleDefaults
                                                  .getVerticalSpacing(context) *
                                              2),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              selectedExpiryDate != null
                                                  ? DateFormat('dd MMM yyyy')
                                                      .format(
                                                          selectedExpiryDate!)
                                                  : LocalizationService
                                                      .getString("consent",
                                                          "select_expiry"),
                                              style: TextStyle(
                                                fontSize: SensibleDefaults
                                                    .getFontSize(context),
                                                color:
                                                    selectedExpiryDate != null
                                                        ? Colors.black
                                                        : Colors.grey,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.calendar_today),
                                            onPressed: () async {
                                              final DateTime? pickedDate =
                                                  await showDatePicker(
                                                context: context,
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime.now().add(
                                                    const Duration(days: 365)),
                                              );
                                              if (pickedDate != null &&
                                                  pickedDate !=
                                                      selectedExpiryDate) {
                                                setState(() {
                                                  selectedExpiryDate =
                                                      pickedDate;
                                                });
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          height: SensibleDefaults
                                                  .getVerticalSpacing(context) *
                                              2),

                                      // Checkbox with Text
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: isChecked,
                                            onChanged: (bool? newValue) {
                                              setState(() {
                                                isChecked = newValue!;
                                              });
                                            },
                                          ),
                                          Expanded(
                                            child: Text(
                                              LocalizationService.getString(
                                                  "consent",
                                                  "consent_agreement"),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Actions (Cancel)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      LocalizationService.getString(
                                          "consent", "cancel"),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: SensibleDefaults.getFontSize(
                                            context),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Show error dialog
  static void showErrorDialog(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(LocalizationService.getString("general", "okay")),
            ),
          ],
        );
      },
    );
  }
}
