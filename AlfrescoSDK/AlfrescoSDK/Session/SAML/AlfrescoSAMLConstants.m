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

#import "AlfrescoSAMLConstants.h"

// Root url path
NSString * const kAlfrescoSAMLRootPath = @"service/saml/-default-/rest-api";

// Url path to request authentication
NSString * const kAlfrescoSAMLAuthenticateSufix = @"authenticate";

// Url path to receive authentication token
NSString * const kAlfrescoSAMLAuthenticateResponseSufix = @"authenticate-response?format=json";

// Url path to check if SAML is enabled
NSString * const kAlfrescoSAMLEnabledSufix =  @"enabled";
