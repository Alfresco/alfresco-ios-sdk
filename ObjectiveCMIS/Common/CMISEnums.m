/*
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 */

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