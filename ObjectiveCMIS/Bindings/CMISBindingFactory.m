//
//  CMISBindingFactory.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 20/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISBindingFactory.h"
#import "CMISAtomPubBinding.h"

@implementation CMISBindingFactory

- (id<CMISBinding>)bindingWithParameters:(CMISSessionParameters *)sessionParameters;
{
    // TODO: Add default parameters to the session, if not already present.
    
    // TODO: Allow for the creation of custom binding implementations using NSClassFromString.
    
    if (sessionParameters.bindingType == CMISBindingTypeAtomPub)
    {
        return [[CMISAtomPubBinding alloc] initWithSessionParameters:sessionParameters];
    }
    
    return nil;
}


@end
