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
#import "AlfrescoOAuthData.h"
typedef void (^AlfrescoOAuthCompletionBlock)(AlfrescoOAuthData * oauthData, NSError *error);

@interface AlfrescoOAuthWebViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property (nonatomic, strong) UIWebView * webView;

- (id)initWithAPIKey:(NSString *)apiKey secretKey:(NSString *)secretKey redirectURI:(NSString *)redirectURI completionBlock:(AlfrescoOAuthCompletionBlock)completionBlock;
- (id)initWithAPIKey:(NSString *)apiKey secretKey:(NSString *)secretKey redirectURI:(NSString *)redirectURI completionBlock:(AlfrescoOAuthCompletionBlock)completionBlock parameters:(NSDictionary *)parameters;
@end
