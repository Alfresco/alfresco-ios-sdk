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
#import "CMISObjectByPathUriBuilder.h"

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

                // Cache collections
               [self.session setObject:[workspace collectionHrefForCollectionType:kCMISAtomCollectionQuery] forKey:kCMISBindingSessionKeyQueryCollection];


                // Cache uri's and uri templates
                CMISObjectByIdUriBuilder *objectByIdUriBuilder = [[CMISObjectByIdUriBuilder alloc] initWithTemplateUrl:workspace.objectByIdUriTemplate];
                [self.session setObject:objectByIdUriBuilder forKey:kCMISBindingSessionKeyObjectByIdUriBuilder];

                CMISObjectByPathUriBuilder *objectByPathUriBuilder = [[CMISObjectByPathUriBuilder alloc] initWithTemplateUrl:workspace.objectByPathUriTemplate];
                [self.session setObject:objectByPathUriBuilder forKey:kCMISBindingSessionKeyObjectByPathUriBuilder];

                [self.session setObject:workspace.queryUriTemplate forKey:kCMISBindingSessionKeyQueryUri];
            }
            else {
                index++;
           }
        }

        if (!repositoryFound)
        {
            log(@"No matching repository found for repository id %@", self.session.repositoryId);
            // TODO: populate error properly
            *error = [[NSError alloc] init];
        }
    }
}

- (NSArray *)retrieveCMISWorkspacesAndReturnError:(NSError * *)error
{
    if ([self.session objectForKey:kCMISSessionKeyWorkspaces] == nil)
    {
        NSData *data = [HttpUtil invokeGETSynchronous:self.atomPubUrl withSession:self.session error:error].data;

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
    CMISObjectByIdUriBuilder *objectByIdUriBuilder = [self retrieveFromCache:kCMISBindingSessionKeyObjectByIdUriBuilder error:error];
    objectByIdUriBuilder.objectId = objectId;
    NSURL *objectIdUrl = [objectByIdUriBuilder buildUrl];
    
    // Execute actual call
    CMISObjectData *objectData = nil;
    HTTPResponse *response = [HttpUtil invokeGETSynchronous:objectIdUrl withSession:self.session error:error];

    if (response.statusCode == 200 && response.data != nil)
    {
        CMISAtomEntryParser *parser = [[CMISAtomEntryParser alloc] initWithData:response.data];
        if ([parser parseAndReturnError:error])
        {
            objectData = parser.objectData;
            return objectData;
        }
    }
    
    return nil;
}

- (CMISObjectData *)retrieveObjectByPathInternal:(NSString *)path error:(NSError **)error
{
    CMISObjectByPathUriBuilder *objectByPathUriBuilder = [self retrieveFromCache:kCMISBindingSessionKeyObjectByPathUriBuilder error:error];
    objectByPathUriBuilder.path = path;

    // Execute actual call
    CMISObjectData *objectData = nil;
    HTTPResponse *response = [HttpUtil invokeGETSynchronous:[objectByPathUriBuilder buildUrl] withSession:self.session error:error];

    if (response.statusCode == 200 && response.data != nil)
    {
        CMISAtomEntryParser *parser = [[CMISAtomEntryParser alloc] initWithData:response.data];
        if ([parser parseAndReturnError:error])
        {
            objectData = parser.objectData;
            return objectData;
        }
    }

    return nil;
}

@end
