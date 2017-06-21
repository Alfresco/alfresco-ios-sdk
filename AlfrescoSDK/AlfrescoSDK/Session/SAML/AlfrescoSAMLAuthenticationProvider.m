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

#import "AlfrescoSAMLAuthenticationProvider.h"
#import "CMISBase64Encoder.h"

@interface AlfrescoSAMLAuthenticationProvider ()

@property (nonatomic, strong) AlfrescoSAMLData *samlData;
@property (nonatomic, strong, readwrite) NSMutableDictionary *httpHeaders;

@end

@implementation AlfrescoSAMLAuthenticationProvider

- (instancetype)initWithSamlData:(AlfrescoSAMLData *)samlData
{
    if (self = [super init])
    {
        self.samlData = samlData;
    }
    
    return self;
}

- (instancetype)initWithSamlInfo:(AlfrescoSAMLInfo *)samlInfo samlTicket:(AlfrescoSAMLTicket *)samlTicket
{
    if (self = [super init])
    {
        self.samlData = [[AlfrescoSAMLData alloc] initWithSamlInfo:samlInfo samlTicket:samlTicket];
    }
    
    return self;
}

#pragma mark AlfrescoAuthenticationProvider Delegate methods

- (NSDictionary *)willApplyHTTPHeadersForSession:(id<AlfrescoSession>)session;
{
    if (self.httpHeaders == nil)
    {
        self.httpHeaders = [NSMutableDictionary dictionaryWithCapacity:1];
        
        NSString *loginString = [self.samlData getTicket];
        NSString *encodedLoginData = [CMISBase64Encoder stringByEncodingText:[loginString dataUsingEncoding:NSUTF8StringEncoding]];
        NSString *authHeader = [NSString stringWithFormat:@"Basic %@", encodedLoginData];
        
        [self.httpHeaders setValue:authHeader forKey:@"Authorization"];
    }
    
    return self.httpHeaders;
}

- (NSDictionary *)httpHeadersToApply
{
    return [self willApplyHTTPHeadersForSession:nil];
}

@end
