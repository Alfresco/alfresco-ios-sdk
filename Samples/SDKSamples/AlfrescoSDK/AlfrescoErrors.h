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
/** The AlfrescoErrors error definitions for Mobile SDK.
 
 Author: Peter Schmidt (Alfresco)
 */

#import <Foundation/Foundation.h>

typedef enum 
{

    kAlfrescoErrorCodeUnknown = 0,
    kAlfrescoErrorCodeNoRepositoryFound = 1,
    kAlfrescoErrorHttpResponseNotOk = 2,
    kAlfrescoErrorInvalidArgument = 3,
    
    kAlfrescoErrorCodeComment = 100,
    kAlfrescoErrorCodeSites = 200,
    kAlfrescoErrorCodeActivityStream = 300,
    kAlfrescoErrorCodeDocumentFolder = 400,
    kAlfrescoErrorCodeTagging = 500,
    kAlfrescoErrorCodePerson = 600,
    kAlfrescoErrorCodeSearch = 700,
    kAlfrescoErrorCodeNetwork = 800,
    kAlfrescoErrorCodeRatings = 900,
    kAlfrescoErrorCodeJSONParsing = 1000
}AlfrescoErrorCodes;

extern NSString * const kAlfrescoErrorDomainName;
extern NSString * const kAlfrescoErrorDescriptionUnknown;
extern NSString * const kAlfrescoErrorDescriptionNoRepositoryFound;
extern NSString * const kAlfrescoErrorDescriptionHttpResponseNotOk;
extern NSString * const kAlfrescoErrorDescriptionInvalidArgument;
extern NSString * const kAlfrescoErrorDescriptionComment;
extern NSString * const kAlfrescoErrorDescriptionSites;
extern NSString * const kAlfrescoErrorDescriptionActivityStream;
extern NSString * const kAlfrescoErrorDescriptionDocumentFolder;
extern NSString * const kAlfrescoErrorDescriptionTagging;
extern NSString * const kAlfrescoErrorDescriptionPerson;
extern NSString * const kAlfrescoErrorDescriptionSearch;
extern NSString * const kAlfrescoErrorDescriptionNetwork;
extern NSString * const kAlfrescoErrorDescriptionRatings;
extern NSString * const kAlfrescoErrorDescriptionJSONParsing;
/** AlfrescoErrors is used in case an error occurs when executing an operation against the Alfresco repository.
 
 Author: Peter Schmidt (Alfresco)
 */

@interface AlfrescoErrors : NSObject

/**---------------------------------------------------------------------------------------
 * @name Error creation methods.
 *  ---------------------------------------------------------------------------------------
 */

/** Creates an error object based on another NSError instance.
 
 @param error The error that's used to create an Alfresco error instance.
 @param code the code string that represents the error type.
 @return The newly created error.
 */
+ (NSError *)alfrescoError:(NSError *)error withAlfrescoErrorCode:(AlfrescoErrorCodes)code;


/** Creates an error object based on an error code and a description.
 
 @param code the code string that represents the error type.
 @param detailedDescription The detailed description of the error.
 @return The newly created error.
 */
+ (NSError *)createAlfrescoErrorWithCode:(AlfrescoErrorCodes)code withDetailedDescription:(NSString *)detailedDescription;
@end
