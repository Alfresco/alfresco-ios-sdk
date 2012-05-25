//
//  CMISEnums.h
//  ObjectiveCMIS
//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISEnums.h"

@implementation CMISEnums

+ (NSString *)stringFrom:(CMISIncludeRelationship)includeRelationship
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

@end