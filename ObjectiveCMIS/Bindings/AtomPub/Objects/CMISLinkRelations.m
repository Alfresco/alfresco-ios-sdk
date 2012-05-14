//
//  CMISLinkRelations.m
//  ObjectiveCMIS
//
//  Created by Gi Lee on 5/13/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISLinkRelations.h"

@interface CMISLinkRelations ()
@property (nonatomic, strong, readwrite) NSSet *linkRelationSet;
@end

@implementation CMISLinkRelations

@synthesize linkRelationSet = _linkRelationSet;

- (id)initWithLinkRelationSet:(NSSet *)linkRelationSet
{
    self = [super init];
    if (self)
    {
        self.linkRelationSet = linkRelationSet;
    }
    return self;
}

- (NSString *)linkHrefForRel:(NSString *)rel
{
    return [self linkHrefForRel:rel type:nil];
}

- (NSString *)linkHrefForRel:(NSString *)rel type:(NSString *)type
{
    NSArray *predicateArgsArray = nil;
    
    NSString *predicateFormat = @"(rel == %@)";
    if (type != nil && type.length > 0)
    {
        predicateFormat = [predicateFormat stringByAppendingString:@"&& (type == %@)"];
        predicateArgsArray = [NSArray arrayWithObjects:rel, type, nil];
    }
    else 
    {
        predicateArgsArray = [NSArray arrayWithObject:rel];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:predicateArgsArray];
    NSSet *filteredSet = [self.linkRelationSet filteredSetUsingPredicate:predicate];
    if ([filteredSet count] == 1)
    {
        return [filteredSet.anyObject valueForKey:@"href"];
    }
    
    // We will only get here if the link to return is ambiguous or if no link is found for the rel/type
    
    return nil;
}

@end
