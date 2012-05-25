//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//


#import "CMISAtomPubDiscoveryService.h"
#import "CMISQueryAtomEntryWriter.h"
#import "CMISHttpUtil.h"
#import "CMISAtomPubConstants.h"
#import "CMISAtomFeedParser.h"
#import "CMISObjectList.h"
#import "CMISErrors.h"

@implementation CMISAtomPubDiscoveryService

- (CMISObjectList *)query:(NSString *)statement searchAllVersions:(BOOL)searchAllVersions
                                                includeRelationShips:(CMISIncludeRelationship)includeRelationships
                                                renditionFilter:(NSString *)renditionFilter
                                                includeAllowableActions:(BOOL)includeAllowableActions
                                                maxItems:(NSNumber *)maxItems
                                                skipCount:(NSNumber *)skipCount
                                                error:(NSError * *)error
{
    // Validate params
    if (statement == nil)
    {
        log(@"Must provide 'statement' parameter when executing a cmis query");
        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument withDetailedDescription:nil];
        return nil;
    }

    // Validate query uri
    NSString *queryUrlString = [self.session objectForKey:kCMISBindingSessionKeyQueryCollection];
    if (queryUrlString == nil)
    {
        log(@"Unknown repository or query not supported!");
        *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound withDetailedDescription:nil];
        return nil;
    }

    NSURL *queryURL = [NSURL URLWithString:queryUrlString];
    // Build XML for query
    CMISQueryAtomEntryWriter *atomEntryWriter = [[CMISQueryAtomEntryWriter alloc] init];
    atomEntryWriter.statement = statement;
    atomEntryWriter.searchAllVersions = searchAllVersions;
    atomEntryWriter.includeAllowableActions = includeAllowableActions;
    atomEntryWriter.includeRelationships = includeRelationships;
    atomEntryWriter.renditionFilter = renditionFilter;
    atomEntryWriter.maxItems = maxItems;
    atomEntryWriter.skipCount = skipCount;

    // Execute HTTP call
    NSError *internalError = nil;
    NSData *responseData = [HttpUtil invokePOSTSynchronous:queryURL
                                 withSession:self.session
                                 body:[[atomEntryWriter generateAtomEntryXML] dataUsingEncoding:NSUTF8StringEncoding]
                                 headers:[NSDictionary dictionaryWithObject:kCMISMediaTypeQuery forKey:@"Content-type"]
                                 error:&internalError].data;
    if (internalError == nil)
    {
        CMISAtomFeedParser *feedParser = [[CMISAtomFeedParser alloc] initWithData:responseData];
        if ([feedParser parseAndReturnError:error])
        {
            NSString *nextLink = [feedParser.linkRelations linkHrefForRel:kCMISLinkRelationNext];

            CMISObjectList *objectList = [[CMISObjectList alloc] init];
            objectList.hasMoreItems = (nextLink != nil);
            objectList.numItems = feedParser.numItems;
            objectList.objects = feedParser.entries;
            return objectList;
        }
    }
    else 
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeConnection];
    }

    return nil;

}

@end