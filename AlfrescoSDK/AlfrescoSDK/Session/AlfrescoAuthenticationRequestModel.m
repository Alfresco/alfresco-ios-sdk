/*
******************************************************************************
* Copyright (C) 2005-2020 Alfresco Software Limited.
*
* This file is part of the Alfresco Mobile SDK.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*  http://www.apache.org/licenses/LICENSE-2.0
*
*  Unless required by applicable law or agreed to in writing, software
*  distributed under the License is distributed on an "AS IS" BASIS,
*  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*  See the License for the specific language governing permissions and
*  limitations under the License.
*****************************************************************************
*/

#import "AlfrescoAuthenticationRequestModel.h"
#import "AlfrescoSAMLAuthenticationProvider.h"
#import "AlfrescoBasicAuthenticationProvider.h"
#import "CMISSessionParameters.h"
#import "AlfrescoSAMLData.h"
#import "AlfrescoOAuthData.h"
#import "AlfrescoSAMLStandardUntrustedSSLAuthenticationProvider.h"
#import "CMISStandardUntrustedSSLAuthenticationProvider.h"
#import "CMISStandardAuthenticationProvider.h"


typedef NS_ENUM(NSUInteger, AuthenticationRequestType) {
    AuthenticationRequestTypeBasicAuth,
    AuthenticationRequestTypeSAML,
    AuthenticationRequestTypeAIMS
};

@interface AlfrescoAuthenticationRequestModel ()

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) AlfrescoSAMLData *samlData;
@property (nonatomic, strong) AlfrescoOAuthData *oauthData;

@property (nonatomic, assign) AuthenticationRequestType authenticationRequestType;

@end

@implementation AlfrescoAuthenticationRequestModel

- (instancetype)initWithUsername:(NSString *)username
                        password:(NSString *)password
{
    self = [super init];
    if (self)
    {
        _username = username;
        _password = password;
        _authenticationRequestType = AuthenticationRequestTypeBasicAuth;
    }
    
    return self;
}

- (instancetype)initWithSAMLData:(AlfrescoSAMLData *)samlData
{
    self = [super init];
    if (self)
    {
        _samlData = samlData;
        _authenticationRequestType = AuthenticationRequestTypeSAML;
    }
    
    return self;
}

- (instancetype)initWithOAuthData:(AlfrescoOAuthData *)oAuthData
{
    self = [super init];
    if (self)
    {
        _oauthData = oAuthData;
        _authenticationRequestType = AuthenticationRequestTypeAIMS;
    }
    
    return self;
}

- (id<AlfrescoAuthenticationProvider>)authenticationProvider
{
    id<AlfrescoAuthenticationProvider> tempAuthProvider = nil;
    
    switch (self.authenticationRequestType) {
        case AuthenticationRequestTypeBasicAuth:
        {
            tempAuthProvider = [[AlfrescoBasicAuthenticationProvider alloc] initWithUsername:self.username
                                                                                 andPassword:self.password];
        }
            break;
            
        case AuthenticationRequestTypeSAML:
        {
            tempAuthProvider = [[AlfrescoSAMLAuthenticationProvider alloc] initWithSamlData:self.samlData];
        }
            break;
            
        case AuthenticationRequestTypeAIMS:
        {
            
        }
            break;
            
        default:
            break;
    }
    
    return tempAuthProvider;
}

- (CMISStandardAuthenticationProvider *)sslAuthenticationProvider;
{
    id<CMISAuthenticationProvider> authenticationProvider = nil;
    
    switch (self.authenticationRequestType) {
        case AuthenticationRequestTypeBasicAuth:
        {
            authenticationProvider = [[CMISStandardAuthenticationProvider alloc] initWithUsername:self.username
                                                                                         password:self.password];
        }
            break;
            
        case AuthenticationRequestTypeSAML:
        {
            authenticationProvider = [[AlfrescoSAMLAuthenticationProvider alloc] initWithSamlData:self.samlData];
        }
            break;
            
        case AuthenticationRequestTypeAIMS:
        {
            
        }
            break;
            
        default:
            break;
    }
    
    return authenticationProvider;
}

- (CMISStandardAuthenticationProvider *)untrustedSSLAuthenticationProvider;
{
    id<CMISAuthenticationProvider> authenticationProvider = nil;
    
    switch (self.authenticationRequestType) {
        case AuthenticationRequestTypeBasicAuth:
        {
            authenticationProvider = [[CMISStandardUntrustedSSLAuthenticationProvider alloc] initWithUsername:self.username
                                                                                                     password:self.password];
        }
            break;
            
        case AuthenticationRequestTypeSAML:
        {
            authenticationProvider = [[AlfrescoSAMLStandardUntrustedSSLAuthenticationProvider alloc] initWithSamlData:self.samlData];
        }
            break;
            
        case AuthenticationRequestTypeAIMS:
        {
            
        }
            break;
            
        default:
            break;
    }
    
    return authenticationProvider;
}

- (void)updateCMISSessionParametersForAuthenticationType:(CMISSessionParameters *)cmisSessionParams
{
    switch (self.authenticationRequestType) {
        case AuthenticationRequestTypeBasicAuth:
        {
            cmisSessionParams.username = self.username;
        }
            break;
            
        case AuthenticationRequestTypeSAML:
        {
            cmisSessionParams.username = [self.samlData getUserID];
            cmisSessionParams.authenticationProvider = [[AlfrescoSAMLAuthenticationProvider alloc] initWithSamlData:self.samlData];
        }
            break;
            
        case AuthenticationRequestTypeAIMS:
        {
        }
            
        default:
            break;
    }
}

@end
