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

- (CMISObjectList *)query:(NSString *)statement searchAllVersions:(BOOL)searchAllVersions maxItems:(NSNumber *)maxItems skipCount:(NSNumber *)skipCount error:(NSError * *)error
{
    // Validate params
    if (statement == nil)
    {
        log(@"Must provide 'statement' parameter when executing a cmis query");
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
        [errorInfo setValue:NSLocalizedString(kCMISInvalidArgumentErrorDescription, kCMISInvalidArgumentErrorDescription) forKey:NSLocalizedDescriptionKey];        
        *error = [NSError errorWithDomain:kCMISErrorDomainName code:kCMISInvalidArgumentError userInfo:errorInfo];
        return nil;
    }

    // Validate query uri
    NSString *queryUrlString = [self.session objectForKey:kCMISBindingSessionKeyQueryCollection];
    if (queryUrlString == nil)
    {
        log(@"Unknown repository or query not supported!");
        NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
        [errorInfo setValue:NSLocalizedString(kCMISObjectNotFoundErrorDescription, kCMISObjectNotFoundErrorDescription) forKey:NSLocalizedDescriptionKey];        
        *error = [NSError errorWithDomain:kCMISErrorDomainName code:kCMISObjectNotFoundError userInfo:errorInfo];
        return nil;
    }

    NSURL *queryURL = [NSURL URLWithString:queryUrlString];
    // Build XML for query
    CMISQueryAtomEntryWriter *atomEntryWriter = [[CMISQueryAtomEntryWriter alloc] init];
    atomEntryWriter.statement = statement;
    atomEntryWriter.searchAllVersions = searchAllVersions;
    atomEntryWriter.maxItems = maxItems;
    atomEntryWriter.skipCount = skipCount;

    // Execute HTTP call
    NSError *internalError = nil;
    NSData *response = [HttpUtil invokePOSTSynchronous:queryURL
                                 withSession:self.session
                                 body:[[atomEntryWriter generateAtomEntryXML] dataUsingEncoding:NSUTF8StringEncoding]
                                 headers:[NSDictionary dictionaryWithObject:kCMISMediaTypeQuery forKey:@"Content-type"]
                                 error:&internalError].data;

    // TODO: check response HTTP status code?

    if (internalError == nil)
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
    else 
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISConnectionError withCMISLocalizedDescription:kCMISConnectionErrorDescription];
    }

    return nil;

}

@end