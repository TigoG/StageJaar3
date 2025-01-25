import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_defaults.dart';
import 'package:sen_gs_1_ca_connector_plugin/localization_service.dart';
import 'package:sen_gs_1_ca_connector_plugin/consent/consent_models.dart';
import 'package:sen_gs_1_ca_connector_plugin/consent/consent_service.dart';
import 'package:sen_gs_1_web/controls/buttons/segmented_button.dart' as custom;
import 'package:sen_gs_1_web/views/connection/consent_functions.dart';
import 'package:dotted_border/dotted_border.dart';

class ConnectionListView extends StatefulWidget {
  final String userId;

  const ConnectionListView({required this.userId, super.key});

  @override
  State<ConnectionListView> createState() => _ConnectionListViewState();
}

class _ConnectionListViewState extends State<ConnectionListView> {
  ConsentFunctions consentFunctions = ConsentFunctions();
  List<LocalConsentRecord> inboundItems = [];
  List<LocalConsentRecord> outboundItems = [];
  int _selectedSegmentIndex = 0; // 0 for inbound, 1 for outbound
  String _searchQuery = '';
  bool isLoading = true;
  String? errorMessage;
  bool isInbound = true;
  bool isBackgroundFrosted = false;

  @override
  void initState() {
    super.initState();
    fetchConsentRecord();
  }

  void toggleSegment(int index) {
    setState(() {
      _selectedSegmentIndex = index;
      isInbound = index == 0;
      fetchConsentRecord(); // Refresh consents based on the selected segment
    });
  }

  // Create the frosted glass effect overlay
  Widget generateFrostedBackground() {
    return Container(
      color: Colors.white.withOpacity(
        1,
      ),
      child: Container(
        width: double.infinity,
        //height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(1),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> fetchConsentRecord() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    // Fetch consent records
    final consents =
        await ConsentService.fetchConsentRecord(widget.userId, 'USER');

    // Separate inbound and outbound consents
    inboundItems = [];
    outboundItems = [];

    for (final consent in consents) {
      if (consent.inboundEntity.id == widget.userId) {
        inboundItems.add(consent);
      }

      if (consent.outboundEntity.id == widget.userId) {
        outboundItems.add(consent);
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  void showAddConsentRequestDialog(BuildContext context) {
    final emailController = TextEditingController();
    final messageController = TextEditingController();
    DateTime? selectedExpiryDate;

    // Show Add Consent Request Dialog
    ConsentFunctions.showAddConsentRequestDialog(
      context,
      emailController,
      messageController,
      selectedExpiryDate,
      (email, message, expiry) {
        consentFunctions.addConsentRequest(
            context, widget.userId, email, message, ["SEN-GS-1-RawVoltage"],
            expiry: expiry);
      },
    );
    setState(() {
      isBackgroundFrosted =
          true; // Activate frosted background when dialog is shown
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter the items based on the selected segment and search query
    final filteredItems = (isInbound ? inboundItems : outboundItems)
        .where((item) => item.consentItems.any((consentItem) =>
            consentItem.status.toString().toLowerCase().contains(_searchQuery)))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Frosted background effect when required
            if (isBackgroundFrosted) generateFrostedBackground(),

            // Segmented Buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: custom.SegmentedButton(
                segments: [
                  LocalizationService.getString("profile", "inbound"),
                  LocalizationService.getString("profile", "outbound"),
                ],
                selectedIndex: _selectedSegmentIndex,
                onSegmentTapped: toggleSegment,
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: LocalizationService.getString("consent", "search"),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
              ),
            ),

            // Loading, Error, No Results, or List
            if (isLoading)
              const CircularProgressIndicator()
            else if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: SensibleDefaults.getFontSize(context),
                      ),
                    ),
                    SizedBox(
                        height:
                            (SensibleDefaults.getVerticalSpacing(context) * 2)),
                    ElevatedButton(
                      onPressed: fetchConsentRecord,
                      child: Text(
                          LocalizationService.getString("consent", "retry")),
                    ),
                  ],
                ),
              )
            else if (filteredItems.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  LocalizationService.getString("consent", "no_results"),
                  style: TextStyle(
                    fontSize: SensibleDefaults.getFontSize(context),
                    color: Colors.grey,
                  ),
                ),
              )
            else
              Column(
                children: [
                  // Header Row
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 0.2 * MediaQuery.of(context).size.width,
                          child: Text(
                            LocalizationService.getString("consent", "status"),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: SensibleDefaults.getFontSize(context),
                                color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          width: 0.2 * MediaQuery.of(context).size.width,
                          child: Text(
                            LocalizationService.getString("consent", "name"),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: SensibleDefaults.getFontSize(context),
                                color: Colors.grey),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        SizedBox(
                          width: 0.4 * MediaQuery.of(context).size.width,
                          child: Text(
                            LocalizationService.getString("consent", "expires"),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: SensibleDefaults.getFontSize(context),
                                color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    color: Colors.grey,
                  ),
                  // ListView of Items
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return Card(
                          elevation: 2.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis
                                  .horizontal, // Enable horizontal scrolling
                              child: Row(
                                children: [
                                  // Status Indicator
                                  SizedBox(
                                    width:
                                        0.1 * MediaQuery.of(context).size.width,
                                    child: Center(
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: item.consentItems.isNotEmpty
                                                ? (item.consentItems.first
                                                            .status ==
                                                        ConsentItemStatus
                                                            .CONFIRMED
                                                    ? Colors.green
                                                    : item.consentItems.first
                                                                .status ==
                                                            ConsentItemStatus
                                                                .PENDING
                                                        ? Colors.orange
                                                        : Colors.red)
                                                : Colors.grey,
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            item.consentItems.isNotEmpty
                                                ? (item.consentItems.first
                                                            .status ==
                                                        ConsentItemStatus
                                                            .CONFIRMED
                                                    ? '\u2713'
                                                    : item.consentItems.first
                                                                .status ==
                                                            ConsentItemStatus
                                                                .PENDING
                                                        ? '𝐢'
                                                        : '\u2717')
                                                : '?',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: item
                                                      .consentItems.isNotEmpty
                                                  ? (item.consentItems.first
                                                              .status ==
                                                          ConsentItemStatus
                                                              .CONFIRMED
                                                      ? Colors.green
                                                      : item.consentItems.first
                                                                  .status ==
                                                              ConsentItemStatus
                                                                  .PENDING
                                                          ? Colors.orange
                                                          : Colors.red)
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Name
                                  SizedBox(
                                    width:
                                        0.3 * MediaQuery.of(context).size.width,
                                    child: Text(
                                      item.outboundEntity.displayName,
                                      style: TextStyle(
                                          fontSize:
                                              SensibleDefaults.getFontSize(
                                                  context)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Expiry Date
                                  SizedBox(
                                    width:
                                        0.4 * MediaQuery.of(context).size.width,
                                    child: Center(
                                      child: Text(
                                        DateFormat('dd MMM yyyy').format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                            item.consentItems.first.expiry,
                                          ).toLocal(),
                                        ),
                                        style: TextStyle(
                                            fontSize:
                                                SensibleDefaults.getFontSize(
                                                    context)),
                                      ),
                                    ),
                                  ),
                                  // Popup Menu
                                  PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value ==
                                          LocalizationService.getString(
                                              "consent", "accept")) {
                                        await consentFunctions.confirmConsent(
                                            context, item);
                                        await fetchConsentRecord();
                                      } else if (value == 'Details') {
                                        consentFunctions
                                            .showConsentDetailsDialog(
                                                context, item);
                                      } else if (value ==
                                          LocalizationService.getString(
                                              "consent", "reject")) {
                                        await consentFunctions.revokeConsent(
                                            context, item);
                                        await fetchConsentRecord();
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      // Determine if the item is outbound and its status
                                      final isOutbound =
                                          outboundItems.contains(item);
                                      final isConfirmed =
                                          item.consentItems.isNotEmpty &&
                                              item.consentItems.first.status ==
                                                  ConsentItemStatus.CONFIRMED;

                                      // Build the menu options dynamically
                                      final options = [
                                        if (isOutbound && !isConfirmed)
                                          LocalizationService.getString(
                                              "consent", "accept"),
                                        'Details',
                                        LocalizationService.getString(
                                            "consent", "reject"),
                                      ];
                                      return options
                                          .map(
                                              (option) => PopupMenuItem<String>(
                                                    value: option,
                                                    child: Text(option),
                                                  ))
                                          .toList();
                                    },
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
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(4),
                padding: const EdgeInsets.all(4),
                color: Colors.blue,
                strokeWidth: 1,
                dashPattern: const [4, 4],
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        isBackgroundFrosted = true;
                      });
                      showAddConsentRequestDialog(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add,
                            color: Colors.blue,
                            size: SensibleDefaults.getFontSize(context)),
                        Text(
                          LocalizationService.getString(
                              "consent", "add_request"),
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: SensibleDefaults.getFontSize(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
