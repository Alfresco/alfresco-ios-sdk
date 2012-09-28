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

#import <Foundation/Foundation.h>
/** The AlfrescoContentFile objects are used for download/upload content.
 
 Author: Peter Schmidt (Alfresco)
 */

@interface AlfrescoContentFile : NSObject

/// @name Properties
@property (nonatomic, strong, readonly) NSURL *fileUrl;
@property (nonatomic, strong, readonly) NSString *mimeType;
@property (nonatomic, assign, readonly) NSUInteger length;

/**---------------------------------------------------------------------------------------
 * @name initialisers.
 *  ---------------------------------------------------------------------------------------
 */

/**
 Creates a new file in the temporary directory folder and copies the data of the file at URL
 Detects the mime type based on the extension of the file
 @param the URL of the file.
 */
- (id)initWithUrl:(NSURL *)url;

/** creates a new  file in the temporary folder 
 
 @param data The data to initialise the AlfrescoContentFile with
 @param mimeType the mime type of the data
 */
- (id)initWithData:(NSData *)data mimeType:(NSString *)mimeType;


/** creates a new  file in the temporary folder
 
 @param path the full file path of the file to be used
 @param mimeType the mime type of the data
 */
- (id)initWithFilePath:(NSString *)path mimeType:(NSString *)mimeType;
@end
