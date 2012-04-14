//
//  CMISBinding.h
//  HybridApp
//
//  Created by Cornwell Gavin on 10/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISBindingProtocols.h"
#import "CMISSessionParameters.h"

@interface CMISBinding : NSObject

// creation
+ (id<CMISBindingDelegate>)createCMISBinding:(CMISSessionParameters *)sessionParameters;

@end
