const String addConsentRequestMutation = '''
mutation AddConsentRequest(\$input: AddConsentRequestInput!) {
  addConsentRequest(input: \$input) {
    inboundEntityId
    outboundEmail
    inboundEntityType
    requestedItems {
      dataType {
        id
        friendlyName
        dataFormat
        transmitterDeviceDataFormat
      }
      status
      from
      history {
        eventTime
        newStatus
        oldStatus
        description
      }
      expiry
      termsDocuments {
        title
        description
        url
      }
    }
  }
}
''';

// Query to fetch inbound consent records
const String listInboundConsentQuery = '''
  query ListInboundConsent(\$input: ListInboundConsentInput) {
    listInboundConsent(input: \$input) {
      outboundEntity {
        id
        email
        displayName
        legalName
        partnerId
        logoUrl
      }
      inboundEntity {
        id
        email
        displayName
        legalName
        partnerId
        logoUrl
      }
      consentItems {
        dataType {
          id
          friendlyName
          dataFormat
          transmitterDeviceDataFormat
        }
        status
        history {
          eventTime
          newStatus
          oldStatus
          description
        }
        from
        expiry
        termsDocuments {
          title
          description
          url
        }
      }
    }
  }
''';

// Query to fetch outbound consent records
const String listOutboundConsentQuery = '''
  query ListOutboundConsent(\$input: ListOutboundConsentInput) {
    listOutboundConsent(input: \$input) {
      outboundEntity {
        id
        email
        displayName
        legalName
        partnerId
        logoUrl
      }
      inboundEntity {
        id
        email
        displayName
        legalName
        partnerId
        logoUrl
      }
      consentItems {
        dataType {
          id
          friendlyName
          dataFormat
          transmitterDeviceDataFormat
        }
        status
        history {
          eventTime
          newStatus
          oldStatus
          description
        }
        from
        expiry
        termsDocuments {
          title
          description
          url
        }
      }
    }
  }
''';

const String confirmOrCreateConsentMutation = '''
mutation ConfirmOrCreateConsent(\$input: ConfirmOrCreateConsentInput) {
  confirmOrCreateConsent(input: \$input) {
    outboundEntity {
        id
        email
        displayName
        legalName
        partnerId
        logoUrl
    }
    inboundEntity {
        id
        email
        displayName
        legalName
        partnerId
        logoUrl
    }
    consentItems {
      dataType {
        id
        friendlyName
        dataFormat
        transmitterDeviceDataFormat
      }
      status
      from
      history {
        eventTime
        newStatus
        oldStatus
        description
      }
      expiry
      termsDocuments {
        title
        description
        url
      }
    }
  }
}
''';

const String revokeConsentMutation = '''
mutation RevokeConsent(\$input: RevokeConsentInput!) {
  revokeConsent(input: \$input) {
    outboundEntity {
        id
        email
        displayName
        legalName
        partnerId
        logoUrl
    }
    inboundEntity {
        id
        email
        displayName
        legalName
        partnerId
        logoUrl
    }
    consentItems {
      dataType {
        id
        friendlyName
        dataFormat
        transmitterDeviceDataFormat
      }
      status
      from
      history {
        eventTime
        newStatus
        oldStatus
        description
      }
      expiry
      termsDocuments {
        title
        description
        url
      }
    }
  }
}
''';

const String fetchUserInfoQuery = '''
query fetchUserInfo {
  fetchUserInfo {
    __typename
    id
    email
    displayName
    custom:partner_id
  }
}
''';
