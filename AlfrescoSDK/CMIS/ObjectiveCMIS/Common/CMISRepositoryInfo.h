/*
  Licensed to the Apache Software Foundation (ASF) under one
  or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
 */

#import <Foundation/Foundation.h>
#import "CMISExtensionData.h"
#import "CMISRepositoryCapabilities.h"

@interface CMISRepositoryInfo : CMISExtensionData

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *rootFolderId;

@property (nonatomic, strong) NSString *cmisVersionSupported;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSString *productVersion;
@property (nonatomic, strong) NSString *vendorName;
@property (nonatomic, strong) NSString *thinClientUri;
@property (nonatomic, strong) NSString *latestChangeLogToken;

/**
 * Returns principal ID for an anonymous user (any authenticated user). This
 * principal ID is supposed to be used in an Ace.
 *
 * @return the principal ID for an anonymous user or {@code null} if the
 *         repository does not support anonymous users
 *
 * @cmis 1.0
 */
@property (nonatomic, strong) NSString *principalIdAnonymous;

/**
 * Returns principal ID for unauthenticated user (guest user). This
 * principal ID is supposed to be used in an Ace.
 *
 * @return the principal ID for unauthenticated user or {@code null} if the
 *         repository does not support unauthenticated users
 *
 * @cmis 1.0
 */
@property (nonatomic, strong) NSString *principalIdAnyone;

/**
 * Returns Repository Capabilities Object
 *
 * @return Repository Capabilities
 */
@property (nonatomic, strong) CMISRepositoryCapabilities *repositoryCapabilities;

@end
