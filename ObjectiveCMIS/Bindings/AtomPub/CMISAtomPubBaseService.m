//
//  CMISAtomPubBaseService.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 10/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubBaseService.h"
#import "CMISAtomPubBaseService+Protected.h"
#import "HttpUtil.h"
#import "CMISServiceDocumentParser.h"
#import "CMISConstants.h"
#import "CMISAtomEntryParser.h"
#import "CMISWorkspace.h"
#import "CMISObjectByIdUriBuilder.h"

@interface CMISAtomPubBaseService ()
@property (nonatomic, strong, readwrite) CMISBindingSession *session;
@property (nonatomic, strong, readwrite) NSURL *atomPubUrl;
@end

@implementation CMISAtomPubBaseService

@synthesize session = _session;
@synthesize atomPubUrl = _atomPubUrl;

- (id)initWithBindingSession:(CMISBindingSession *)session
{
    self = [super init];
    if (self)
    {
        self.session = session;
        
        // pull out and cache all the useful objects for this binding
        self.atomPubUrl = [session objectForKey:kCMISBindingSessionKeyAtomPubUrl];
    }
    return self;
}


#pragma mark -
#pragma mark Protected methods

- (NSArray *)retrieveCMISWorkspacesWithError:(NSError * *)error
{
    if ([self.session objectForKey:kCMISSessionKeyWorkspaces] == nil)
    {
        NSData *data = [HttpUtil invokeGET:self.atomPubUrl withSession:self.session error:error];

        // Parse the cmis service document
        if (data != nil)
        {
            CMISServiceDocumentParser *parser = [[CMISServiceDocumentParser alloc] initWithData:data];
            if ([parser parseAndReturnError:error])
            {
                [self.session setObject:parser.workspaces forKey:kCMISSessionKeyWorkspaces];
            } 
            else
            {
                log(@"Error while parsing service document: %@", [*error description]);
            }
        }
    }

    return (NSArray *) [self.session objectForKey:kCMISSessionKeyWorkspaces];
}

- (CMISObjectData *)retrieveObjectInternal:(NSString *)objectId error:(NSError **)error
{
    // build URL to get object data
    NSArray *cmisWorkSpaces = [self retrieveCMISWorkspacesWithError:error];
    
    // TODO: discuss what to do with multiple workspaces. Is this even possible?
    // TODO: Retrieve the URI templates from the CMISBindingSession (once they've been stored!)
    NSString *urlTemplate = [(CMISWorkspace *)[cmisWorkSpaces objectAtIndex:0] objectByIdUriTemplate];
    CMISObjectByIdUriBuilder *objectByIdUriBuilder = [[CMISObjectByIdUriBuilder alloc] initWithTemplateUrl:urlTemplate];
    objectByIdUriBuilder.objectId = objectId;
    NSURL *objectIdUrl = [objectByIdUriBuilder buildUrl];
    
    // Execute actual call
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

- (NSData *)executeRequest:(NSURL *)url error:(NSError **)error
{
    return [HttpUtil invokeGET:url withSession:self.session error:error];
}

@end
