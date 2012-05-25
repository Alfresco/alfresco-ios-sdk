//
//  CMISAllowableActions.m
//  ObjectiveCMIS
//
//  Created by Gi Lee on 5/8/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISAllowableActions.h"
#import "CMISEnums.h"

#define INT_OBJ(x) [NSNumber numberWithInt:x]

@interface CMISAllowableActions ()
@property (nonatomic, readwrite) NSSet *allowableActionsSet;
@end

@implementation CMISAllowableActions
@synthesize allowableActionsSet = _allowableActionsSet;

- (id)initWithAllowableActionsDictionary:(NSDictionary *)allowableActionsDict
{
    self = [super init];
    if (self)
    {   
        NSSet *filteredSet = [allowableActionsDict keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *aMethod) 
                              {
                                  return [obj isEqualToString:@"true"];
                              }];
        [self setAllowableActionsSet:filteredSet];
    }
    return self;
}

- (id)initWithAllowableActionsDictionary:(NSDictionary *)allowableActionsDict extensionElementArray:(NSArray *)extensionElementArray
{
    self = [self initWithAllowableActionsDictionary:allowableActionsDict];
    if (self)
    {
        self.extensions = extensionElementArray;
    }
    return self;
}

- (NSSet *)allowableActionTypesSet
{
    NSArray *actionsArray = [[NSArray alloc] initWithObjects:CMISAllowableActionsArray];
    
    NSMutableSet *allowableActionTypesSet = [NSMutableSet set];
    for (NSString *actionStrValue in self.allowableActionsSet) 
    {
        // TODO: Check that the idx is valid in the defined enum
        
        NSInteger idx = [actionsArray indexOfObject:actionStrValue];
        [allowableActionTypesSet addObject:INT_OBJ(idx)];
    }
    return [allowableActionTypesSet copy];
}


// TODO: Create helper methods for the different action types.  Example
// - (BOOL)canCreateDocument


#pragma mark -
#pragma mark Overrides

- (NSString *)description
{
    return [NSString stringWithFormat:@"CMIS Allowable Actions: %@", self.allowableActionsSet];
}


@end