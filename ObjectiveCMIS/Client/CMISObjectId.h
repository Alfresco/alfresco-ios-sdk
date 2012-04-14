//
//  CMISObjectId.h
//  HybridApp
//
//  Created by Cornwell Gavin on 21/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMISObjectId : NSObject

@property (nonatomic, strong, readonly) NSString *identifier;

- (id)initWithString:(NSString *)string;

@end
