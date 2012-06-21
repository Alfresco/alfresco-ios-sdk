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

#import "CMISPropertyDefinition.h"


@implementation CMISPropertyDefinition

@synthesize id = _id;
@synthesize localName = _localName;
@synthesize localNamespace = _localNamespace;
@synthesize displayName = _displayName;
@synthesize queryName = _queryName;
@synthesize description = _description;
@synthesize propertyType = _propertyType;
@synthesize cardinality = _cardinality;
@synthesize updatability = _updatability;
@synthesize isInherited = _isInherited;
@synthesize isRequired = _isRequired;
@synthesize isQueryable = _isQueryable;
@synthesize isOrderable = _isOrderable;
@synthesize isOpenChoice = _isOpenChoice;
@synthesize defaultValues = _defaultValues;
@synthesize choices = _choices;

@end