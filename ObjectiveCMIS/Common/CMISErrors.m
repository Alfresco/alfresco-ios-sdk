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

#import "CMISErrors.h"

NSString * const kCMISErrorDomainName = @"org.apache.chemistry.objectivecmis";
//to be used in the userInfo dictionary as Localized error description

/**
 Note, the string definitions below should not be used by themselves. Rather, they should be used to 
 obtain the localized string. Therefore, the proper use in the code would be e.g.
 NSLocalizedString(kCMISNoReturnErrorDescription,kCMISNoReturnErrorDescription)
 (the second parameter in NSLocalizedString is a Comment and may be set to nil)
 */
//Basic Errors

NSString * const kCMISErrorDescriptionNoReturn = @"Unknown Error";
NSString * const kCMISErrorDescriptionConnection = @"Connection Error";
NSString * const kCMISErrorDescriptionProxyAuthentication = @"Proxy Authentication Error";
NSString * const kCMISErrorDescriptionUnauthorized = @"Unauthorized access error";
NSString * const kCMISErrorDescriptionNoRootFolderFound =  @"Root Folder Not Found Error";
NSString * const kCMISErrorDescriptionRepositoryNotFound =  @"Repository Not Found Error";

//General errors as defined in 2.2.1.4.1 of spec
NSString * const kCMISErrorDescriptionInvalidArgument = @"Invalid Argument Error";
NSString * const kCMISErrorDescriptionObjectNotFound = @"Object Not Found Error";
NSString * const kCMISErrorDescriptionNotSupported = @"Not supported Error";
NSString * const kCMISErrorDescriptionPermissionDenied = @"Permission Denied Error";
NSString * const kCMISErrorDescriptionRuntime = @"Runtime Error";

//Specific errors as defined in 2.2.1.4.2
NSString * const kCMISErrorDescriptionConstraint = @"Constraint Error";
NSString * const kCMISErrorDescriptionContentAlreadyExists = @"Content Already Exists Error";
NSString * const kCMISErrorDescriptionFilterNotValid = @"Filter Not Valid Error";
NSString * const kCMISErrorDescriptionNameConstraintViolation = @"Name Constraint Violation Error";
NSString * const kCMISErrorDescriptionStorage = @"Storage Error";
NSString * const kCMISErrorDescriptionStreamNotSupported = @"Stream Not Supported Error";
NSString * const kCMISErrorDescriptionUpdateConflict = @"Update Conflict Error";
NSString * const kCMISErrorDescriptionVersioning = @"Versioning Error";

@interface CMISErrors ()
+ (NSString *)localizedDescriptionForCode:(CMISErrorCodes)code;
@end

@implementation CMISErrors

+ (NSError *)cmisError:(NSError * *)error withCMISErrorCode:(CMISErrorCodes)code
{
    if (!error && error == NULL && *error == nil) {//shouldn't really get there
        return nil;
    }
    if ([[*error domain] isEqualToString:kCMISErrorDomainName]) {
        return *error;
    }
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
    [errorInfo setValue:[CMISErrors localizedDescriptionForCode:code] forKey:NSLocalizedDescriptionKey];
    [errorInfo setObject:*error forKey:NSUnderlyingErrorKey];
    return [NSError errorWithDomain:kCMISErrorDomainName code:code userInfo:errorInfo];
}

+ (NSError *)createCMISErrorWithCode:(CMISErrorCodes)code withDetailedDescription:(NSString *)detailedDescription
{
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
    [errorInfo setValue:[CMISErrors localizedDescriptionForCode:code] forKey:NSLocalizedDescriptionKey];
    if (detailedDescription != nil) {
        [errorInfo setValue:detailedDescription forKey:NSLocalizedFailureReasonErrorKey];
    }
    
    return [NSError errorWithDomain:kCMISErrorDomainName code:code userInfo:errorInfo];
}

+ (NSString *)localizedDescriptionForCode:(CMISErrorCodes)code
{
    switch (code) {
        case kCMISErrorCodeNoReturn:
            return kCMISErrorDescriptionNoReturn;
        case kCMISErrorCodeConnection:
            return kCMISErrorDescriptionConnection;
        case kCMISErrorCodeProxyAuthentication:
            return kCMISErrorDescriptionProxyAuthentication;
        case kCMISErrorCodeUnauthorized:
            return kCMISErrorDescriptionUnauthorized;
        case kCMISErrorCodeNoRootFolderFound:
            return kCMISErrorDescriptionNoRootFolderFound;
        case kCMISErrorCodeNoRepositoryFound:
            return kCMISErrorDescriptionRepositoryNotFound;
        case kCMISErrorCodeInvalidArgument:
            return kCMISErrorDescriptionInvalidArgument;
        case kCMISErrorCodeObjectNotFound:
            return kCMISErrorDescriptionObjectNotFound;
        case kCMISErrorCodeNotSupported:
            return kCMISErrorDescriptionNotSupported;
        case kCMISErrorCodePermissionDenied:
            return kCMISErrorDescriptionPermissionDenied;
        case kCMISErrorCodeRuntime:
            return kCMISErrorDescriptionRuntime;
        case kCMISErrorCodeConstraint:
            return kCMISErrorDescriptionConstraint;
        case kCMISErrorCodeContentAlreadyExists:
            return kCMISErrorDescriptionContentAlreadyExists;
        case kCMISErrorCodeFilterNotValid:
            return kCMISErrorDescriptionFilterNotValid;
        case kCMISErrorCodeNameConstraintViolation:
            return kCMISErrorDescriptionNameConstraintViolation;
        case kCMISErrorCodeStorage:
            return kCMISErrorDescriptionStorage;
        case kCMISErrorCodeStreamNotSupported:
            return kCMISErrorDescriptionStreamNotSupported;
        case kCMISErrorCodeUpdateConflict:
            return kCMISErrorDescriptionUpdateConflict;
        case kCMISErrorCodeVersioning:
            return kCMISErrorDescriptionVersioning;
        default:
            return kCMISErrorDescriptionNoReturn;
    }
    
}

@end
