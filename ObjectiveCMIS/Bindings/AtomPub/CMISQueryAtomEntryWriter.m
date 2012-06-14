//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISQueryAtomEntryWriter.h"


@implementation CMISQueryAtomEntryWriter

@synthesize statement = _statement;
@synthesize searchAllVersions = _searchAllVersions;
@synthesize includeRelationships = _includeRelationships;
@synthesize renditionFilter = _renditionFilter;
@synthesize includeAllowableActions = _includeAllowableActions;
@synthesize skipCount = _skipCount;
@synthesize maxItems = _maxItems;


- (id)init
{
    self = [super init];
    if (self)
    {
        self.includeRelationships = CMISIncludeRelationshipNone;
    }
    return self;
}


- (NSString *)generateAtomEntryXML
{
    NSMutableString *xml = [[NSMutableString alloc] init];
    [xml appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
        "<cmis:query xmlns:cmis=\"http://docs.oasis-open.org/ns/cmis/core/200908/\" "
                    "xmlns:cmism=\"http://docs.oasis-open.org/ns/cmis/messaging/200908/\" "
                    "xmlns:atom=\"http://www.w3.org/2005/Atom\" "
                    "xmlns:app=\"http://www.w3.org/2007/app\" "
                    "xmlns:cmisra=\"http://docs.oasis-open.org/ns/cmis/restatom/200908/\">"];

    [xml appendFormat:@"<cmis:statement>%@</cmis:statement>", self.statement];
    [xml appendFormat:@"<cmis:searchAllVersions>%@</cmis:searchAllVersions>", self.searchAllVersions ? @"true" : @"false"];

    [xml appendFormat:@"<cmis:includeAllowableActions>%@</cmis:includeAllowableActions>", self.includeAllowableActions ? @"true" : @"false"];
    [xml appendFormat:@"<cmis:includeRelationships>%@</cmis:includeRelationships>", [CMISEnums stringForIncludeRelationShip:self.includeRelationships]];
    [xml appendFormat:@"<cmis:renditionFilter>%@</cmis:renditionFilter>", self.renditionFilter != nil ? self.renditionFilter : @"*"];

    if (self.maxItems != nil)
    {
        [xml appendFormat:@"<cmis:maxItems>%d</cmis:maxItems>", self.maxItems.intValue];
    }

    if (self.skipCount != nil)
    {
        [xml appendFormat:@"<cmis:skipCount>%d</cmis:skipCount>", self.skipCount.intValue];
    }
    [xml appendString:@"</cmis:query>"];

    return xml;
}

@end