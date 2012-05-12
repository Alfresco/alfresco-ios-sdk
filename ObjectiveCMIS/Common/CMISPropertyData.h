//
//  CMISPropertyData.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 22/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMISPropertyData : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *localName;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *queryName;

// Returns the list of values of this property. 
// For a single value property this is a list with one entry
@property (nonatomic, strong) NSArray *values;

// Returns the first entry of the list of values.
@property (nonatomic, assign, readonly) id firstValue;

@end
