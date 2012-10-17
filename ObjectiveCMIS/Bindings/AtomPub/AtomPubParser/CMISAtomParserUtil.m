/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is the Alfresco Mobile App.
 *
 * The Initial Developer of the Original Code is Zia Consulting, Inc.
 * Portions created by the Initial Developer are Copyright (C) 2011-2012
 * the Initial Developer. All Rights Reserved.
 *
 *
 * ***** END LICENSE BLOCK ***** */

//
// CMISAtomParserUtil 
//
#import "CMISAtomParserUtil.h"
#import "CMISAtomPubConstants.h"
#import "CMISISO8601DateFormatter.h"
#import "CMISEnums.h"


@implementation CMISAtomParserUtil

//+ (CMISPropertyType)atomPubTypeToInternalType:(NSString *)atomPubType
//{
//    if([atomPubType isEqualToString:kCMISAtomEntryPropertyId])
//    {
//        return CMISPropertyTypeId;
//    }
//    else if ([atomPubType isEqualToString:kCMISAtomEntryPropertyInteger])
//       {
//           return CMISPropertyTypeString;
//       }
//    else if ([atomPubType isEqualToString:kCMISAtomEntryPropertyInteger])
//    {
//        return CMISPropertyTypeInteger;
//    }
//    else if ([atomPubType isEqualToString:kCMISAtomEntryPropertyBoolean])
//    {
//        return CMISPropertyTypeBoolean;
//    }
//    else if ([atomPubType isEqualToString:kCMISAtomEntryPropertyDateTime])
//    {
//        return CMISPropertyTypeDateTime;
//    }
//    else if ([atomPubType isEqualToString:kCMISAtomEntryPropertyDecimal])
//    {
//        return CMISPropertyTypeDecimal;
//    }
//}

+ (NSArray *)parsePropertyValue:(NSString *)stringValue withPropertyType:(NSString *)propertyType
{
    if ([propertyType isEqualToString:kCMISAtomEntryPropertyString] ||
            [propertyType isEqualToString:kCMISAtomEntryPropertyId])
    {
        return [NSArray arrayWithObject:stringValue];
    }
    else if ([propertyType isEqualToString:kCMISAtomEntryPropertyInteger])
    {
        return [NSArray arrayWithObject:[NSNumber numberWithInt:[stringValue intValue]]];
    }
    else if ([propertyType isEqualToString:kCMISAtomEntryPropertyBoolean])
    {
        return [NSArray arrayWithObject:[NSNumber numberWithBool:[stringValue isEqualToString:kCMISAtomEntryValueTrue]]];
    }
    else if ([propertyType isEqualToString:kCMISAtomEntryPropertyDateTime])
    {
        CMISISO8601DateFormatter *df = [[CMISISO8601DateFormatter alloc] init];
        return [NSArray arrayWithObject:[df dateFromString:stringValue]];
    }
    else if ([propertyType isEqualToString:kCMISAtomEntryPropertyDecimal])
    {
        return [NSArray arrayWithObject:[NSNumber numberWithFloat:[stringValue floatValue]]];
    }
}


@end