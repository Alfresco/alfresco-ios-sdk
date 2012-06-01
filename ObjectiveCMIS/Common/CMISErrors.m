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

NSString * const kCMISErrorDescriptionNoReturn = @"ObjectiveCMIS.Common.CMISErrors.kCMISErrorDescriptionNoReturn";
NSString * const kCMISErrorDescriptionConnection = @"ObjectiveCMIS.Common.CMISErrors.kCMISErrorDescriptionConnection";
NSString * const kCMISErrorDescriptionProxyAuthentication = @"ObjectiveCMIS.Common.CMISErrors.kCMISErrorDescriptionProxyAuthentication";
NSString * const kCMISErrorDescriptionUnauthorized = @"ObjectiveCMIS.Common.CMISErrors.kCMISErrorDescriptionUnauthorized";
NSString * const kCMISErrorDescriptionNoRootFolderFound =  @"ObjectiveCMIS.Common.CMISErrors.kCMISErrorDescriptionNoRootFolderFound";
NSString * const kCMISErrorDescriptionRepositoryNotFound =  @"ObjectiveCMIS.Common.CMISErrors.kCMISErrorDescriptionRepositoryNotFound";

//General errors as defined in 2.2.1.4.1 of spec
NSString * const kCMISErrorDescriptionInvalidArgument = @"ObjectiveCMIS.Common.CMISErrors.kCMISErrorDescriptionInvalidArgument";
NSString * const kCMISErrorDescriptionObjectNotFound = @"ObjectiveCMIS.Common.CMISErrors.kCMISErrorDescriptionObjectNotFound";
NSString * const kCMISErrorDescriptionNotSupported = @"ObjectiveCMIS.Common.CMISErrors.kCMISErrorDescriptionNotSupported";
NSString * const kCMISErrorDescriptionPermissionDenied = @"ObjectiveCMIS.Common.CMISErrors.kCMISErrorDescriptionPermissionDenied";
NSString * const kCMISErrorDescriptionRuntime = @"ObjectiveCMIS.Common.CMISErrors.kCMISErrorDescriptionRuntime";

//Specific errors as defined in 2.2.1.4.2
NSString * const kCMISErrorDescriptionConstraint = @"ObjectiveCMIS.Common.CMISErrors.kCMISErrorDescriptionConstraint";
NSString * const kCMISErrorDescriptionContentAlreadyExists = @"ObjectiveCMIS.Common.CMISErrors.kCMISErrorDescriptionContentAlreadyExists";
NSString * const kCMISErrorDescriptionFilterNotValid = @"ObjectiveCMIS.Common.CMISErrors.kCMISErrorDescriptionFilterNotValid";
NSString * const kCMISErrorDescriptionNameConstraintViolation = @"ObjectiveCMIS.Common.CMISErrors.kCMISErrorDescriptionNameConstraintViolation";
NSString * const kCMISErrorDescriptionStorage = @"ObjectiveCMIS.Common.CMISErrors.kCMISErrorDescriptionStorage";
NSString * const kCMISErrorDescriptionStreamNotSupported = @"ObjectiveCMIS.Common.CMISErrors.kCMISErrorDescriptionStreamNotSupported";
NSString * const kCMISErrorDescriptionUpdateConflict = @"ObjectiveCMIS.Common.CMISErrors.kCMISErrorDescriptionUpdateConflict";
NSString * const kCMISErrorDescriptionVersioning = @"ObjectiveCMIS.Common.CMISErrors.kCMISErrorDescriptionVersioning";

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
            return NSLocalizedStringFromTable(kCMISErrorDescriptionNoReturn, @"ObjectiveCMISLocalizable", @"Unknown");
        case kCMISErrorCodeConnection:
            return NSLocalizedStringFromTable(kCMISErrorDescriptionConnection, @"ObjectiveCMISLocalizable", @"Connection error");
        case kCMISErrorCodeProxyAuthentication:
            return NSLocalizedStringFromTable(kCMISErrorDescriptionProxyAuthentication, @"ObjectiveCMISLocalizable", @"Proxy Auth. error");
        case kCMISErrorCodeUnauthorized:
            return NSLocalizedStringFromTable(kCMISErrorDescriptionUnauthorized, @"ObjectiveCMISLocalizable", @"Unauthorised");
        case kCMISErrorCodeNoRootFolderFound:
            return NSLocalizedStringFromTable(kCMISErrorDescriptionNoRootFolderFound, @"ObjectiveCMISLocalizable", @"No root folder");
        case kCMISErrorCodeNoRepositoryFound:
            return NSLocalizedStringFromTable(kCMISErrorDescriptionRepositoryNotFound, @"ObjectiveCMISLocalizable", @"No repository");
        case kCMISErrorCodeInvalidArgument:
            return NSLocalizedStringFromTable(kCMISErrorDescriptionInvalidArgument, @"ObjectiveCMISLocalizable", @"invalid argument");
        case kCMISErrorCodeObjectNotFound:
            return NSLocalizedStringFromTable(kCMISErrorDescriptionObjectNotFound, @"ObjectiveCMISLocalizable", @"object not found");
        case kCMISErrorCodeNotSupported:
            return NSLocalizedStringFromTable(kCMISErrorDescriptionNotSupported, @"ObjectiveCMISLocalizable", @"not supported");
        case kCMISErrorCodePermissionDenied:
            return NSLocalizedStringFromTable(kCMISErrorDescriptionPermissionDenied, @"ObjectiveCMISLocalizable", @"permission denied");
        case kCMISErrorCodeRuntime:
            return NSLocalizedStringFromTable(kCMISErrorDescriptionRuntime, @"ObjectiveCMISLocalizable", @"runtime error");
        case kCMISErrorCodeConstraint:
            return NSLocalizedStringFromTable(kCMISErrorDescriptionConstraint, @"ObjectiveCMISLocalizable", @"constraint error");
        case kCMISErrorCodeContentAlreadyExists:
            return NSLocalizedStringFromTable(kCMISErrorDescriptionContentAlreadyExists, @"ObjectiveCMISLocalizable", @"content already exists");
        case kCMISErrorCodeFilterNotValid:
            return NSLocalizedStringFromTable(kCMISErrorDescriptionFilterNotValid, @"ObjectiveCMISLocalizable", @"invalid filter");
        case kCMISErrorCodeNameConstraintViolation:
            return NSLocalizedStringFromTable(kCMISErrorDescriptionNameConstraintViolation, @"ObjectiveCMISLocalizable", @"constraint violation");
        case kCMISErrorCodeStorage:
            return NSLocalizedStringFromTable(kCMISErrorDescriptionStorage, @"ObjectiveCMISLocalizable", @"storage error");
        case kCMISErrorCodeStreamNotSupported:
            return NSLocalizedStringFromTable(kCMISErrorDescriptionStreamNotSupported, @"ObjectiveCMISLocalizable", @"stream not supported");
        case kCMISErrorCodeUpdateConflict:
            return NSLocalizedStringFromTable(kCMISErrorDescriptionUpdateConflict, @"ObjectiveCMISLocalizable", @"update conflict");
        case kCMISErrorCodeVersioning:
            return NSLocalizedStringFromTable(kCMISErrorDescriptionVersioning, @"ObjectiveCMISLocalizable", @"version error");
        default:
            return NSLocalizedStringFromTable(kCMISErrorDescriptionNoReturn, @"ObjectiveCMISLocalizable", @"Unknown");
    }
    
}

@end
