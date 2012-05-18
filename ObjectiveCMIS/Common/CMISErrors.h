//
//  CMISErrors.h
//  ObjectiveCMIS
//
//  Created by Peter Schmidt on 11/05/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/FoundationErrors.h>
#import <Foundation/NSURLError.h>

//error types as defined in the CMIS spec
typedef enum
{
    //error range for basic errors - not covered in the spec but
    // present in the OpenCMIS Java lib
    kCMISErrorCodeBasicMinimum = 0,
    kCMISErrorCodeBasicMaximum = 255,

    //basic CMIS errors
    kCMISErrorCodeNoReturn = 0,
    kCMISErrorCodeConnection = 1,
    kCMISErrorCodeProxyAuthentication = 2,
    kCMISErrorCodeUnauthorized = 3,
    kCMISErrorCodeNoRootFolderFound = 4,
    kCMISErrorCodeNoRepositoryFound = 5,
    
    //error ranges for General errors
    kCMISErrorCodeGeneralMinimum = 256,
    kCMISErrorCodeGeneralMaximum = 511,
    
    //General errors/exceptions as defined in 2.2.1.4.1
    kCMISErrorCodeInvalidArgument = 256,
    kCMISErrorCodeObjectNotFound = 257,
    kCMISErrorCodeNotSupported = 258,
    kCMISErrorCodePermissionDenied = 259,
    kCMISErrorCodeRuntime = 260,
    
    
    //error ranges for CMIS specific errors
    kCMISErrorCodeSpecificMinimum = 512,
    kCMISErrorCodeSpecificMaximum = 1023,
    
    //Specific errors/exceptions as defined in 2.2.1.4.2
    kCMISErrorCodeConstraint = 512,
    kCMISErrorCodeContentAlreadyExists = 513,
    kCMISErrorCodeFilterNotValid = 514,
    kCMISErrorCodeNameConstraintViolation = 515,
    kCMISErrorCodeStorage = 516,
    kCMISErrorCodeStreamNotSupported = 517,
    kCMISErrorCodeUpdateConflict = 518,
    kCMISErrorCodeVersioning = 519
    
}CMISErrorCodes;


extern NSString * const kCMISErrorDomainName;
//to be used in the userInfo dictionary as Localized error description
//Basic Errors
extern NSString * const kCMISErrorDescriptionNoReturn;
extern NSString * const kCMISErrorDescriptionConnection;
extern NSString * const kCMISErrorDescriptionProxyAuthentication;
extern NSString * const kCMISErrorDescriptionUnauthorized;
extern NSString * const kCMISErrorDescriptionNoRootFolderFound;
extern NSString * const kCMISErrorDescriptionRepositoryNotFound;
//General errors as defined in 2.2.1.4.1 of spec
extern NSString * const kCMISErrorDescriptionInvalidArgument;
extern NSString * const kCMISErrorDescriptionObjectNotFound;
extern NSString * const kCMISErrorDescriptionNotSupported;
extern NSString * const kCMISErrorDescriptionPermissionDenied;
extern NSString * const kCMISErrorDescriptionRuntime;
//Specific errors as defined in 2.2.1.4.2
extern NSString * const kCMISErrorDescriptionConstraint;
extern NSString * const kCMISErrorDescriptionContentAlreadyExists;
extern NSString * const kCMISErrorDescriptionFilterNotValid;
extern NSString * const kCMISErrorDescriptionNameConstraintViolation;
extern NSString * const kCMISErrorDescriptionStorage;
extern NSString * const kCMISErrorDescriptionStreamNotSupported;
extern NSString * const kCMISErrorDescriptionUpdateConflict;
extern NSString * const kCMISErrorDescriptionVersioning;

@interface CMISErrors : NSObject
+ (NSError *)cmisError:(NSError * *)error withCMISErrorCode:(NSInteger)code;
+ (NSError *)createCMISErrorWithCode:(NSInteger)code withDetailedDescription:(NSString *)detailedDescription;
@end

