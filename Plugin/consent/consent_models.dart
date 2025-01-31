// ignore_for_file: constant_identifier_names

import 'dart:convert';

class LocalConsentRecord {
  final LocalConsentEntity inboundEntity;
  final LocalConsentEntity outboundEntity;
  final List<LocalConsentItem> consentItems;

  LocalConsentRecord({
    required this.inboundEntity,
    required this.outboundEntity,
    required this.consentItems,
  });

  @override
  String toString() {
    return 'LocalConsentRecord(inboundEntity: $inboundEntity, '
        'outboundEntity: $outboundEntity, '
        'consentItems: $consentItems)';
  }

  Map<String, dynamic> toJson() {
    return {
      'inboundEntity': inboundEntity.toJson(),
      'outboundEntity': outboundEntity.toJson(),
      'consentItems': consentItems.map((item) => item.toJson()).toList(),
    };
  }

  factory LocalConsentRecord.fromGraphQlResponse(dynamic rec) {

    return LocalConsentRecord(
      inboundEntity: LocalConsentEntity.fromGraphQlResponse(rec['inboundEntity'] ?? {}),
      outboundEntity: LocalConsentEntity.fromGraphQlResponse(rec['outboundEntity'] ?? {}),
      consentItems: (rec['consentItems'] ?? [])
          .map((item) => LocalConsentItem.fromGraphQlResponse(item))
          .toList(),
    );
  }
}

class LocalConsentRequest{
  final String inboundEntityId;
  final String outboundEmail;
  final InboundEntityType inboundEntityType;
  final List<LocalConsentItem> consentItems;

  LocalConsentRequest({
    required this.inboundEntityId,
    required this.outboundEmail,
    required this.inboundEntityType,
    required this.consentItems,
  });

   @override
  String toString() {
    return 'LocalConsentRequest(inboundEntityId: $inboundEntityId, '
        'outboundEmail: $outboundEmail, '
        'inboundEntityType: $inboundEntityType, '
        'consentItems: $consentItems)';
  }

  factory LocalConsentRequest.fromGraphQlResponse(dynamic rec) {
    if (rec == null) {
      throw GraphQLResponseException('GraphQL response for LocalConsentRequest is null or malformed');
    }
    return LocalConsentRequest(
      inboundEntityId: rec['inboundEntityId'] ?? '',
      outboundEmail: rec['outboundEmail'] ?? '',
      inboundEntityType: InboundEntityTypeExtension.fromGraphQLString(rec['inboundEntityType']),
      consentItems: (rec['consentItems']?? [])
          .map((item) => LocalConsentItem.fromGraphQlResponse(item))
          .toList(),
    );
  }
}

class LocalConsentEntity {
  final String id;
  //final InboundEntityType type;
  final String email;
  final String displayName;
  final String? legalName;
  final String? partnerId;
  final String? logoUrl;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'legalName': legalName,
      'partnerId': partnerId,
      'logoUrl': logoUrl,
    };
  }

  LocalConsentEntity({
    required this.id,
    //required this.type,
    required this.email,
    required this.displayName,
    this.legalName,
    this.partnerId,
    this.logoUrl,
  });

  @override
  String toString() {
    return 'LocalConsentEntity(id: $id, '
        //'type: $type, '
        'email: $email, '
        'displayName: $displayName, '
        'legalName: $legalName, '
        'partnerId: $partnerId, '
        'logoUrl: $logoUrl)';
  }

  factory LocalConsentEntity.fromGraphQlResponse(dynamic rec) {

    return LocalConsentEntity(
      id: rec['id'],
      //InboundEntityTypeExtension.fromGraphQLString(rec['inboundEntityType']),
      //type: InboundEntityType.USER,
      email: rec['email'],
      displayName: rec['displayName'],
      legalName: rec['legalName'],
      partnerId: rec['partnerId'],
      logoUrl: rec['logoUrl'],
    );
  }

  String getName() {
    return displayName;
  }
}

class LocalConsentItem {
  Map<String, dynamic> toJson() {
    return {
      'dataType': dataType.toString(),
      'status': status.toGraphQLString(),
      'from': from,
      'history': history.map((event) => event.toJson()).toList(),
      'expiry': expiry,
      'termsDocuments': termsDocuments?.toMap(),
    };
  }
  final DataTypeInfo dataType;
  final ConsentItemStatus status;
  final int from;
  final List<ConsentItemEvent> history;
  final int expiry;
  final Document? termsDocuments;

  LocalConsentItem({
    required this.dataType,
    required this.status,
    required this.from,
    required this.history,
    required this.expiry,
    this.termsDocuments
  });

    @override
  String toString() {
    return 'LocalConsentItem(dataType: $dataType, '
        'status: $status, '
        'from: $from, '
        'expiry: $expiry, '
        'history: $history)';
  }

  factory LocalConsentItem.fromGraphQlResponse(Map<String, dynamic> rec) {
    
    return LocalConsentItem(
      dataType: DataTypeInfo.fromGraphQlResponse(rec['dataType']),
      status: ConsentItemStatusExtension.fromString(rec['status']),
      history: (rec['history'] as List<dynamic>?)
          ?.map((item) => ConsentItemEvent.fromGraphQlResponse(item as Map<String, dynamic>))
          .toList() ?? [],
      from: int.parse(rec['from'].toString()),
      expiry: int.parse(rec['expiry'].toString()),
      termsDocuments: rec['termsDocuments'] != null
          ? Document.fromGraphQLResponse(rec['termsDocuments'])
          : null,
    );
  }
}

class DataTypeInfo {
  final String id;
  final String? friendlyName;
  final DataFormat? dataFormat;
  final Map<String, DataFormat>? transmitterDeviceDataFormat;

  DataTypeInfo({
    required this.id,
    this.friendlyName,
    this.dataFormat,
    this.transmitterDeviceDataFormat,
  });

  @override
  String toString() {
    return 'DataTypeInfo(id: $id, friendlyName: $friendlyName, '
        'dataFormat: $dataFormat, '
        'transmitterDeviceDataFormat: $transmitterDeviceDataFormat)';
  }

  factory DataTypeInfo.fromGraphQlResponse(dynamic rec) {
    if (rec == null) {
      throw GraphQLResponseException('GraphQL response for DataTypeInfo is null or malformed');
    }

    // Decode transmitterDeviceDataFormat if it's a string
    Map<String, DataFormat>? transmitterDeviceDataFormat;
    if (rec['transmitterDeviceDataFormat'] is String) {
      try {
        var decoded = jsonDecode(rec['transmitterDeviceDataFormat']);
        // Convert the decoded map to a Map<String, DataFormat>
        transmitterDeviceDataFormat = Map<String, DataFormat>.fromEntries(
          (decoded as Map<String, dynamic>).entries.map(
            (entry) => MapEntry(entry.key, DataFormatExtension.fromString(entry.value)),
          ),
        );
      } catch (e) {
        throw GraphQLResponseException(
            'Failed to decode transmitterDeviceDataFormat: $e');
      }
    } else if (rec['transmitterDeviceDataFormat'] is Map) {
      // If it's already a Map, convert it to Map<String, DataFormat>
      transmitterDeviceDataFormat = Map<String, DataFormat>.fromEntries(
        (rec['transmitterDeviceDataFormat'] as Map<String, dynamic>).entries.map(
          (entry) => MapEntry(entry.key, DataFormatExtension.fromString(entry.value)),
        ),
      );
    }

    return DataTypeInfo(
      id: rec['id'] ?? '',
      friendlyName: rec['friendlyName'] ?? 'Unknown',
      dataFormat: DataFormatExtension.fromString(rec['dataFormat']),
      transmitterDeviceDataFormat: transmitterDeviceDataFormat,
    );
  }
}

enum InboundEntityType { USER, PARTNER }

class InboundEntityTypeExtension {
  static InboundEntityType fromGraphQLString(String? value) {
    switch (value) {
      case 'USER':
        return InboundEntityType.USER;
      case 'PARTNER':
        return InboundEntityType.PARTNER;
      default:
        throw Exception('Unknown InboundEntityType: $value');
    }
  }
}


enum ConsentItemStatus { PENDING, CONFIRMED, EXPIRED, CANCELED_BY_USER, UNKNOWN }

extension ConsentItemStatusExtension on ConsentItemStatus {
  static ConsentItemStatus fromString(String? status) {
    if (status == null) {
      return ConsentItemStatus.UNKNOWN;  // Return default value
    }
    switch (status.toUpperCase()) {
      case 'PENDING':
        return ConsentItemStatus.PENDING;
      case 'CONFIRMED':
        return ConsentItemStatus.CONFIRMED;
      case 'EXPIRED':
        return ConsentItemStatus.EXPIRED;
      case 'CANCELED_BY_USER':
        return ConsentItemStatus.CANCELED_BY_USER;
      default:
        return ConsentItemStatus.UNKNOWN;  // Handle unknown statuses safely
    }
  }

  String toGraphQLString() {
    return toString().split('.').last;  // Convert enum to its string value
  }
}

enum DataFormat { NUMBER, STRING, NUMBERS, STRINGS, MAP }

extension DataFormatExtension on DataFormat {
    static DataFormat fromString(String? format) {
    if (format == null) {
      return DataFormat.STRING; // Return a default value (STRING) if null is passed
    }
    switch (format.trim().toUpperCase()) {
      case 'NUMBER':
        return DataFormat.NUMBER;
      case 'STRING':
        return DataFormat.STRING;
      case 'NUMBERS':
        return DataFormat.NUMBERS;
      case 'STRINGS':
        return DataFormat.STRINGS;
      case 'MAP':
        return DataFormat.MAP;
      default:
        throw GraphQLResponseException('Unknown DataFormat: $format');
    }
  }
}

// Custom exception for GraphQL response errors
class GraphQLResponseException implements Exception {
  final String message;
  GraphQLResponseException(this.message);

  @override
  String toString() => 'GraphQLResponseException: $message';
}

class ConsentItemEvent {
  final int eventTime;
  final ConsentItemStatus newStatus;
  final ConsentItemStatus? oldStatus;
  final String description;

  ConsentItemEvent({
    required this.eventTime,
    required this.newStatus,
    this.oldStatus,
    required this.description,
  });

  @override
  String toString() {
    return 'ConsentItemEvent(eventTime: $eventTime, '
        'newStatus: $newStatus, '
        'oldStatus: $oldStatus, '
        'description: $description)';
  }

  factory ConsentItemEvent.fromGraphQlResponse(Map<String, dynamic> rec) {
    return ConsentItemEvent(
      eventTime: int.parse(rec['eventTime'].toString()),
      newStatus: ConsentItemStatusExtension.fromString(rec['newStatus']),
      oldStatus: rec['oldStatus'] != null
          ? ConsentItemStatusExtension.fromString(rec['oldStatus'])
          : ConsentItemStatus.UNKNOWN,
      description: rec['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventTime': eventTime,
      'newStatus': newStatus.toGraphQLString(),
      'oldStatus': oldStatus?.toGraphQLString(),
      'description': description,
    };
  }
}

class Document {
  final String title;
  final String description;
  final String url;

  // Constructor
  Document({
    required this.title,
    required this.description,
    required this.url,
  });

  // Convert a GraphQL response to a Document object
  factory Document.fromGraphQLResponse(Map<String, dynamic> rec) {
    return Document(
      title: rec['title'] ?? '',
      description: rec['description'] ?? '',
      url: rec['url'] ?? '',
    );
  }

  // Convert the Document object to a map to send as a GraphQL request variable
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'url': url,
    };
  }
}
