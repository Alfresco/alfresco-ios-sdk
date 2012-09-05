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
/** The AlfrescoKeywordSearchOptions are used in Alfresco Search Service.
 
 Author: Peter Schmidt (Alfresco)
 */

#import <Foundation/Foundation.h>
#import "AlfrescoFolder.h"

@interface AlfrescoKeywordSearchOptions : NSObject
@property (nonatomic, assign) BOOL exactMatch;
@property (nonatomic, assign) BOOL includeContent;
@property (nonatomic, assign) BOOL includeDescendants;
@property (nonatomic, strong) AlfrescoFolder *folder;

- (id)initWithExactMatch:(BOOL)exactMatch includeContent:(BOOL)includeContent;

- (id)initWithFolder:(AlfrescoFolder *)folder includeDescendants:(BOOL)includeDescendants;

- (id)initWithExactMatch:(BOOL)exactMatch
          includeContent:(BOOL)includeContent
                  folder:(AlfrescoFolder *)folder
      includeDescendants:(BOOL)includeDescendants;

@end
