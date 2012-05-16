//
//  CMISErrors.m
//  ObjectiveCMIS
//
//  Created by Peter Schmidt on 11/05/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISErrors.h"

NSString * const kCMISErrorDomainName = @"org.apache.chemistry.opencmis";
//to be used in the userInfo dictionary as Localized error description

/**
 Note, the string definitions below should not be used by themselves. Rather, they should be used to 
 obtain the localized string. Therefore, the proper use in the code would be e.g.
 NSLocalizedString(kCMISNoReturnErrorDescription,kCMISNoReturnErrorDescription)
 (the second parameter in NSLocalizedString is a Comment and may be set to nil)
 */
//Basic Errors

NSString * const kCMISNoReturnErrorDescription = @"Unknown Error";
NSString * const kCMISConnectionErrorDescription = @"Connection Error";
NSString * const kCMISProxyAuthenticationErrorDescription = @"Proxy Authentication Error";
NSString * const kCMISUnauthorizedErrorDescription = @"Unauthorized access error";
NSString * const kCMISNoRootFolderFoundErrorDescription =  @"Root Folder Not Found Error";
NSString * const kCMISRepositoryNotFoundErrorDescription =  @"Repository Not Found Error";

//General errors as defined in 2.2.1.4.1 of spec
NSString * const kCMISInvalidArgumentErrorDescription = @"Invalid Argument Error";
NSString * const kCMISObjectNotFoundErrorDescription = @"Object Not Found Error";
NSString * const kCMISNotSupportedErrorDescription = @"Not supported Error";
NSString * const kCMISPermissionDeniedErrorDescription = @"Permission Denied Error";
NSString * const kCMISRuntimeErrorDescription = @"Runtime Error";

//Specific errors as defined in 2.2.1.4.2
NSString * const kCMISConstraintErrorDescription = @"Constraint Error";
NSString * const kCMISContentAlreadyExistsErrorDescription = @"Content Already Exists Error";
NSString * const kCMISFilterNotValidErrorDescription = @"Filter Not Valid Error";
NSString * const kCMISNameConstraintViolationErrorDescription = @"Name Constraint Violation Error";
NSString * const kCMISStorageErrorDescription = @"Storage Error";
NSString * const kCMISStreamNotSupportedErrorDescription = @"Stream Not Supported Error";
NSString * const kCMISUpdateConflictErrorDescription = @"Update Conflict Error";
NSString * const kCMISVersioningErrorDescription = @"Versioning Error";

@implementation CMISErrors

+ (NSError *)cmisError:(NSError * *)error withCMISErrorCode:(NSInteger)code withCMISLocalizedDescription:(NSString *)localizedDescription
{
    if ([[*error domain] isEqualToString:kCMISErrorDomainName]) {
        return *error;
    }
    NSMutableDictionary *errorInfo = [NSMutableDictionary dictionary];
    [errorInfo setValue:localizedDescription forKey:NSLocalizedDescriptionKey];
    if (error && error != NULL && *error != nil) {
        [errorInfo setObject:*error forKey:NSUnderlyingErrorKey];
    }
    return [NSError errorWithDomain:kCMISErrorDomainName code:code userInfo:errorInfo];
}


@end
