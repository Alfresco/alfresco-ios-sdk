/*
  Licensed to the Apache Software Foundation (ASF) under one
  or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
 */

#import "CMISEnums.h"
#import "CMISLog.h"
#import "CMISConstants.h"
#import "CMISBrowserConstants.h"

@implementation CMISEnums

+ (NSString *)stringForIncludeRelationShip:(CMISIncludeRelationship)includeRelationship
{
    NSString *includeRelationShipString = nil;
    switch (includeRelationship) {
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
            CMISLogError(@"Invalid enum type %d", (int)includeRelationship);
            break;
    }
    return includeRelationShipString;
}

+ (NSString *)stringForUnfileObject:(CMISUnfileObject)unfileObject;
{
    NSString *unfileObjectString = nil;
    switch (unfileObject) {
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
            CMISLogError(@"Inavlid enum type %d", (int)unfileObject);
            break;
    }
    return unfileObjectString;
}

+ (NSString *)stringForReturnVersion:(BOOL)major
{
    return major == NO ? kCMISParameterValueReturnValueLatest : kCMISParameterValueReturnValueLatestMajor;
}

+ (CMISBaseType)enumForBaseId:(NSString *)baseId
{
    if([kCMISPropertyObjectTypeIdValueDocument isEqualToString:baseId]) {
        return CMISBaseTypeDocument;
    } else if([kCMISPropertyObjectTypeIdValueFolder isEqualToString:baseId]) {
        return CMISBaseTypeFolder;
    } else if([kCMISPropertyObjectTypeIdValueRelationship isEqualToString:baseId]) {
        return CMISBaseTypeRelationship;
    } else if([kCMISPropertyObjectTypeIdValuePolicy isEqualToString:baseId]) {
        return CMISBaseTypePolicy;
    } else if([kCMISPropertyObjectTypeIdValueItem isEqualToString:baseId]) {
        return CMISBaseTypeItem;
    } else if([kCMISPropertyObjectTypeIdValueSecondary isEqualToString:baseId]) {
        return CMISBaseTypeSecondary;
    } else {
        return CMISBaseTypeUnknown;
    }
}

+ (CMISContentStreamAllowedType)enumForContentStreamAllowed:(NSString *)contentStreamAllowed
{
    if([kCMISContentStreamAllowedValueAllowed isEqualToString:contentStreamAllowed]) {
        return CMISContentStreamAllowed;
    } else if([kCMISContentStreamAllowedValueNotAllowed isEqualToString:contentStreamAllowed]) {
        return CMISContentStreamNotAllowed;
    } else if([kCMISContentStreamAllowedValueRequired isEqualToString:contentStreamAllowed]) {
        return CMISContentStreamRequired;
    } else {
        return CMISContentStreamUnknown;
    }
}

+ (CMISPropertyType)enumForPropertyType:(NSString *)typeString
{
    CMISPropertyType propertyType;
    if ([typeString isEqualToString:kCMISBrowserJSONPropertyTypeValueString]) {
        propertyType = CMISPropertyTypeString;
    } else if ([typeString isEqualToString:kCMISBrowserJSONPropertyTypeValueId]) {
        propertyType = CMISPropertyTypeId;
    } else if ([typeString isEqualToString:kCMISBrowserJSONPropertyTypeValueInteger]) {
        propertyType = CMISPropertyTypeInteger;
    } else if ([typeString isEqualToString:kCMISBrowserJSONPropertyTypeValueDecimal]) {
        propertyType = CMISPropertyTypeDecimal;
    } else if ([typeString isEqualToString:kCMISBrowserJSONPropertyTypeValueBoolean]) {
        propertyType = CMISPropertyTypeBoolean;
    } else if ([typeString isEqualToString:kCMISBrowserJSONPropertyTypeValueDateTime]) {
        propertyType = CMISPropertyTypeDateTime;
    } else if ([typeString isEqualToString:kCMISBrowserJSONPropertyTypeValueHtml]) {
        propertyType = CMISPropertyTypeHtml;
    } else if ([typeString isEqualToString:kCMISBrowserJSONPropertyTypeValueUri]) {
        propertyType = CMISPropertyTypeUri;
    } else {
        propertyType = CMISPropertyTypeUnknown;
    }
    return propertyType;
}

@end