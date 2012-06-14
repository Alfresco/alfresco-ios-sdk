//
//  CMISEnums.h
//  ObjectiveCMIS
//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISEnums.h"

@implementation CMISEnums

+ (NSString *)stringForIncludeRelationShip:(CMISIncludeRelationship)includeRelationship
{
    NSString *includeRelationShipString = nil;
    switch (includeRelationship)
    {
        case (CMISIncludeRelationshipNone):
            includeRelationShipString = @"none";
            break;
        case (CMISIncludeRelationshipSource):
            includeRelationShipString = @"source";
            break;
        case (CMISIncludeRelationshipTarget):
            includeRelationShipString = @"target";
            break;
        case (CMISIncludeRelationshipBoth):
            includeRelationShipString = @"both";
            break;
        default:
            log(@"Invalid enum type %d", includeRelationship);
            break;
    }
    return includeRelationShipString;
}

+ (NSString *)stringForUnfileObject:(CMISUnfileObject)unfileObject;
{
    NSString *unfileObjectString = nil;
    switch (unfileObject)
    {
        case CMISUnfile:
            unfileObjectString = @"unfile";
            break;
        case  CMISDeleteSingleFiled:
            unfileObjectString = @"deletesinglefiled";
            break;
        case CMISDelete:
            unfileObjectString = @"delete";
            break;
        default:
            log(@"Inavlid enum type %d", unfileObject);
            break;
    }
    return unfileObjectString;
}

@end