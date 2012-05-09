//
//  CMISAllowableActions.h
//  ObjectiveCMIS
//
//  Created by Gi Lee on 5/8/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CMISAllowableActions : NSObject

// Allowable actions as a NSSet of NSString objects, nil if unknown
@property (nonatomic, readonly) NSSet *allowableActionsSet;

// Use this init method when initializing with a raw NSDictionary parsed from an AtomPub Response
- (id)initWithAllowableActionsDictionary:(NSDictionary *)allowableActionsDict;

// Returns an NSSet of NSNumber of objects.  The NSNumber objects map to the CMISActionType enum
- (NSSet *)allowableActionTypesSet;

@end
