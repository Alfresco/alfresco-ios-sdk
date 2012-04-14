//
//  CMISBinding.m
//  HybridApp
//
//  Created by Cornwell Gavin on 10/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISConstants.h"
#import "CMISBinding.h"
#import "CMISAtomPubBinding.h"

@implementation CMISBinding

+ (id<CMISBindingDelegate>)createCMISBinding:(CMISSessionParameters *)sessionParameters
{
    // TODO: Handle errors with an NSError object?
    
    if (sessionParameters.bindingType == CMISBindingTypeAtomPub)
    {
        return [[CMISAtomPubBinding alloc] initWithSessionParameters:sessionParameters];
    }
    
    return nil;
}

@end
