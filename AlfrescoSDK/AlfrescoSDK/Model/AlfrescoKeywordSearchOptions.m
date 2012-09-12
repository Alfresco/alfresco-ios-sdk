/*******************************************************************************
 * Copyright (C) 2005-2012 Alfresco Software Limited.
 * 
 * This file is part of the Alfresco Mobile SDK.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *  
 *  http://www.apache.org/licenses/LICENSE-2.0
 * 
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ******************************************************************************/

#import "AlfrescoKeywordSearchOptions.h"

@interface AlfrescoKeywordSearchOptions ()
@property (nonatomic, assign, readwrite) BOOL exactMatch;
@property (nonatomic, assign, readwrite) BOOL includeContent;
@property (nonatomic, assign, readwrite) BOOL includeDescendants;
@property (nonatomic, strong, readwrite) AlfrescoFolder *folder;
@end

@implementation AlfrescoKeywordSearchOptions
@synthesize exactMatch = _exactMatch;
@synthesize includeContent = _includeContent;
@synthesize includeDescendants = _includeDescendants;
@synthesize folder = _folder;

- (id)init
{
    return [self initWithExactMatch:NO includeContent:NO folder:nil includeDescendants:YES];
}

- (id)initWithExactMatch:(BOOL)exactMatch includeContent:(BOOL)includeContent
{
    return [self initWithExactMatch:exactMatch includeContent:includeContent folder:nil includeDescendants:YES];
}

- (id)initWithFolder:(AlfrescoFolder *)folder includeDescendants:(BOOL)includeDescendants
{
    return [self initWithExactMatch:NO includeContent:NO folder:folder includeDescendants:includeDescendants];
}

- (id)initWithExactMatch:(BOOL)exactMatch
          includeContent:(BOOL)includeContent
                  folder:(AlfrescoFolder *)folder
      includeDescendants:(BOOL)includeDescendants
{
    self = [super init];
    if (self)
    {
        self.exactMatch = exactMatch;
        self.folder = folder;
        self.includeContent = includeContent;
        self.includeDescendants = includeDescendants;
    }
    return self;
}

@end
