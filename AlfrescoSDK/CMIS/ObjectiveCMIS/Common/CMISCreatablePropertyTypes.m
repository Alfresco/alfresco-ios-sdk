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

#import "CMISCreatablePropertyTypes.h"
#import "CMISLog.h"
#import "CMISObjectConverter.h"
#import "CMISConstants.h"
#import "CMISDictionaryUtil.h"

@implementation CMISCreatablePropertyTypes

- (void)setCreateablePropertyTypeFromDictionary:(NSDictionary *)dictionary
{
    if([dictionary isKindOfClass:NSDictionary.class]){
        
        NSArray *canCreateJson = [dictionary cmis_objectForKeyNotNull:kCMISRepositoryCapabilityCreateablePropertyTypesCanCreate];
        if(canCreateJson){
            if([canCreateJson isKindOfClass:NSArray.class]){
                NSMutableSet *canCreate = [[NSMutableSet alloc] init];
                
                for (id o in canCreateJson) {
                    if(o){
                        [canCreate addObject:o];
                    }
                }
                
                self.canCreate = canCreate;
            } else {
                CMISLogWarning(@"expected an array but was %@", canCreateJson.class);
            }
        }

        self.extensions = [CMISObjectConverter convertExtensions:dictionary cmisKeys:[CMISConstants repositoryCapabilityCreateablePropertyTypesKeys]];
    } else {
        CMISLogWarning(@"expected a dictionary but was %@", dictionary.class);
    }
}

@end
