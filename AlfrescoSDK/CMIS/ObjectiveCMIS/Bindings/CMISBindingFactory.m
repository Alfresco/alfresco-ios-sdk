/*
  Licensed to the Apache Software Foundation (ASF) under one
  or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
 */

#import "CMISBindingFactory.h"
#import "CMISAtomPubBinding.h"
#import "CMISBrowserBinding.h"

@implementation CMISBindingFactory

- (id<CMISBinding>)bindingWithParameters:(CMISSessionParameters *)sessionParameters
{
    // TODO: Add default parameters to the session, if not already present.
    
    // TODO: Allow for the creation of custom binding implementations using NSClassFromString.

    id<CMISBinding> binding = nil;
    if (sessionParameters.bindingType == CMISBindingTypeAtomPub) {
        binding = [[CMISAtomPubBinding alloc] initWithSessionParameters:sessionParameters];
    }
    else if (sessionParameters.bindingType == CMISBindingTypeBrowser) {
        binding = [[CMISBrowserBinding alloc] initWithSessionParameters:sessionParameters];
    }

    return binding;
}


@end
