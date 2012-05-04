//
//  CMISAtomPubBaseService.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 10/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISSessionParameters.h"
#import "CMISBindingSession.h"

@interface CMISAtomPubBaseService : NSObject

@property (nonatomic, strong, readonly) CMISBindingSession *session;
@property (nonatomic, strong, readonly) NSURL *atomPubUrl;

- (id)initWithBindingSession:(CMISBindingSession *)session;

@end
