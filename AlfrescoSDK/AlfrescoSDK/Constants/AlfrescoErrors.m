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
NSString * const kAlfrescoErrorDescriptionNoRepositoryFound = @"No Alfresco repository found";
NSString * const kAlfrescoErrorDescriptionHttpResponseNotOk= @"Http response code was not Ok";
NSString * const kAlfrescoErrorDescriptionInvalidArgument = @"Invalid input parameter";
NSString * const kAlfrescoErrorDescriptionComment = @"Comment Service Error";
NSString * const kAlfrescoErrorDescriptionSites = @"Sites Service Error";
NSString * const kAlfrescoErrorDescriptionActivityStream =@"Activity Stream Service Error";
NSString * const kAlfrescoErrorDescriptionDocumentFolder = @"Document Folder Service Error";
NSString * const kAlfrescoErrorDescriptionTagging = @"Tagging Service Error";
NSString * const kAlfrescoErrorDescriptionPerson = @"Person Service Error";
NSString * const kAlfrescoErrorDescriptionSearch = @"Search Service Error";
NSString * const kAlfrescoErrorDescriptionNetwork = @"Cloud network/tenant Error";
NSString * const kAlfrescoErrorDescriptionRatings = @"Ratings Service Error";
NSString * const kAlfrescoErrorDescriptionJSONParsing = @"JSON Data parsing Error";

@interface AlfrescoErrors ()
+ (NSString *)localizedDescriptionForCode:(NSInteger)code;
@end

@implementation AlfrescoErrors
+ (NSError *)alfrescoError:(NSError *)error withAlfrescoErrorCode:(AlfrescoErrorCodes)code
{
    if (error == nil) {//shouldn't really get there
        return nil;
    }
    if ([error.domain isEqualToString:kAlfrescoErrorDomainName]) {
        return error;
    }
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
    [errorInfo setValue:[AlfrescoErrors localizedDescriptionForCode:code] forKey:NSLocalizedDescriptionKey];
    [errorInfo setObject:error forKey:NSUnderlyingErrorKey];
    return [NSError errorWithDomain:kAlfrescoErrorDomainName code:code userInfo:errorInfo];    
}

+ (NSError *)createAlfrescoErrorWithCode:(AlfrescoErrorCodes)code withDetailedDescription:(NSString *)detailedDescription
{
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
    [errorInfo setValue:[AlfrescoErrors localizedDescriptionForCode:code] forKey:NSLocalizedDescriptionKey];
    if (detailedDescription != nil) {
        [errorInfo setValue:detailedDescription forKey:NSLocalizedFailureReasonErrorKey];
    }
    
    return [NSError errorWithDomain:kAlfrescoErrorDomainName code:code userInfo:errorInfo];    
}

+ (NSString *)localizedDescriptionForCode:(NSInteger)code
{
    switch (code) {
        case kAlfrescoErrorCodeUnknown:
            return kAlfrescoErrorDescriptionUnknown;            
            break;
        case kAlfrescoErrorCodeNoRepositoryFound:
            return kAlfrescoErrorDescriptionNoRepositoryFound;
            break;
        case kAlfrescoErrorHttpResponseNotOk:
            return kAlfrescoErrorDescriptionHttpResponseNotOk;
            break;
        case kAlfrescoErrorInvalidArgument:
            return kAlfrescoErrorDescriptionInvalidArgument;
            break;
        case kAlfrescoErrorCodeComment:
            return kAlfrescoErrorDescriptionComment;
            break;
        case kAlfrescoErrorCodeSites:
            return kAlfrescoErrorDescriptionSites;
            break;
        case kAlfrescoErrorCodeActivityStream:
            return kAlfrescoErrorDescriptionActivityStream;
            break;
        case kAlfrescoErrorCodeDocumentFolder:
            return kAlfrescoErrorDescriptionDocumentFolder;
            break;
        case kAlfrescoErrorCodeTagging:
            return kAlfrescoErrorDescriptionTagging;
            break;
        case kAlfrescoErrorCodePerson:
            return kAlfrescoErrorDescriptionPerson;
            break;    
        case kAlfrescoErrorCodeSearch:
            return kAlfrescoErrorDescriptionSearch;
            break;
        case kAlfrescoErrorCodeNetwork:
            return kAlfrescoErrorDescriptionNetwork;
            break;
        case kAlfrescoErrorCodeRatings:
            return kAlfrescoErrorDescriptionRatings;
            break;
        case kAlfrescoErrorCodeJSONParsing:
            return kAlfrescoErrorDescriptionJSONParsing;
            break;
        default:
            return kAlfrescoErrorDescriptionUnknown;
            break;
    }
}

@end
