//
//  CMISAllowableActions.h
//  ObjectiveCMIS
//
//  Created by Gi Lee on 5/8/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISExtensionData.h"


@interface CMISAllowableActions : CMISExtensionData

// Allowable actions as a NSSet of NSString objects, nil if unknown
@property (nonatomic, readonly) NSSet *allowableActionsSet;

// Designated Initializer. Use this init method when initializing with a raw NSDictionary parsed from an AtomPub Response
- (id)initWithAllowableActionsDictionary:(NSDictionary *)allowableActionsDict;
- (id)initWithAllowableActionsDictionary:(NSDictionary *)allowableActionsDict extensionElementArray:(NSArray *)extensionElementArray;

// Returns an NSSet of NSNumber of objects.  The NSNumber objects map to the CMISActionType enum
- (NSSet *)allowableActionTypesSet;

@end
