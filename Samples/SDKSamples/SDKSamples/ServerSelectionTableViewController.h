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

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
#import "AlfrescoOAuthLoginDelegate.h"

#warning ENTER YOUR API AND SECRET KEY

// Enter the api Key and secret key in the #define below
#define APIKEY @"l7xx6f56d3e7e94343afb788f4d6a148e8da"
#define SECRETKEY @"42b22c5c093f4d4eac399364317254fc"
#define REDIRECT @"http://www.alfresco.com/mobile-auth-callback.html"
@interface ServerSelectionTableViewController : BaseTableViewController <AlfrescoOAuthLoginDelegate, UIAlertViewDelegate>

@end
