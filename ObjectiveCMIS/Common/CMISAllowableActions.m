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

#import "CMISAllowableActions.h"
#import "CMISEnums.h"

#define INT_OBJ(x) [NSNumber numberWithInt:x]

@interface CMISAllowableActions ()

@property (nonatomic, strong, readwrite) NSSet *allowableActionsSet;

@end


@implementation CMISAllowableActions
@synthesize allowableActionsSet = _allowableActionsSet;

- (id)init
{
    self = [super init];

    return self;
}

- (id)initWithAllowableActionsDictionary:(NSDictionary *)allowableActionsDict
{
    self = [self init];
    if (self)
    {   
        [self setAllowableActionsWithDictionary:allowableActionsDict];
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

- (void)setAllowableActionsWithDictionary:(NSDictionary *)allowableActionsDict
{
    NSSet *filteredSet = [allowableActionsDict keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *aMethod) 
                          {
                              return [obj isEqualToString:@"true"];
                          }];
    [self setAllowableActionsSet:filteredSet];
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