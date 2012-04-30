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
#import "CMISWorkspace.h"

@interface CMISAtomPubBaseService ()
@property (nonatomic, strong, readwrite) NSArray *cmisWorkspaces;
@end

@implementation CMISAtomPubBaseService

@synthesize sessionParameters = _sessionParameters;
@synthesize cmisWorkspaces = _cmisWorkspaces;

- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters andWithCMISWorkspaces:(NSArray *)cmisWorkspaces;
{
    self = [super init];
    if (self)
    {
        _sessionParameters = sessionParameters;
        _cmisWorkspaces = cmisWorkspaces;
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
    [request setUsername:self.sessionParameters.authenticationProvider.username];
    [request setPassword:self.sessionParameters.authenticationProvider.password];
        
    // send the request
    [request startSynchronous];

    NSError *requestError = [request error];
    
    if (!requestError)
    {
        //NSLog(@"response for %@: %@", url, [request responseString]);
        return [request responseData];
    }
    else {

        // set error and return nil
        NSLog(@"Http error : %@", [requestError description]);
        *outError = requestError;
        
        return nil;
    }
}

@end
