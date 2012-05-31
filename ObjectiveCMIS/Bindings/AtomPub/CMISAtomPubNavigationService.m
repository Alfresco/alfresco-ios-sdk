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
#import "CMISURLUtil.h"
#import "CMISObjectList.h"

@implementation CMISAtomPubNavigationService

- (CMISObjectList *)retrieveChildren:(NSString *)objectId orderBy:(NSString *)orderBy
                       filter:(NSString *)filter includeRelationShips:(CMISIncludeRelationship)includeRelationship
                       renditionFilter:(NSString *)renditionFilter includeAllowableActions:(BOOL)includeAllowableActions
                       includePathSegment:(BOOL)includePathSegment skipCount:(NSNumber *)skipCount
                       maxItems:(NSNumber *)maxItems error:(NSError **)error
{
    // Get Object for objectId
    NSError *internalError = nil;
    CMISObjectData *cmisObjectData = [self retrieveObjectInternal:objectId error:&internalError];
    if (internalError) 
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeObjectNotFound];
        return nil;
    }
    NSString *downLink = [cmisObjectData.linkRelations linkHrefForRel:kCMISLinkRelationDown type:kCMISMediaTypeChildren];

    // Add optional params (CMISUrlUtil will not append if the param name or value is nil)
    downLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterFilter withValue:filter toUrlString:downLink];
    downLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterOrderBy withValue:orderBy toUrlString:downLink];
    downLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeAllowableActions withValue:(includeAllowableActions ? @"true" : @"false") toUrlString:downLink];
    downLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludeRelationships withValue:[CMISEnums stringFrom:includeRelationship] toUrlString:downLink];
    downLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterRenditionFilter withValue:renditionFilter toUrlString:downLink];
    downLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterIncludePathSegment withValue:(includePathSegment ? @"true" : @"false") toUrlString:downLink];
    downLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterMaxItems withValue:[maxItems stringValue] toUrlString:downLink];
    downLink = [CMISURLUtil urlStringByAppendingParameter:kCMISParameterSkipCount withValue:[skipCount stringValue] toUrlString:downLink];

    // execute the request
    HTTPResponse *response = [HttpUtil invokeGETSynchronous:[NSURL URLWithString:downLink] withSession:self.bindingSession error:&internalError];
    if (internalError || response.data == nil) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeConnection];
        return nil;        
    }

    // Parse the feed (containing entries for the children) you get back
    CMISAtomFeedParser *parser = [[CMISAtomFeedParser alloc] initWithData:response.data];
    if ([parser parseAndReturnError:error])
    {
        NSString *nextLink = [parser.linkRelations linkHrefForRel:kCMISLinkRelationNext];

        CMISObjectList *objectList = [[CMISObjectList alloc] init];
        objectList.hasMoreItems = (nextLink != nil);
        objectList.numItems = parser.numItems;
        objectList.objects = parser.entries;
        return objectList;
    }
    else 
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeRuntime];  
        return nil;
    }
}

- (NSArray *)retrieveParentsForObject:(NSString *)objectId error:(NSError **)error
{
    // Get object data
    NSError *internalError = nil;
    CMISObjectData *objectData = [self retrieveObjectInternal:objectId error:&internalError];
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeObjectNotFound];
        log(@"Failing because CMISObjectData returns with error");
        return nil;
    }

    NSString *upLink = [objectData.linkRelations linkHrefForRel:kCMISLinkRelationUp];
    if (upLink == nil) {
        log(@"Failing because the NString upLink is nil");
        return [NSArray array];
    }
    
    NSData *response = [HttpUtil invokeGETSynchronous:[NSURL URLWithString:upLink] withSession:self.bindingSession error:&internalError].data;
    if (internalError) {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeConnection];
        log(@"Failing because the invokeGETSynchronous returns an error");
        return nil;
    }
    CMISAtomFeedParser *parser = [[CMISAtomFeedParser alloc] initWithData:response];
    if (![parser parseAndReturnError:error])
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeRuntime];  
        log(@"Failing because parsing the Atom Feed XML returns an error");
        return nil;
    }
    return parser.entries;    
}

@end
