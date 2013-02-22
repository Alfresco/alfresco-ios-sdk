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

#import "AlfrescoErrors.h"
NSString * const kAlfrescoErrorDomainName = @"AlfrescoErrorDomain";

NSString * const kAlfrescoErrorDescriptionUnknown = @"Unknown Alfresco Error";
NSString * const kAlfrescoErrorDescriptionRequestedNodeNotFound = @"The requested node wasn't found";
NSString * const kAlfrescoErrorDescriptionAccessDenied = @"Access Denied";

NSString * const kAlfrescoErrorDescriptionSession = @"Session Error";
NSString * const kAlfrescoErrorDescriptionNoRepositoryFound = @"Session Error: No Alfresco repository found";
NSString * const kAlfrescoErrorDescriptionUnauthorisedAccess = @"Session Error: Unauthorised Access";
NSString * const kAlfrescoErrorDescriptionHTTPResponse= @"Session Error: the HTTP Response code suggests an error";
NSString * const kAlfrescoErrorDescriptionNoNetworkFound = @"Session Error: No Cloud network/domain found";
NSString * const kAlfrescoErrorDescriptionAPIKeyOrSecretKeyUnrecognised = @"The API or Secret Key (or both) are unrecognised";
NSString * const kAlfrescoErrorDescriptionAuthorizationCodeInvalid = @"The authentication code is invalid";
NSString * const kAlfrescoErrorDescriptionAccessTokenExpired = @"The access token has expired";
NSString * const kAlfrescoErrorDescriptionRefreshTokenExpired = @"The refresh token has expired";
NSString * const kAlfrescoErrorDescriptionNetworkRequestCancelled = @"The network request was cancelled";

NSString * const kAlfrescoErrorDescriptionJSONParsing = @"JSON Data parsing Error";
NSString * const kAlfrescoErrorDescriptionJSONParsingNilData = @"JSON Data are nil/empty";
NSString * const kAlfrescoErrorDescriptionJSONParsingNoEntry = @"JSON Data: missing entry element";
NSString * const kAlfrescoErrorDescriptionJSONParsingNoEntries = @"JSON Data: missing entries element";

NSString * const kAlfrescoErrorDescriptionComment = @"Comment Service Error";
NSString * const kAlfrescoErrorDescriptionCommentNoCommentFound = @"Comment Service Error: No Comments were found";

NSString * const kAlfrescoErrorDescriptionSites = @"Sites Service Error";
NSString * const kAlfrescoErrorDescriptionSitesNoDocLib = @"Sites Service Error: No Document Library was found";
NSString * const kAlfrescoErrorDescriptionSitesNoSites = @"Sites Service Error: No Sites were found.";

NSString * const kAlfrescoErrorDescriptionActivityStream =@"Activity Stream Service Error";
NSString * const kAlfrescoErrorDescriptionActivityStreamNoActivities =@"Activity Stream Service Error: No Activities were found.";

NSString * const kAlfrescoErrorDescriptionDocumentFolder = @"Document Folder Service Error";
NSString * const kAlfrescoErrorDescriptionDocumentFolderPermissions = @"Document Folder Service Error: Error retrieving Permissions";
NSString * const kAlfrescoErrorDescriptionDocumentFolderNoParent = @"Document Folder Service Error: No Parent Folder";
NSString * const kAlfrescoErrorDescriptionDocumentFolderWrongNodeType = @"Document Folder Service Error: wrong node type. Expected either folder or document.";
NSString * const kAlfrescoErrorDescriptionDocumentFolderNodeAlreadyExists = @"Node already exists";
NSString * const kAlfrescoErrorDescriptionDocumentFolderFailedToConvertNode = @"Node could not be converted to an Alfresco object";



NSString * const kAlfrescoErrorDescriptionDocumentFolderNoThumbnail = @"Document Folder Service Error: No Thumbnail found for document/folder.";

NSString * const kAlfrescoErrorDescriptionTagging = @"Tagging Service Error";
NSString * const kAlfrescoErrorDescriptionTaggingNoTags = @"Tagging Service Error: No tags were found.";

NSString * const kAlfrescoErrorDescriptionPerson = @"Person Service Error";
NSString * const kAlfrescoErrorDescriptionPersonNoAvatarFound = @"Person Service Error: no avatar for the user was found.";
NSString * const kAlfrescoErrorDescriptionPersonNotFound = @"Person Service Error: person/user wasn't found.";

NSString * const kAlfrescoErrorDescriptionSearch = @"Search Service Error";

NSString * const kAlfrescoErrorDescriptionRatings = @"Ratings Service Error";
NSString * const kAlfrescoErrorDescriptionRatingsNoRatings = @"No Ratings found";




@interface AlfrescoErrors ()
+ (NSString *)descriptionForAlfrescoErrorCode:(AlfrescoErrorCodes)code;
@end

@implementation AlfrescoErrors
+ (NSError *)alfrescoErrorWithUnderlyingError:(NSError *)error andAlfrescoErrorCode:(AlfrescoErrorCodes)code
{
    if (error == nil) {//shouldn't really get there
        return nil;
    }
    if ([error.domain isEqualToString:kAlfrescoErrorDomainName]) {
        return error;
    }
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
    [errorInfo setValue:[AlfrescoErrors descriptionForAlfrescoErrorCode:code] forKey:NSLocalizedDescriptionKey];
    [errorInfo setObject:error forKey:NSUnderlyingErrorKey];
    return [NSError errorWithDomain:kAlfrescoErrorDomainName code:code userInfo:errorInfo];    
}

+ (NSError *)alfrescoErrorWithAlfrescoErrorCode:(AlfrescoErrorCodes)code
{
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
    [errorInfo setValue:[AlfrescoErrors descriptionForAlfrescoErrorCode:code] forKey:NSLocalizedDescriptionKey];
    NSString *standardDescription = [AlfrescoErrors descriptionForAlfrescoErrorCode:code];
    [errorInfo setValue:standardDescription forKey:NSLocalizedFailureReasonErrorKey];    
    return [NSError errorWithDomain:kAlfrescoErrorDomainName code:code userInfo:errorInfo];    
}

+ (void)assertArgumentNotNil:(id)argument argumentName:(NSString *)argumentName
{
    if (nil == argument)
    {
        NSString * message = [NSString stringWithFormat:@"%@ must not be nil",argumentName];
        NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:message userInfo:nil];
        @throw exception;
    }
}

+ (void)assertStringArgumentNotNilOrEmpty:(NSString *)argument argumentName:(NSString *)argumentName
{
    if (nil == argument)
    {
        NSString * message = [NSString stringWithFormat:@"%@ must not be nil",argumentName];
        NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:message userInfo:nil];
        @throw exception;
    }
    else if ([argument isEqualToString:@""])
    {
        NSString * message = [NSString stringWithFormat:@"%@ must not be empty",argumentName];
        NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:message userInfo:nil];
        @throw exception;        
    }
    
}



+ (NSString *)descriptionForAlfrescoErrorCode:(AlfrescoErrorCodes)code
{
    switch (code) {
        case kAlfrescoErrorCodeUnknown:
            return kAlfrescoErrorDescriptionUnknown;            
            break;
        case kAlfrescoErrorCodeHTTPResponse:
            return kAlfrescoErrorDescriptionHTTPResponse;
            break;
        case kAlfrescoErrorCodeRequestedNodeNotFound:
            return kAlfrescoErrorDescriptionRequestedNodeNotFound;
            break;
        case kAlfrescoErrorCodeAccessDenied:
            return kAlfrescoErrorDescriptionAccessDenied;
            break;
        case kAlfrescoErrorCodeSession:
            return kAlfrescoErrorDescriptionSession;
            break;
        case kAlfrescoErrorCodeNoRepositoryFound:
            return kAlfrescoErrorDescriptionNoRepositoryFound;
            break;
        case kAlfrescoErrorCodeUnauthorisedAccess:
            return kAlfrescoErrorDescriptionUnauthorisedAccess;
            break;
            
        case kAlfrescoErrorCodeAPIKeyOrSecretKeyUnrecognised:
            return kAlfrescoErrorDescriptionAPIKeyOrSecretKeyUnrecognised;
            break;
        case kAlfrescoErrorCodeAuthorizationCodeInvalid:
            return kAlfrescoErrorDescriptionAuthorizationCodeInvalid;
            break;
        case kAlfrescoErrorCodeAccessTokenExpired:
            return kAlfrescoErrorDescriptionAccessTokenExpired;
            break;
        case kAlfrescoErrorCodeRefreshTokenExpired:
            return kAlfrescoErrorDescriptionRefreshTokenExpired;
            break;
            
        case kAlfrescoErrorCodeNoNetworkFound:
            return kAlfrescoErrorDescriptionNoNetworkFound;
            break;
        case kAlfrescoErrorCodeNetworkRequestCancelled:
            return kAlfrescoErrorDescriptionNetworkRequestCancelled;
            break;
        case kAlfrescoErrorCodeJSONParsing:
            return kAlfrescoErrorDescriptionJSONParsing;
            break;
        case kAlfrescoErrorCodeJSONParsingNilData:
            return kAlfrescoErrorDescriptionJSONParsingNilData;
            break;
        case kAlfrescoErrorCodeJSONParsingNoEntries:
            return kAlfrescoErrorDescriptionJSONParsingNoEntries;
            break;
        case kAlfrescoErrorCodeJSONParsingNoEntry:
            return kAlfrescoErrorDescriptionJSONParsingNoEntry;
            break;
        case kAlfrescoErrorCodeComment:
            return kAlfrescoErrorDescriptionComment;
            break;
        case kAlfrescoErrorCodeCommentNoCommentFound:
            return kAlfrescoErrorDescriptionCommentNoCommentFound;
            break;
        case kAlfrescoErrorCodeSites:
            return kAlfrescoErrorDescriptionSites;
            break;
        case kAlfrescoErrorCodeSitesNoDocLib:
            return kAlfrescoErrorDescriptionSitesNoDocLib;
            break;
        case kAlfrescoErrorCodeSitesNoSites:
            return kAlfrescoErrorDescriptionSitesNoSites;
            break;            
        case kAlfrescoErrorCodeActivityStream:
            return kAlfrescoErrorDescriptionActivityStream;
            break;
        case kAlfrescoErrorCodeActivityStreamNoActivities:
            return kAlfrescoErrorDescriptionActivityStreamNoActivities;
            break;
        case kAlfrescoErrorCodeDocumentFolder:
            return kAlfrescoErrorDescriptionDocumentFolder;
            break;
        case kAlfrescoErrorCodeDocumentFolderPermissions:
            return kAlfrescoErrorDescriptionDocumentFolderPermissions;
            break;
        case kAlfrescoErrorCodeDocumentFolderNodeAlreadyExists:
            return kAlfrescoErrorDescriptionDocumentFolderNodeAlreadyExists;
            break;
        case kAlfrescoErrorCodeDocumentFolderNoParent:
            return kAlfrescoErrorDescriptionDocumentFolderNoParent;
            break;
        case kAlfrescoErrorCodeDocumentFolderFailedToConvertNode:
            return kAlfrescoErrorDescriptionDocumentFolderFailedToConvertNode;
            break;
        case kAlfrescoErrorCodeDocumentFolderWrongNodeType:
            return kAlfrescoErrorDescriptionDocumentFolderWrongNodeType;
            break;
        case kAlfrescoErrorCodeDocumentFolderNoThumbnail:
            return kAlfrescoErrorDescriptionDocumentFolderNoThumbnail;
            break;
        case kAlfrescoErrorCodeTagging:
            return kAlfrescoErrorDescriptionTagging;
            break;
        case kAlfrescoErrorCodeTaggingNoTags:
            return kAlfrescoErrorDescriptionTaggingNoTags;
            break;
        case kAlfrescoErrorCodePerson:
            return kAlfrescoErrorDescriptionPerson;
            break;    
        case kAlfrescoErrorCodePersonNoAvatarFound:
            return kAlfrescoErrorDescriptionPersonNoAvatarFound;
            break;
        case kAlfrescoErrorCodePersonNotFound:
            return kAlfrescoErrorDescriptionPersonNotFound;
            break;
        case kAlfrescoErrorCodeSearch:
            return kAlfrescoErrorDescriptionSearch;
            break;
        case kAlfrescoErrorCodeRatings:
            return kAlfrescoErrorDescriptionRatings;
            break;
        case kAlfrescoErrorCodeRatingsNoRatings:
            return kAlfrescoErrorDescriptionRatingsNoRatings;
            break;
        default:
            return kAlfrescoErrorDescriptionUnknown;
            break;
    }
}

@end
