//
//  CMISAtomPubBaseService.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 10/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubBaseService.h"
#import "CMISAuthenticationProvider.h"
#import "ASIHTTPRequest.h"

@interface CMISAtomPubBaseService ()
@property (nonatomic, strong, readwrite) CMISSessionParameters *sessionParameters;
@end

@implementation CMISAtomPubBaseService

@synthesize sessionParameters = _sessionParameters;

- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters
{
    if (self = [super init]) 
    {
        self.sessionParameters = sessionParameters;
    }
    
    return self;
}


#pragma mark -
#pragma mark Protected methods

- (NSData *)executeRequest:(NSURL *)url error:(NSError **)outError
{
    // TODO: Replace ASIHTTPRequest with standard NSURLConnection
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    // add authentication to request
    // TODO: deal with authentication providers that require headers or query string params to be added
    [request setUsername:_sessionParameters.authenticationProvider.username];
    [request setPassword:_sessionParameters.authenticationProvider.password];
        
    // send the request
    [request startSynchronous];
    
    NSError *requestError = [request error];
    
    if (!requestError)
    {
        //NSLog(@"response for %@: %@", url, [request responseString]);
        
        // return response data
        return [request responseData];
    }
    else 
    {
        // set error and return nil
        *outError = requestError;
        
        return nil;
    }
}

@end
