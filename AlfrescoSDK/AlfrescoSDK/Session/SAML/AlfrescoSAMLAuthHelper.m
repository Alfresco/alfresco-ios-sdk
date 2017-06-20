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

#import "AlfrescoSAMLAuthHelper.h"
#import "AlfrescoSAMLConstants.h"
#import "AlfrescoConnectionDiagnostic.h"
#import "CMISReachability.h"
#import "AlfrescoDefaultNetworkProvider.h"
#import "AlfrescoErrors.h"
#import "AlfrescoLog.h"

@interface AlfrescoSAMLAuthHelper ()

@property (nonatomic, strong, readwrite) NSURL *baseURL;
@property (nonatomic, strong, readwrite) id<AlfrescoNetworkProvider> networkProvider;

@end

@implementation AlfrescoSAMLAuthHelper

- (instancetype)initWithBaseURL:(NSURL *)baseURL
{
    if (self = [super init])
    {
        self.baseURL = [baseURL URLByAppendingPathComponent:kAlfrescoSAMLRootPath];
    }
    
    return self;
}

- (NSURL *)authenticateURL
{
    return [self.baseURL URLByAppendingPathComponent:kAlfrescoSAMLAuthenticateSufix];
}

- (NSURL *)authenticateResponseURL
{
    return [self.baseURL URLByAppendingPathComponent:kAlfrescoSAMLAuthenticateResponseSufix];
}

- (NSURL *)infoURL
{
    return [self.baseURL URLByAppendingPathComponent:kAlfrescoSAMLEnabledSufix];
}

+ (AlfrescoRequest *)checkIfSAMLIsEnabledForServerWithUrlString:(NSString *)urlString completionBlock:(AlfrescoSAMLAuthCompletionBlock)completionBlock
{
    AlfrescoRequest *request = nil;
    
    AlfrescoConnectionDiagnostic *diagnostic = [[AlfrescoConnectionDiagnostic alloc] initWithEventName:kAlfrescoConfigurationDiagnosticReachabilityEvent];
    [diagnostic notifyEventStart];
    
    CMISReachability *reachability = [CMISReachability networkReachability];
    if (reachability.hasNetworkConnection)
    {
        [diagnostic notifyEventSuccess];
        
        NSURL *baseURL = [NSURL URLWithString:urlString];
        AlfrescoSAMLAuthHelper *helper = [[AlfrescoSAMLAuthHelper alloc] initWithBaseURL:baseURL];
        helper.networkProvider = [[AlfrescoDefaultNetworkProvider alloc] init];
        NSURL *url = [helper infoURL];
        
        [AlfrescoErrors assertArgumentNotNil:url argumentName:@"url"];
        [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

        request = [AlfrescoRequest new];
        
        [helper.networkProvider executeRequestWithURL:url
                                              session:nil
                                      alfrescoRequest:request
                                      completionBlock:^(NSData *data, NSError *error) {
                                          if (error)
                                          {
                                              [diagnostic notifyEventFailureWithError:error];
                                              completionBlock(nil, error);
                                          }
                                          else
                                          {
                                              NSError *parseError = nil;
                                              NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                                              
                                              if (dictionary == nil)
                                              {
                                                  [diagnostic notifyEventFailureWithError:parseError];
                                                  
                                                  AlfrescoLogError(@"Failed to parse saml info response", [parseError localizedDescription]);
                                                  completionBlock(nil, parseError);
                                              }
                                              else
                                              {
                                                  [diagnostic notifyEventSuccess];
                                                  
                                                  AlfrescoSAMLInfo *samlInfo = [[AlfrescoSAMLInfo alloc] initWithDictionary:dictionary];
                                                  AlfrescoSAMLData *samlData = [[AlfrescoSAMLData alloc] initWithSamlInfo:samlInfo samlTicket:nil];
                                                  
                                                  completionBlock(samlData, nil);
                                              }
                                          }
                                      }];
    }
    else
    {
        [diagnostic notifyEventFailureWithError:nil];
        
        NSError *noConnectionError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeNoNetworkConnection];
        
        if (completionBlock != NULL)
        {
            completionBlock(nil, noConnectionError);
        }
    }
    
    return request;
}

@end
