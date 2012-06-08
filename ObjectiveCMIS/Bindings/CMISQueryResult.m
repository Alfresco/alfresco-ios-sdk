//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//


#import "CMISQueryResult.h"
#import "CMISPropertyData.h"
#import "CMISAllowableActions.h"
#import "CMISObjectData.h"
#import "CMISRendition.h"
#import "CMISSession.h"

@interface CMISQueryResult()

@property(nonatomic, strong, readwrite) CMISProperties *properties;
@property(nonatomic, strong, readwrite) CMISAllowableActions *allowableActions;
@property(nonatomic, strong, readwrite) NSArray *renditions;

@end


@implementation CMISQueryResult

@synthesize properties = _properties;
@synthesize allowableActions = _allowableActions;
@synthesize renditions = _renditions;


- (id)initWithCmisObjectData:(CMISObjectData *)cmisObjectData andWithSession:(CMISSession *)session
{
    self = [super init];
    if (self)
    {
        self.properties = cmisObjectData.properties;
        self.allowableActions = cmisObjectData.allowableActions;

        if (cmisObjectData.renditions != nil)
        {
            NSMutableArray *renditions = [NSMutableArray array];
            for (CMISRenditionData *renditionData in cmisObjectData.renditions)
            {
                [renditions addObject:[[CMISRendition alloc] initWithRenditionData:renditionData andObjectId:cmisObjectData.identifier andSession:session]];
            }
            self.renditions = renditions;
        }
    }
    return self;
}

+ (CMISQueryResult *)queryResultUsingCmisObjectData:(CMISObjectData *)cmisObjectData andWithSession:(CMISSession *)session
{
    CMISQueryResult *queryResult = [[CMISQueryResult alloc] initWithCmisObjectData:cmisObjectData andWithSession:session];
    return queryResult;
}

- (CMISPropertyData *)propertyForId:(NSString *)id
{
    return [self.properties propertyForId:id];
}

- (CMISPropertyData *)properyForQueryName:(NSString *)queryName
{
    return [self.properties propertyForQueryName:queryName];
}

- (id)properyValueForId:(NSString *)propertyId
{
    return [self.properties propertyValueForId:propertyId];
}

- (id)propertyValueForQueryName:(NSString *)queryName
{
    return [self.properties propertyValueForQueryName:queryName];
}

- (NSArray *)propertyMultiValueById:(NSString *)id
{
    return [self.properties propertyMultiValueById:id];
}

- (NSArray *)propertyMultiValueByQueryName:(NSString *)queryName
{
    return [self.properties propertyMultiValueByQueryName:queryName];
}


@end