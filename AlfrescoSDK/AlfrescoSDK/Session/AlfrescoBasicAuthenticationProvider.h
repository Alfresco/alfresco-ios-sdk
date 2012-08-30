/*******************************************************************************
 * Copyright (C) 2005-2012 Alfresco Software Limited.
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

#import "AlfrescoAuthenticationProvider.h"

/** The AlfrescoBasicAuthenticationProvider manages the authentication credentials for a session.
 
 Author: Tijs Rademakers (Alfresco)
 */

@interface AlfrescoBasicAuthenticationProvider : NSObject <AlfrescoAuthenticationProvider>

/**---------------------------------------------------------------------------------------
 * @name Creates an authentication provider with a plain username and password.
 *  ---------------------------------------------------------------------------------------
 */

/** Creates an instance of an AlfrescoBasicAuthenticationProvider with a username and password.
 
 @param userIdentifier The user identifier/name registered on the repository.
 @param password The password.
 @return Authentication provider instance.
 */
- (id)initWithUsername:(NSString *)username andPassword:(NSString *)password;

@end
