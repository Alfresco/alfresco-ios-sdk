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
#import "CMISObjectByIdUriBuilder.h"
#import "CMISAtomEntryParser.h"

@interface CMISAtomPubBaseService ()
@property (nonatomic, strong, readwrite) NSArray *cmisWorkspaces;
@end

@implementation CMISAtomPubBaseService

@synthesize sessionParameters = _sessionParameters;
@synthesize cmisWorkspaces = _cmisWorkspaces;

- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters andWithCMISWorkspaces:(NSArray *)cmisWorkspaces
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

- (CMISObjectData *)retrieveObject:(NSString *)objectId error:(NSError **)error
{
    // build URL to get object data
    NSString *urlTemplate = [(CMISWorkspace *)[self.cmisWorkspaces objectAtIndex:0] objectByIdUriTemplate]; // TODO: discuss what to do with multiple workspaces. Is this even possible?
    CMISObjectByIdUriBuilder *objectByIdUriBuilder = [[CMISObjectByIdUriBuilder alloc] initWithTemplateUrl:urlTemplate];
    objectByIdUriBuilder.objectId = objectId;
    NSURL *objectIdUrl = [objectByIdUriBuilder buildUrl];

    // Execute actual call
    log(@"GET: %@", [objectIdUrl absoluteString]);

    CMISObjectData *objectData = nil;
    NSData *data = [self executeRequest:objectIdUrl error:error];
    if (data != nil)
    {
        CMISAtomEntryParser *parser = [[CMISAtomEntryParser alloc] initWithData:data];
        if ([parser parseAndReturnError:error])
        {
            objectData = parser.objectData;
        }
    }

    return objectData;
}

@end
