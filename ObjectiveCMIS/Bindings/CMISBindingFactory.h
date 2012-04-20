//
//  CMISBindingFactory.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 20/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISSessionParameters.h"

@interface CMISBindingFactory : NSObject

// Returns an instance of a CMISBinding using the given session parameters
- (id<CMISBinding>)bindingWithParameters:(CMISSessionParameters *)sessionParameters;

@end
