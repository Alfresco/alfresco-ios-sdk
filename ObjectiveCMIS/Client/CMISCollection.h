//
//  CMISCollection.h
//  HybridApp
//
//  Created by Cornwell Gavin on 21/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMISCollection : NSObject

@property (nonatomic, strong, readonly)NSArray *items;

- (id)initWithItems:(NSArray *)items;

@end
