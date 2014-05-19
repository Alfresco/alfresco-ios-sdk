/*
 ******************************************************************************
 * Copyright (C) 2005-2014 Alfresco Software Limited.
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

/*
 * This category is a swizzled implementation for CMISHttpRequest. Since the
 * Objective-CMIS library should support this behaviour by default, we are not
 * providing a custom network provider. Instead, until this behaviour
 * is added to Objective-CMIS, the Alfresco SDK will swizzle CMISHttpRequest's
 * startRequest: method with it's own implementation.
 *
 * Author: Tauseef Mughal (Alfresco)
 */

#import "CMISHttpRequest.h"

@interface CMISHttpRequest (Swizzled)

@end
