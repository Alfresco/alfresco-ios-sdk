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

//
// CMISAtomParserUtil
//
#import "CMISAtomPubParserUtil.h"
#import "CMISAtomPubConstants.h"
#import "CMISDateUtil.h"
#import "CMISLog.h"

@implementation CMISAtomPubParserUtil

+ (CMISPropertyType)atomPubTypeToInternalType:(NSString *)atomPubType
{
    if([atomPubType isEqualToString:kCMISAtomEntryPropertyId]) {
        return CMISPropertyTypeId;
    } else if ([atomPubType isEqualToString:kCMISAtomEntryPropertyString]) {
           return CMISPropertyTypeString;
    } else if ([atomPubType isEqualToString:kCMISAtomEntryPropertyInteger]) {
        return CMISPropertyTypeInteger;
    } else if ([atomPubType isEqualToString:kCMISAtomEntryPropertyBoolean]) {
        return CMISPropertyTypeBoolean;
    } else if ([atomPubType isEqualToString:kCMISAtomEntryPropertyDateTime]) {
        return CMISPropertyTypeDateTime;
    } else if ([atomPubType isEqualToString:kCMISAtomEntryPropertyDecimal]) {
        return CMISPropertyTypeDecimal;
    } else if ([atomPubType isEqualToString:kCMISAtomEntryPropertyHtml]) {
        return CMISPropertyTypeHtml;
    } else if ([atomPubType isEqualToString:kCMISAtomEntryPropertyUri]) {
        return CMISPropertyTypeUri;
    } else {
        CMISLogDebug(@"Unknown property type %@. Go tell a developer to fix this.", atomPubType);
        return CMISPropertyTypeString;
    }
}

+ (void)parsePropertyValue:(NSString *)stringValue propertyType:(NSString *)propertyType addToArray:(NSMutableArray*)array
{
    if ([propertyType isEqualToString:kCMISAtomEntryPropertyString] ||
        [propertyType isEqualToString:kCMISAtomEntryPropertyId] ||
        [propertyType isEqualToString:kCMISAtomEntryPropertyHtml]) {
        [array addObject:stringValue];
    } else if ([propertyType isEqualToString:kCMISAtomEntryPropertyInteger]) {
        [array addObject:[NSNumber numberWithInt:[stringValue intValue]]];
    } else if ([propertyType isEqualToString:kCMISAtomEntryPropertyBoolean]) {
        [array addObject:[NSNumber numberWithBool:[stringValue isEqualToString:kCMISAtomEntryValueTrue]]];
    } else if ([propertyType isEqualToString:kCMISAtomEntryPropertyDateTime]) {
        [array addObject:[CMISDateUtil dateFromString:stringValue]];
    } else if ([propertyType isEqualToString:kCMISAtomEntryPropertyDecimal]) {
        [array addObject:[NSDecimalNumber decimalNumberWithString:stringValue]];
    } else if ([propertyType isEqualToString:kCMISAtomEntryPropertyUri]) {
        [array addObject:[NSURL URLWithString:stringValue]];
    } else {
        CMISLogDebug(@"Unknown property type %@. Go tell a developer to fix this.", propertyType);
    }
}


@end