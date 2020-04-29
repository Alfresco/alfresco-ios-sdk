/*
 ******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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
 *****************************************************************************
 */

//
// AlfrescoCMISUtil 
//
#import <Foundation/Foundation.h>
#import "AlfrescoNode.h"

@class CMISObject, CMISProperties, CMISSession;


@interface AlfrescoCMISUtil : NSObject

/**
 * Processes Alfresco cmis extensions:
 * - Returns an array with al the aspect type ids for the object
 * - Adds all extension properties to the properties property of the object.
 */
+ (NSMutableArray *)processExtensionElementsForObject:(CMISObject *)cmisObject;

/**
 maps CMIS errors to Alfresco Errors
 */
+ (NSError *)alfrescoErrorWithCMISError:(NSError *)cmisError;

/**
 * Prepares the CMIS objectTypeId property for the given set of properties.
 */
+ (NSString *)prepareObjectTypeIdForProperties:(NSDictionary *)alfrescoProperties
                                          type:(NSString *)type
                                       aspects:(NSArray *)aspects
                                        folder:(BOOL)folder;

/**
 * Prepares the given dictionary of Alfresco properties for update via CMIS
 */
+ (void)preparePropertiesForUpdate:(NSDictionary *)alfrescoProperties
                           aspects:(NSArray *)aspects
                              node:(AlfrescoNode *)node
                       cmisSession:(CMISSession *)cmisSession
                   completionBlock:(void (^)(CMISProperties *cmisProperties, NSError *error))completionBlock;

@end
