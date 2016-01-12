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

#import "CMISNewTypeSettableAttributes.h"
#import "CMISDictionaryUtil.h"
#import "CMISLog.h"
#import "CMISConstants.h"
#import "CMISObjectConverter.h"

@implementation CMISNewTypeSettableAttributes

- (void)setNewTypeSettableAttributesFromDictionary:(NSDictionary *)dictionary
{
    if([dictionary isKindOfClass:NSDictionary.class]){
        self.canSetId = [dictionary cmis_boolForKey:kCMISRepositoryCapabilityNewTypeSettableAttributesId];
        self.canSetLocalName = [dictionary cmis_boolForKey:kCMISRepositoryCapabilityNewTypeSettableAttributesLocalName];
        self.canSetLocalNamespace = [dictionary cmis_boolForKey:kCMISRepositoryCapabilityNewTypeSettableAttributesLocalNamespace];
        self.canSetDisplayName = [dictionary cmis_boolForKey:kCMISRepositoryCapabilityNewTypeSettableAttributesDisplayName];
        self.canSetQueryName = [dictionary cmis_boolForKey:kCMISRepositoryCapabilityNewTypeSettableAttributesQueryName];
        self.canSetDescription = [dictionary cmis_boolForKey:kCMISRepositoryCapabilityNewTypeSettableAttributesDescription];
        self.canSetCreatable = [dictionary cmis_boolForKey:kCMISRepositoryCapabilityNewTypeSettableAttributesCreateable];
        self.canSetFileable = [dictionary cmis_boolForKey:kCMISRepositoryCapabilityNewTypeSettableAttributesFileable];
        self.canSetQueryable = [dictionary cmis_boolForKey:kCMISRepositoryCapabilityNewTypeSettableAttributesQueryable];
        self.canSetFulltextIndexed = [dictionary cmis_boolForKey:kCMISRepositoryCapabilityNewTypeSettableAttributesFullTextIndexed];
        self.canSetIncludedInSupertypeQuery = [dictionary cmis_boolForKey:kCMISRepositoryCapabilityNewTypeSettableAttributesIncludedInSuperTypeQuery];
        self.canSetControllablePolicy = [dictionary cmis_boolForKey:kCMISRepositoryCapabilityNewTypeSettableAttributesControllablePolicy];
        self.canSetControllableAcl = [dictionary cmis_boolForKey:kCMISRepositoryCapabilityNewTypeSettableAttributesControllableAcl];
        
        self.extensions = [CMISObjectConverter convertExtensions:dictionary cmisKeys:[CMISConstants repositoryCapabilityNewTypeSettableAttributesKeys]];
    } else {
        CMISLogWarning(@"expected a dictionary but was %@", dictionary.class);
    }
}

@end
