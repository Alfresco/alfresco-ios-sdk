/*
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "CMISEnums.h"


// TODO: type specific properties, see cmis spec line 527
@interface CMISPropertyDefinition : NSObject


@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *localName;
@property (nonatomic, strong) NSString *localNamespace;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *queryName;
@property (nonatomic, strong) NSString *description;
@property CMISPropertyType propertyType;
@property CMISCardinality cardinality;
@property CMISUpdatability updatability;

@property BOOL isInherited;
@property BOOL isRequired;
@property BOOL isQueryable;
@property BOOL isOrderable;
@property BOOL isOpenChoice;

@property (nonatomic, strong) NSArray *defaultValues;
@property (nonatomic, strong) NSArray *choices;

@end