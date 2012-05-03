//
//  CMISBindingFactory.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 20/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISBindingFactory.h"
#import "CMISAtomPubBinding.h"
#import "CMISConstants.h"

@implementation CMISBindingFactory

- (id<CMISBinding>)bindingWithParameters:(CMISSessionParameters *)sessionParameters
{
    // TODO: Add default parameters to the session, if not already present.
    
    // TODO: Allow for the creation of custom binding implementations using NSClassFromString.

    id<CMISBinding> binding = nil;
    if (sessionParameters.bindingType == CMISBindingTypeAtomPub)
    {
        binding = [[CMISAtomPubBinding alloc] initWithSessionParameters:sessionParameters];
    }

    [sessionParameters setObject:binding forKey:kCMISSessionKeyBinding];
    return binding;
}


@end
