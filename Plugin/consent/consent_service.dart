// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/user.dart';
import 'package:sen_gs_1_ca_connector_plugin/consent/graph_queries.dart';
import 'package:sen_gs_1_ca_connector_plugin/consent/consent_models.dart';

class ConsentService {
  late final User? user;

  Future<void> addConsentRequest(LocalConsentRequest consentRequest) async {
    try {
      // Prepare the payload (GraphQL mutation variables)
      final variables = {
        'input': {
          'userEmail': consentRequest
              .outboundEmail, // Ensure `outboundEmail` is passed correctly
          'dataTypeIds': consentRequest.consentItems
              .map((item) => item.dataType.id)
              .toList(),
          'expiry': consentRequest.consentItems.isNotEmpty
              ? consentRequest.consentItems.first.expiry // First item's expiry
              : null,
          'message': consentRequest.consentItems
              .map((item) => item.history.first.description)
              .toList(),
        },
      };

      print('GraphQL Input Variables: $variables'); // Debug output

      // Send the mutation request
      final response = await Amplify.API
          .mutate(
            request: GraphQLRequest<String>(
              document: addConsentRequestMutation,
              variables: variables,
            ),
          )
          .response;

      // Check for GraphQL errors
      if (response.errors.isNotEmpty) {
        throw Exception(
          'GraphQL Errors: ${response.errors.map((e) => e.message).join(", ")}',
        );
      }

      print('Consent request added successfully: ${response.data}');
    } catch (e) {
      print('Error adding consent request: $e');
      throw Exception('Failed to add consent request: $e');
    }
  }

  static Future<List<LocalConsentRecord>> fetchConsentRecord(
      String userId, String entityType) async {
    // Fetch inbound consent records
    final inboundConsents = await fetchConsentData(listInboundConsentQuery, {
      'input': {
        'includeInvalid': false,
        'asEntity': entityType,
      },
    });

    // Fetch outbound consent records
    final outboundConsents = await fetchConsentData(listOutboundConsentQuery, {
      'input': {
        'entityType': entityType,
        'includeInvalid': false,
      },
    });

    // Combine both inbound and outbound into a single list of LocalConsentRecord
    final List<LocalConsentRecord> allConsents = [
      ...inboundConsents.map<LocalConsentRecord>((record) => LocalConsentRecord(
            inboundEntity: record.inboundEntity,
            outboundEntity: record.outboundEntity,
            consentItems: record.consentItems,
          )),
      ...outboundConsents
          .map<LocalConsentRecord>((record) => LocalConsentRecord(
                inboundEntity: record.inboundEntity,
                outboundEntity: record.outboundEntity,
                consentItems: record.consentItems,
              )),
    ];
    return allConsents;
  }

  static Future<List<LocalConsentRecord>> fetchConsentData(
      String query, Map<String, dynamic> variables) async {
    final request =
        GraphQLRequest<String>(document: query, variables: variables);
    final response = await Amplify.API.query(request: request).response;

    final responseData =
        response.data != null ? jsonDecode(response.data!) : null;

    // Extract lists for inbound and outbound consent
    final inboundConsentList = responseData?['listInboundConsent'] ?? [];
    final outboundConsentList = responseData?['listOutboundConsent'] ?? [];

    // Function to map a consent data item to LocalConsentRecord
    List<LocalConsentRecord> mapConsentList(List<dynamic> consentList) {
      return consentList
          .where((consentData) => consentData != null)
          .map<LocalConsentRecord>((consentData) {
        final inboundEntityData = consentData['inboundEntity'];
        final outboundEntityData = consentData['outboundEntity'];
        final consentItemsData = consentData['consentItems'];

        // Map outboundEntity and inboundEntity to ConsentEntity objects
        final outboundEntity =
            LocalConsentEntity.fromGraphQlResponse(outboundEntityData);
        final inboundEntity =
            LocalConsentEntity.fromGraphQlResponse(inboundEntityData);

        // Map consentItemsData to LocalConsentItem objects
        final consentItems = (consentItemsData as List<dynamic>).map((item) {
          return LocalConsentItem.fromGraphQlResponse(
              item as Map<String, dynamic>);
        }).toList();

        return LocalConsentRecord(
          inboundEntity: inboundEntity,
          outboundEntity: outboundEntity,
          consentItems: consentItems,
        );
      }).toList();
    }

    // Map both inbound and outbound lists
    final inboundRecords = mapConsentList(inboundConsentList);
    final outboundRecords = mapConsentList(outboundConsentList);

    return [...inboundRecords, ...outboundRecords];
  }

  static Future<void> printLoggedInUser() async {
    // Fetch the currently logged-in user
    final user = await Amplify.Auth.getCurrentUser();

    // Print user details
    print('User ID: ${user.userId}');
    print('Username: ${user.username}');
  }

  // confirm consent
  Future<void> confirmConsentRequest(LocalConsentRecord consentRecord) async {
    final variables = {
      'input': {
        'inboundEntityId': consentRecord.inboundEntity.id,
        'dataTypeIds':
            consentRecord.consentItems.map((item) => item.dataType.id).toList(),
        'inboundEntityType': "USER",
        'expiry': consentRecord.consentItems.isNotEmpty
            ? consentRecord.consentItems.first.expiry
            : null,
        'nickname': consentRecord.outboundEntity.displayName,
        'termsDocuments': consentRecord.consentItems
            .map((item) => item.termsDocuments)
            .toList(),
      },
    };

    print('GraphQL Input Variables: $variables'); // Debug output

    // Send the mutation request
    final response = await Amplify.API
        .mutate(
          request: GraphQLRequest<String>(
            document: confirmOrCreateConsentMutation,
            variables: variables,
          ),
        )
        .response;

    print('Consent request confirmed successfully: ${response.data}');
  }

  Future<void> revokeConsent(String inboundEntityId, List<String> dataTypeIds, {String? reason}) async {
  try {
    // Prepare the variables for the GraphQL mutation
    final variables = {
      'input': {
        'inboundEntityId': inboundEntityId,
        'dataTypeIds': dataTypeIds,
        'reason': reason,
      },
    };

    print('GraphQL Input Variables for Revoke: $variables'); // Debug output

    // Send the mutation request
    final response = await Amplify.API
        .mutate(
          request: GraphQLRequest<String>(
            document: revokeConsentMutation,
            variables: variables,
          ),
        )
        .response;

    // Check for errors in the response
    if (response.errors.isNotEmpty) {
      throw Exception(
        'GraphQL Errors: ${response.errors.map((e) => e.message).join(", ")}',
      );
    }

    // Debug output for successful revocation
    print('Consent revoked successfully: ${response.data}');
  } catch (e) {
    print('Error revoking consent: $e');
    throw Exception('Failed to revoke consent: $e');
  }
}

}
