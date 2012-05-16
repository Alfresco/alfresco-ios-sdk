//
//  CMISAtomPubNavigationService.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 10/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAtomPubNavigationService.h"
#import "CMISAtomPubBaseService+Protected.h"
#import "CMISAtomFeedParser.h"
#import "CMISConstants.h"
#import "CMISAtomPubConstants.h"
#import "CMISHttpUtil.h"
#import "CMISErrors.h"

@implementation CMISAtomPubNavigationService

- (NSArray *)retrieveChildren:(NSString *)objectId error:(NSError **)error
{
    // Get Object for objectId
    NSError *internalError = nil;
    CMISObjectData *cmisObjectData = [self retrieveObjectInternal:objectId error:&internalError];
    if (internalError) 
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISObjectNotFoundError withCMISLocalizedDescription:kCMISObjectNotFoundErrorDescription];
        return nil;
    }
    NSString *downLink = [cmisObjectData.linkRelations linkHrefForRel:kCMISLinkRelationDown type:kCMISMediaTypeChildren];

    // Get children for object
    NSURL *childrenUrl = [NSURL URLWithString:downLink];
    
    // execute the request
    HTTPResponse *response = [HttpUtil invokeGETSynchronous:childrenUrl withSession:self.session error:&internalError];
    if (internalError || response.data == nil) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISConnectionError withCMISLocalizedDescription:kCMISConnectionErrorDescription];
        return nil;        
    }
    CMISAtomFeedParser *parser = [[CMISAtomFeedParser alloc] initWithData:response.data];
    if ([parser parseAndReturnError:error])
    {
        return parser.entries;
    }
    else 
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISRuntimeError withCMISLocalizedDescription:kCMISRuntimeErrorDescription];  
        return nil;
    }
}

- (NSArray *)retrieveParentsForObject:(NSString *)objectId error:(NSError **)error
{
    // Get object data
    NSError *internalError = nil;
    CMISObjectData *objectData = [self retrieveObjectInternal:objectId error:&internalError];
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISObjectNotFoundError withCMISLocalizedDescription:kCMISObjectNotFoundErrorDescription];
        log(@"Failing because CMISObjectData returns with error");
        return nil;
    }

    NSString *upLink = [objectData.linkRelations linkHrefForRel:kCMISLinkRelationUp];
    if (upLink == nil) {
        log(@"Failing because the NString upLink is nil");
        return [NSArray array];
    }
    
    NSData *response = [HttpUtil invokeGETSynchronous:[NSURL URLWithString:upLink] withSession:self.session error:&internalError].data;
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISConnectionError withCMISLocalizedDescription:kCMISConnectionErrorDescription];
        log(@"Failing because the invokeGETSynchronous returns an error");
        return nil;
    }
    CMISAtomFeedParser *parser = [[CMISAtomFeedParser alloc] initWithData:response];
    if (![parser parseAndReturnError:error])
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISRuntimeError withCMISLocalizedDescription:kCMISRuntimeErrorDescription];  
        log(@"Failing because parsing the Atom Feed XML returns an error");
        return nil;
    }
    return parser.entries;    
}

@end
