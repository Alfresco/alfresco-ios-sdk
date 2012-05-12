//
//  CMISAtomPubBinding.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 15/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISBinding.h"
#import "CMISSessionParameters.h"

@interface CMISAtomPubBinding : NSObject <CMISBinding>

- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters;

@end
