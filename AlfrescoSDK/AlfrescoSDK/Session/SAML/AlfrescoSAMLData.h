/*******************************************************************************
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
 ******************************************************************************/

#import <Foundation/Foundation.h>
#import "AlfrescoSAMLInfo.h"
#import "AlfrescoSAMLTicket.h"

@interface AlfrescoSAMLData : NSObject <NSCoding>

@property (nonatomic, strong) AlfrescoSAMLInfo *samlInfo;
@property (nonatomic, strong) AlfrescoSAMLTicket *samlTicket;

@property (nonatomic, assign, readonly, getter=isSamlEnabled) BOOL samlEnabled;
@property (nonatomic, assign, readonly, getter=isSamlEnforced) BOOL samlEnforced;
@property (nonatomic, strong, readonly, getter=getIdpDescription) NSString *idpDescription;
@property (nonatomic, strong, readonly, getter=getTenantDomain) NSString *tenantDomain;
@property (nonatomic, strong, readonly, getter=getTicket) NSString *ticket;
@property (nonatomic, strong, readonly, getter=getUserID) NSString *userID;

- (instancetype)initWithSamlInfo:(AlfrescoSAMLInfo *)samlInfo samlTicket:(AlfrescoSAMLTicket *)samlTicket;

@end
