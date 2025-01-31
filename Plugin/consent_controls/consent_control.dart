import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sen_gs_1_ca_connector_plugin/consent/consent_functions.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_defaults.dart';
import 'package:sen_gs_1_ca_connector_plugin/localization_service.dart';
import 'package:sen_gs_1_ca_connector_plugin/trendi_tiles/idi/consent_controls/consent_control_info.dart';
import 'package:intl/intl.dart';
import 'package:sen_gs_1_ca_connector_plugin/trendi_tiles/trendi_tile_content.dart';

class ConsentTile extends TrendiTileContent {
  const ConsentTile(this.info, {required this.userId, super.key}) : super();

  final String userId;

  @override
  final ConsentTileInfo info;

  @override
  State<ConsentTile> createState() => _ConsentTileState();
}

class _ConsentTileState extends TrendiTileContentState<ConsentTile> {
  int selectedSegmentIndex = 0;

  // Example data for consent management
  List<dynamic> inboundItems = [];
  List<dynamic> outboundItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate fetching data
    fetchConsentRecords();
  }

  void fetchConsentRecords() async {
    setState(() {
      inboundItems = [
        {"name": "John Doe", "expiry": "1737897982000", "status": "PENDING"},
        {"name": "Don Pollo", "expiry": "1737984382000", "status": "PENDING"},
        {"name": "Alice Brown", "expiry": "1740662782000", "status": "EXPIRED"},
      ];
      outboundItems = [
        {"name": "Mike Johnson", "expiry": "1737897982000", "status": "ACTIVE"},
        {"name": "Emily White", "expiry": "1740662782000", "status": "ACTIVE"},
        {"name": "Bob Green", "expiry": "1737897982000", "status": "EXPIRED"},
      ];
      isLoading = false;
    });
  }

  void toggleSegment(int index) {
    setState(() {
      selectedSegmentIndex = index;
    });
  }

  String formatDate(String timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
    return DateFormat('dd MMM yyyy').format(date);
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
        ConsentFunctions().addConsentRequest(
            context, widget.userId, email, message, ["SEN-GS-1-RawVoltage"],
            expiry: expiry);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems =
        selectedSegmentIndex == 0 ? inboundItems : outboundItems;

    final pendingItems =
        filteredItems.where((item) => item['status'] == 'PENDING').toList();
    final activeItems =
        filteredItems.where((item) => item['status'] == 'ACTIVE').toList();
    final expiredItems =
        filteredItems.where((item) => item['status'] == 'EXPIRED').toList();

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildListSection(
                          title: LocalizationService.getString(
                              'request', "pending"),
                          items: pendingItems,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: TextButton(
                            onPressed: () {
                              showAddConsentRequestDialog(context);
                            },
                            child: const Text(
                              "+ Request Someone's Data",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.blue),
                            ),
                          ),
                        ),
                        _buildListSection(
                          title: "Active Connections",
                          items: activeItems,
                        ),
                        _buildListSection(
                          title: "Expired Connections",
                          items: expiredItems,
                        ),
                      ],
                    ),
                  ),
                ),
                ToggleButtons(
                  isSelected: [
                    selectedSegmentIndex == 0,
                    selectedSegmentIndex == 1,
                  ],
                  onPressed: (int index) {
                    toggleSegment(index);
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        'Who can see me',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        'Who I can see',
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildListSection(
      {required String title, required List<dynamic> items}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: CupertinoTheme.of(context)
                .textTheme
                .textStyle
                .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "No records",
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return DefaultTextStyle(
                  style: const TextStyle(fontSize: 14),
                  child: _buildConsentItem(item),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildConsentItem(dynamic item) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 3.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              item['name'],
              style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontSize: 14),
              overflow: TextOverflow.ellipsis,
              
            ),
          ),
          Text(
            'Valid until: ${formatDate(item['expiry'])}',
            style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(fontSize: 14)
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit Data Types'),
              ),
              const PopupMenuItem(
                value: 'extend',
                child: Text('Extend Consent Duration'),
              ),
              const PopupMenuItem(
                value: 'revoke',
                child: Text('Revoke Consent'),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  print("Edit selected");
                  break;
                case 'extend':
                  print("Extend selected");
                  break;
                case 'revoke':
                  print("Revoke selected");
                  break;
              }
            },
          ),
        ],
      ),
    );
  }
}
