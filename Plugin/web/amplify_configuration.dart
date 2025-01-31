const amplifyConfig = {
    "UserAgent": "aws-amplify-cli/2.0",
    "Version": "1.0",
    "api": {
        "plugins": {
            "awsAPIPlugin": {
                "GS-1-CB-ca-ApiStack-MainApi": {
                    "endpointType": "GraphQL",
                    "endpoint": "https://osc7ewiaavduba6crgt57a46e4.appsync-api.eu-central-1.amazonaws.com/graphql",
                    "region": "eu-central-1",
                    "authorizationType": "AMAZON_COGNITO_USER_POOLS"
                }
            }
        }
    },
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "UserAgent": "aws-amplify-cli/0.1.0",
                "Version": "0.1.0",
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "eu-central-1_1uvKErj0l",
                        "AppClientId": "3bf1cat1uusll5tg3klq18bkhp",
                        "Region": "eu-central-1"
                    }
                },
                "Auth": {
                    "Default": {
                        "OAuth": {
                            "WebDomain": "sen-gs-1-cb-ca-staging.auth.eu-central-1.amazoncognito.com",
                            "AppClientId": "3bf1cat1uusll5tg3klq18bkhp",
                            "SignInRedirectURI": "ca://callback/",
                            "SignOutRedirectURI": "ca://signout/",
                            "Scopes": [
                                "email",
                                "openid",
                                "profile",
                                "aws.cognito.signin.user.admin"
                            ]
                        },
                        "authenticationFlowType": "USER_SRP_AUTH",
                        "socialProviders": [],
                        "usernameAttributes": [],
                        "signupAttributes": [
                            "EMAIL"
                        ],
                        "passwordProtectionSettings": {
                            "passwordPolicyMinLength": 8,
                            "passwordPolicyCharacters": []
                        },
                        "mfaConfiguration": "OFF",
                        "mfaTypes": [],
                        "verificationMechanisms": [
                            "EMAIL"
                        ]
                    }
                }
            }
        }
    }
};
