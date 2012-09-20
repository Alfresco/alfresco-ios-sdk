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

#import "AlfrescoHTTPUtils.h"

@implementation AlfrescoHTTPUtils

+ (NSData *)executeRequest:(NSString *)api
           baseUrlAsString:(NSString *)baseUrl
    authenticationProvider:(id<AlfrescoAuthenticationProvider>)authenticationProvider
                     error:(NSError **)outError
{
    return [AlfrescoHTTPUtils executeRequest:api baseUrlAsString:baseUrl authenticationProvider:authenticationProvider data:nil httpMethod:@"GET" error:outError];
}

+ (NSData *)executeRequest:(NSString *)api
           baseUrlAsString:(NSString *)baseUrl
    authenticationProvider:(id<AlfrescoAuthenticationProvider>)authenticationProvider
                      data:(NSData *)data
                httpMethod:(NSString *)httpMethod
                     error:(NSError **)outError
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", baseUrl, api]];
    return [AlfrescoHTTPUtils executeRequestWithURL:url authenticationProvider:authenticationProvider data:data httpMethod:httpMethod error:outError];
    
}

+ (NSData *)executeRequestWithURL:(NSURL *)url
           authenticationProvider:(id<AlfrescoAuthenticationProvider>)authenticationProvider
                             data:(NSData *)data
                       httpMethod:(NSString *)httpMethod
                            error:(NSError **)outError
{
    NSLog(@"AlfrescoHTTPUtils %@: %@", httpMethod, [url absoluteString]);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url
                                                           cachePolicy: NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval: 10];
    NSDictionary *httpHeaders = [authenticationProvider willApplyHTTPHeadersForSession:nil];
    NSEnumerator *headerEnumerator = [httpHeaders keyEnumerator];
    for (NSString *key in headerEnumerator)
    {
        NSLog(@"executeRequestWithURL we are applying the header %@ to key %@", [httpHeaders valueForKey:key], key);
        [request addValue:[httpHeaders valueForKey:key] forHTTPHeaderField:key];
    }
    
    // perform the reqeust
    NSError *error;
    NSHTTPURLResponse *response;
    
    [request setHTTPMethod:httpMethod];
    if(nil != data)
    {
        [request setHTTPBody:data];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
    NSLog(@"response status %i", [response statusCode]);
    NSLog(@"response %@", [[NSMutableString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
    
    if (response.statusCode < 200 || response.statusCode > 299)
    {
        *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeHTTPResponse];
        return nil;
    }
    
    return responseData;    
}

+ (NSData *)executeRequestWithURL:(NSURL *)url
                             data:(NSData *)data
                       httpMethod:(NSString *)httpMethod
                            error:(NSError **)outError
{
    NSLog(@"AlfrescoHTTPUtils %@: %@", httpMethod, [url absoluteString]);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url
                                                           cachePolicy: NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval: 10];    
    // perform the reqeust
    NSError *error;
    NSHTTPURLResponse *response;
    
    [request setHTTPMethod:httpMethod];
    if (nil != data)
    {
        [request setHTTPBody:data];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    *outError = error;
    
    NSLog(@"response status %i", [response statusCode]);
    NSLog(@"response %@", [[NSMutableString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
    
    if (response.statusCode < 200 || response.statusCode > 299)
    {
        *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeHTTPResponse];
    }
    
    return responseData;
}


@end
