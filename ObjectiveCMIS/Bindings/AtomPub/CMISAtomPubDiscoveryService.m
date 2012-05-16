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


@implementation CMISAtomPubDiscoveryService

- (CMISObjectList *)query:(NSString *)statement searchAllVersions:(BOOL)searchAllVersions maxItems:(NSNumber *)maxItems skipCount:(NSNumber *)skipCount error:(NSError * *)error
{
    // Validate query uri
    NSString *queryUrlString = [self.session objectForKey:kCMISBindingSessionKeyQueryCollection];
    if (queryUrlString == nil)
    {
        log(@"Unknown repository or query not supported!");
        // TODO: init error propertly
        *error = [[NSError alloc] init];
        return nil;
    }
    NSURL *queryURL = [NSURL URLWithString:queryUrlString];

    // Validate params
    if (statement == nil)
    {
        log(@"Must provide 'statement' parameter when executing a cmis query");
        // TODO: init error propertly
        *error = [[NSError alloc] init];
        return nil;
    }

    // Build XML for query
    CMISQueryAtomEntryWriter *atomEntryWriter = [[CMISQueryAtomEntryWriter alloc] init];
    atomEntryWriter.statement = statement;
    atomEntryWriter.searchAllVersions = searchAllVersions;
    atomEntryWriter.maxItems = maxItems;
    atomEntryWriter.skipCount = skipCount;

    // Execute HTTP call
    NSData *response = [HttpUtil invokePOSTSynchronous:queryURL
                                 withSession:self.session
                                 body:[[atomEntryWriter generateAtomEntryXML] dataUsingEncoding:NSUTF8StringEncoding]
                                 headers:[NSDictionary dictionaryWithObject:kCMISMediaTypeQuery forKey:@"Content-type"]
                                 error:error].data;

    // TODO: check response HTTP status code?

    if (*error == nil)
    {
        CMISAtomFeedParser *feedParser = [[CMISAtomFeedParser alloc] initWithData:response];
        if ([feedParser parseAndReturnError:error])
        {
            CMISObjectList *objectList = [[CMISObjectList alloc] init];
            objectList.numItems = feedParser.numItems;
            objectList.objects = feedParser.entries;
            return objectList;
        }
    }

    return nil;

}

@end