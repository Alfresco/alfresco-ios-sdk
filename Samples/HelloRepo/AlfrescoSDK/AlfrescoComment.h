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


/** The AlfrescoComment represents a comment that's attached to a node in an Alfresco repository.
 
 Author: Gavin Cornwell (Alfresco), Tijs Rademakers (Alfresco)
 */

@interface AlfrescoComment : NSObject

/// @name Properties.

/// Returns the unique identifier of the comment.
@property (nonatomic, strong) NSString *identifier;


/// Returns the name of this comment.
@property (nonatomic, strong) NSString *name;


/// Returns the title of this comment.
@property (nonatomic, strong) NSString *title;


/// Returns the timestamp in the session’s locale when this comment was created.
@property (nonatomic, strong) NSDate *createdAt;


/// Returns the timestamp in the session’s locale when this comment has been modified.
@property (nonatomic, strong) NSDate *modifiedAt;


/// Returns the content of the comment.
@property (nonatomic, strong) NSString *content;


/// Returns the author of the comment as Person Object.
@property (nonatomic, strong) NSString *createdBy;


/// Indicates whether the comment has been edited since it was initially created.
@property (nonatomic) BOOL isEdited;


/// Returns true if the current user can edit this comment.
@property (nonatomic) BOOL canEdit;


/// Returns true if the current user can delete this comment.
@property (nonatomic) BOOL canDelete;

@end
