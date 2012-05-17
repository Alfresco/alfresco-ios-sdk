//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//


#import "CMISQueryResult.h"
#import "CMISPropertyData.h"
#import "CMISAllowableActions.h"
#import "CMISObjectData.h"

@interface CMISQueryResult()

@property(nonatomic, strong, readwrite) CMISProperties *properties;
@property(nonatomic, strong, readwrite) CMISAllowableActions *allowableActions;

@end


@implementation CMISQueryResult

@synthesize properties = _properties;
@synthesize allowableActions = _allowableActions;

- (id)initWithCmisObjectData:(CMISObjectData *)cmisObjectData
{
    self = [super init];
    if (self)
    {
        self.properties = cmisObjectData.properties;
        self.allowableActions = cmisObjectData.allowableActions;
    }
    return self;
}

+ (CMISQueryResult *)queryResultUsingCmisObjectData:(CMISObjectData *)cmisObjectData
{
    CMISQueryResult *queryResult = [[CMISQueryResult alloc] initWithCmisObjectData:cmisObjectData];
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