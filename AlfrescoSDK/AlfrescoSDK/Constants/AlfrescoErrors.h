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
    kAlfrescoErrorInvalidArgument = 1,
    kAlfrescoErrorCodeHTTPResponse = 2,

    kAlfrescoErrorCodeSession = 100,
    kAlfrescoErrorCodeNoRepositoryFound = 101,
    kAlfrescoErrorCodeUnauthorisedAccess = 102,
    kAlfrescoErrorCodeNoNetworkFound = 103,
    kAlfrescoErrorCodeSignUpRequestError = 104,

    kAlfrescoErrorCodeJSONParsing = 200,
    kAlfrescoErrorCodeJSONParsingNilData = 201,
    kAlfrescoErrorCodeJSONParsingNoEntry = 202,
    kAlfrescoErrorCodeJSONParsingNoEntries = 203,
    
    kAlfrescoErrorCodeComment = 300,
    kAlfrescoErrorCodeCommentNoCommentFound = 301,

    kAlfrescoErrorCodeSites = 400,
    kAlfrescoErrorCodeSitesNoDocLib = 401,
    kAlfrescoErrorCodeSitesNoSites = 402,

    kAlfrescoErrorCodeActivityStream = 500,
    kAlfrescoErrorCodeActivityStreamNoActivities = 501,

    kAlfrescoErrorCodeDocumentFolder = 600,
    kAlfrescoErrorCodeDocumentFolderPermissions = 601,
    kAlfrescoErrorCodeDocumentFolderNilFolder = 602,
    kAlfrescoErrorCodeDocumentFolderNoParent = 603,
    kAlfrescoErrorCodeDocumentFolderNoRenditionService = 604,
    kAlfrescoErrorCodeDocumentFolderNilDocument = 605,
    kAlfrescoErrorCodeDocumentFolderNodeNotFound = 606,
    kAlfrescoErrorCodeDocumentFolderWrongNodeType = 607,
    kAlfrescoErrorCodeDocumentFolderNoThumbnail = 608,

    kAlfrescoErrorCodeTagging = 700,
    kAlfrescoErrorCodeTaggingNoTags = 701,

    kAlfrescoErrorCodePerson = 800,
    kAlfrescoErrorCodePersonNoAvatarFound = 801,
    kAlfrescoErrorCodePersonNotFound = 802,

    kAlfrescoErrorCodeSearch = 900,
    kAlfrescoErrorCodeSearchUnsupportedSearchLanguage = 901,

    kAlfrescoErrorCodeRatings = 1000
    
}AlfrescoErrorCodes;

extern NSString * const kAlfrescoErrorDomainName;
extern NSString * const kAlfrescoErrorDescriptionUnknown;
extern NSString * const kAlfrescoErrorDescriptionInvalidArgument;

extern NSString * const kAlfrescoErrorDescriptionSession;
extern NSString * const kAlfrescoErrorDescriptionNoRepositoryFound;
extern NSString * const kAlfrescoErrorDescriptionUnauthorisedAccess;
extern NSString * const kAlfrescoErrorDescriptionHTTPResponse;
extern NSString * const kAlfrescoErrorDescriptionNoNetworkFound;
extern NSString * const kAlfrescoErrorDescriptionSignUpRequestError;

extern NSString * const kAlfrescoErrorDescriptionJSONParsing;
extern NSString * const kAlfrescoErrorDescriptionJSONParsingNilData;
extern NSString * const kAlfrescoErrorDescriptionJSONParsingNoEntry;
extern NSString * const kAlfrescoErrorDescriptionJSONParsingNoEntries;

extern NSString * const kAlfrescoErrorDescriptionComment;
extern NSString * const kAlfrescoErrorDescriptionCommentNoCommentFound;

extern NSString * const kAlfrescoErrorDescriptionSites;
extern NSString * const kAlfrescoErrorDescriptionSitesNoDocLib;
extern NSString * const kAlfrescoErrorDescriptionSitesNoSites;

extern NSString * const kAlfrescoErrorDescriptionActivityStream;
extern NSString * const kAlfrescoErrorDescriptionActivityStreamNoActivities;

extern NSString * const kAlfrescoErrorDescriptionDocumentFolder;
extern NSString * const kAlfrescoErrorDescriptionDocumentFolderPermissions;
extern NSString * const kAlfrescoErrorDescriptionDocumentFolderNilFolder;
extern NSString * const kAlfrescoErrorDescriptionDocumentFolderNoParent;
extern NSString * const kAlfrescoErrorDescriptionDocumentFolderNoRenditionService;
extern NSString * const kAlfrescoErrorDescriptionDocumentFolderNilDocument;
extern NSString * const kAlfrescoErrorDescriptionDocumentFolderNodeNotFound;
extern NSString * const kAlfrescoErrorDescriptionDocumentFolderWrongNodeType;
extern NSString * const kAlfrescoErrorDescriptionDocumentFolderNoThumbnail;

extern NSString * const kAlfrescoErrorDescriptionTagging;
extern NSString * const kAlfrescoErrorDescriptionTaggingNoTags;

extern NSString * const kAlfrescoErrorDescriptionPerson;
extern NSString * const kAlfrescoErrorDescriptionPersonNoAvatarFound;
extern NSString * const kAlfrescoErrorDescriptionPersonNotFound;

extern NSString * const kAlfrescoErrorDescriptionSearch;
extern NSString * const kAlfrescoErrorDescriptionSearchUnsupportedSearchLanguage;

extern NSString * const kAlfrescoErrorDescriptionRatings;


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
+ (NSError *)alfrescoErrorWithUnderlyingError:(NSError *)error andAlfrescoErrorCode:(AlfrescoErrorCodes)code;


/** Creates an error object based on an error code and a description.
 
 @param code the code string that represents the error type.
 @param detailedDescription The detailed description of the error.
 @return The newly created error.
 */
+ (NSError *)alfrescoErrorWithAlfrescoErrorCode:(AlfrescoErrorCodes)code;

+ (void)assertArgumentNotNil:(id)argument argumentName:(NSString *)argumentName;
@end
