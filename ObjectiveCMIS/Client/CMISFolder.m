//
//  CMISFolder.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 21/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISFolder.h"
#import "CMISObjectConverter.h"
#import "CMISConstants.h"
#import "CMISErrors.h"
#import "CMISPagedResult.h"
#import "CMISOperationContext.h"
#import "CMISObjectList.h"

@interface CMISFolder ()

@property (nonatomic, strong, readwrite) NSString *path;
@property (nonatomic, strong, readwrite) CMISCollection *children;
@end

@implementation CMISFolder

@synthesize path = _path;
@synthesize children = _children;

- (id)initWithObjectData:(CMISObjectData *)objectData withSession:(CMISSession *)session
{
    self = [super initWithObjectData:objectData withSession:session];
    if (self)
    {
        self.path = [[objectData.properties propertyForId:kCMISPropertyPath] firstValue];
    }
    return self;
}

- (CMISPagedResult *)retrieveChildrenAndReturnError:(NSError **)error
{
    return [self retrieveChildrenWithOperationContext:[CMISOperationContext defaultOperationContext] andReturnError:error];
}

- (CMISPagedResult *)retrieveChildrenWithOperationContext:(CMISOperationContext *)operationContext andReturnError:(NSError **)error
{
    CMISFetchNextPageBlock fetchNextPageBlock = ^CMISFetchNextPageBlockResult *(int skipCount, int maxItems, NSError **fetchError)
    {
        // Fetch results through navigationService
        CMISObjectList *objectList = [self.binding.navigationService retrieveChildren:self.identifier
                                                   orderBy:operationContext.orderBy
                                                   filter:operationContext.filterString
                                                   includeRelationShips:operationContext.includeRelationShips
                                                   renditionFilter:operationContext.renditionFilterString
                                                   includeAllowableActions:operationContext.isIncludeAllowableActions
                                                   includePathSegment:operationContext.isIncludePathSegments
                                                   skipCount:[NSNumber numberWithInt:skipCount]
                                                   maxItems:[NSNumber numberWithInt:maxItems]
                                                   error:fetchError];



        // Fill up return result
        CMISFetchNextPageBlockResult *result = [[CMISFetchNextPageBlockResult alloc] init];
        result.hasMoreItems = objectList.hasMoreItems;
        result.numItems = objectList.numItems;

        CMISObjectConverter *converter = [[CMISObjectConverter alloc] initWithSession:self.session];
        result.resultArray = [converter convertObjects:objectList.objects].items;

        return result;
    };

    NSError *internalError = nil;
    CMISPagedResult *result = [CMISPagedResult pagedResultUsingFetchBlock:fetchNextPageBlock
                                                       andLimitToMaxItems:operationContext.maxItemsPerPage
                                                    andStartFromSkipCount:operationContext.skipCount
                                                                    error:&internalError];

    // Return nil and populate error in case something went wrong
    if (internalError != nil)
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeRuntime];
        return nil;
    }

    return result;
}

- (NSString *)createFolder:(NSDictionary *)properties error:(NSError **)error;
{
    NSError *internalError = nil;
    CMISObjectConverter *converter = [[CMISObjectConverter alloc] initWithSession:self.session];
    CMISProperties *convertedProperties = [converter convertProperties:properties forObjectTypeId:kCMISPropertyObjectTypeIdValueFolder error:&internalError];
    if (internalError != nil)
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeRuntime];
        return nil;
    }

    return [self.binding.objectService createFolderInParentFolder:self.identifier withProperties:convertedProperties error:error];
}

- (NSString *)createDocumentFromFilePath:(NSString *)filePath withMimeType:(NSString *)mimeType withProperties:(NSDictionary *)properties error:(NSError **)error
{
    NSError *internalError = nil;
    CMISObjectConverter *converter = [[CMISObjectConverter alloc] initWithSession:self.session];
    CMISProperties *convertedProperties = [converter convertProperties:properties forObjectTypeId:kCMISPropertyObjectTypeIdValueDocument error:&internalError];
    if (internalError != nil)
    {
        *error = [CMISErrors cmisError:&internalError withCMISErrorCode:kCMISErrorCodeRuntime];
        return nil;
    }

    return [self.binding.objectService createDocumentFromFilePath:filePath withMimeType:mimeType withProperties:convertedProperties inFolder:self.identifier error:error];
}

- (NSArray *)deleteTreeAndReturnError:(NSError **)error
{
    return [self.binding.objectService deleteTree:self.identifier error:error];
}


@end
