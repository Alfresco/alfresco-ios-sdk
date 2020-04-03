/*
 ******************************************************************************
 * Copyright (C) 2005-2017 Alfresco Software Limited.
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

/** AKUserAccount protocol
 
 Author: Tauseef Mughal (Alfresco)
 */

#import <Foundation/Foundation.h>

@class AlfrescoOAuthData;

@protocol AKUserAccount <NSObject>

// This protocol is subject to change
@property (nonatomic, assign) BOOL isOnPremiseAccount;

// User for OnPremise Accounts
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *accountDescription;
@property (nonatomic, strong) NSString *serverAddress;
@property (nonatomic, strong) NSString *serverPort;
@property (nonatomic, strong) NSString *protocol;
@property (nonatomic, strong) NSString *serviceDocument;
@property (nonatomic, strong) NSString *contentAddress;
@property (nonatomic, strong) NSString *realm;
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *redirectURI;

// Used for Cloud Accounts
@property (nonatomic, strong) NSString *selectedNetworkIdentifier;
@property (nonatomic, strong) NSArray *networkIdentifiers;
@property (nonatomic, strong) AlfrescoOAuthData *oAuthData;

// Used for SAML
@property (nonatomic, strong) AlfrescoSAMLData *samlData;

@end
