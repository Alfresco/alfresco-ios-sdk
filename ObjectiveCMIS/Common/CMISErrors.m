//
//  CMISErrors.m
//  ObjectiveCMIS
//
//  Created by Peter Schmidt on 11/05/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

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
+ (NSString *)localizedDescriptionForCode:(NSInteger)code;
@end

@implementation CMISErrors

+ (NSError *)cmisError:(NSError * *)error withCMISErrorCode:(NSInteger)code
{
    if (!error && error == NULL && *error == nil) {//shouldn't really get there
        return nil;
    }
    if ([[*error domain] isEqualToString:kCMISErrorDomainName]) {
        return *error;
    }
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
    [errorInfo setValue:[self localizedDescriptionForCode:code] forKey:NSLocalizedDescriptionKey];
    [errorInfo setObject:*error forKey:NSUnderlyingErrorKey];
    return [NSError errorWithDomain:kCMISErrorDomainName code:code userInfo:errorInfo];
}

+ (NSError *)createCMISErrorWithCode:(NSInteger)code withDetailedDescription:(NSString *)detailedDescription
{
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
    [errorInfo setValue:[self localizedDescriptionForCode:code] forKey:NSLocalizedDescriptionKey];
    if (detailedDescription != nil) {
        [errorInfo setValue:detailedDescription forKey:NSLocalizedFailureReasonErrorKey];
    }
    
    return [NSError errorWithDomain:kCMISErrorDomainName code:code userInfo:errorInfo];
}

+ (NSString *)localizedDescriptionForCode:(NSInteger)code
{
    switch (code) {
        case kCMISErrorCodeNoReturn:
            return NSLocalizedString(kCMISErrorDescriptionNoReturn, kCMISErrorDescriptionNoReturn);
        case kCMISErrorCodeConnection:
            return NSLocalizedString(kCMISErrorDescriptionConnection, kCMISErrorDescriptionConnection);
        case kCMISErrorCodeProxyAuthentication:
            return NSLocalizedString(kCMISErrorDescriptionProxyAuthentication, kCMISErrorDescriptionProxyAuthentication);
        case kCMISErrorCodeUnauthorized:
            return NSLocalizedString(kCMISErrorDescriptionUnauthorized, kCMISErrorDescriptionUnauthorized);
        case kCMISErrorCodeNoRootFolderFound:
            return NSLocalizedString(kCMISErrorDescriptionNoRootFolderFound, kCMISErrorDescriptionNoRootFolderFound);
        case kCMISErrorCodeNoRepositoryFound:
            return NSLocalizedString(kCMISErrorDescriptionRepositoryNotFound, kCMISErrorDescriptionRepositoryNotFound);
        case kCMISErrorCodeInvalidArgument:
            return NSLocalizedString(kCMISErrorDescriptionInvalidArgument, kCMISErrorDescriptionInvalidArgument);
        case kCMISErrorCodeObjectNotFound:
            return NSLocalizedString(kCMISErrorDescriptionObjectNotFound, kCMISErrorDescriptionObjectNotFound);
        case kCMISErrorCodeNotSupported:
            return NSLocalizedString(kCMISErrorDescriptionNotSupported, kCMISErrorDescriptionNotSupported);
        case kCMISErrorCodePermissionDenied:
            return NSLocalizedString(kCMISErrorDescriptionPermissionDenied, kCMISErrorDescriptionPermissionDenied);
        case kCMISErrorCodeRuntime:
            return NSLocalizedString(kCMISErrorDescriptionRuntime, kCMISErrorDescriptionRuntime);
        case kCMISErrorCodeConstraint:
            return NSLocalizedString(kCMISErrorDescriptionConstraint, kCMISErrorDescriptionConstraint);
        case kCMISErrorCodeContentAlreadyExists:
            return NSLocalizedString(kCMISErrorDescriptionContentAlreadyExists, kCMISErrorDescriptionContentAlreadyExists);
        case kCMISErrorCodeFilterNotValid:
            return NSLocalizedString(kCMISErrorDescriptionFilterNotValid, kCMISErrorDescriptionFilterNotValid);
        case kCMISErrorCodeNameConstraintViolation:
            return NSLocalizedString(kCMISErrorDescriptionNameConstraintViolation, kCMISErrorDescriptionNameConstraintViolation);
        case kCMISErrorCodeStorage:
            return NSLocalizedString(kCMISErrorDescriptionStorage, kCMISErrorDescriptionStorage);
        case kCMISErrorCodeStreamNotSupported:
            return NSLocalizedString(kCMISErrorDescriptionStreamNotSupported, kCMISErrorDescriptionStreamNotSupported);
        case kCMISErrorCodeUpdateConflict:
            return NSLocalizedString(kCMISErrorDescriptionUpdateConflict, kCMISErrorDescriptionUpdateConflict);
        case kCMISErrorCodeVersioning:
            return NSLocalizedString(kCMISErrorDescriptionVersioning, kCMISErrorDescriptionVersioning);
        default:
            return NSLocalizedString(kCMISErrorDescriptionNoReturn, kCMISErrorDescriptionNoReturn);
    }
    
}

@end
