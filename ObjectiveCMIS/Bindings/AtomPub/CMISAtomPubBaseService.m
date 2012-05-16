//
//  CMISAtomPubBaseService.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 10/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubBaseService.h"
#import "CMISAtomPubBaseService+Protected.h"
#import "CMISHttpUtil.h"
#import "CMISServiceDocumentParser.h"
#import "CMISConstants.h"
#import "CMISAtomEntryParser.h"
#import "CMISWorkspace.h"
#import "CMISObjectByIdUriBuilder.h"
#import "CMISErrors.h"

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

- (id)retrieveFromCache:(NSString *)cacheKey error:(NSError * *)error
{
    id object = [self.session objectForKey:cacheKey];

    if (!object)
    {
         // if object is nil, first populate cache
        [self fetchRepositoryInfoAndReturnError:error];
        object = [self.session objectForKey:cacheKey];
    }

    if (!object && !*error)
    {
        // TODO: proper error initialisation
        *error = [[NSError alloc] init];
        log(@"Could not get object from cache with key '%@'", cacheKey);
    }

    return object;
}

- (void)fetchRepositoryInfoAndReturnError:(NSError * *)error
{
    NSArray *cmisWorkSpaces = [self retrieveCMISWorkspacesAndReturnError:error];

    if (!*error)
    {
        BOOL repositoryFound = NO;
        uint index = 0;
        while (!repositoryFound && index < cmisWorkSpaces.count)
        {
            CMISWorkspace *workspace = [cmisWorkSpaces objectAtIndex:index];
            if ([workspace.repositoryInfo.identifier isEqualToString:self.session.repositoryId])
            {
                repositoryFound = YES;

                CMISObjectByIdUriBuilder *objectByIdUriBuilder = [[CMISObjectByIdUriBuilder alloc] initWithTemplateUrl:workspace.objectByIdUriTemplate];
                [self.session setObject:objectByIdUriBuilder forKey:kCMISBindingSessionKeyObjectByIdUriBuilder];
            }
            else {
                index++;
           }
        }

        if (!repositoryFound)
        {
            log(@"No matching repository found for repository id %@", self.session.repositoryId);
            // TODO: populate error properly
            NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
            [errorInfo setObject:kCMISObjectNotFoundErrorDescription forKey:NSLocalizedDescriptionKey];
            NSString *detailedDescription = [NSString stringWithFormat:@"No matching repository found for repository id %@", self.session.repositoryId];
            [errorInfo setObject:detailedDescription forKey:NSLocalizedFailureReasonErrorKey];
            *error = [NSError errorWithDomain:kCMISErrorDomainName code:kCMISObjectNotFoundError userInfo:errorInfo];
        }
    }
}

- (NSArray *)retrieveCMISWorkspacesAndReturnError:(NSError * *)error
{
    if ([self.session objectForKey:kCMISSessionKeyWorkspaces] == nil)
    {
        NSData *data = [HttpUtil invokeGETSynchronous:self.atomPubUrl withSession:self.session error:error];
        // Parse the cmis service document
        if (data != nil && (!error || error == NULL || *error == nil))
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
    CMISObjectByIdUriBuilder *objectByIdUriBuilder = [self retrieveFromCache:kCMISBindingSessionKeyObjectByIdUriBuilder error:error];
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
    return [HttpUtil invokeGETSynchronous:url withSession:self.session error:error];
}

@end
