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
    kCMISBasicErrorMinimum = 0,
    kCMISBasicErrorMaximum = 255,

    //basic CMIS errors
    kCMISNoReturnErrorCode = 0,
    kCMISConnectionError = 1,
    kCMISProxyAuthenticationError = 2,
    kCMISUnauthorizedError = 3,
    
    //error ranges for General errors
    kCMISGeneralErrorMinimum = 256,
    kCMISGeneralErrorMaximum = 511,
    
    //General errors/exceptions as defined in 2.2.1.4.1
    kCMISInvalidArgumentError = 256,
    kCMISObjectNotFoundError = 257,
    kCMISNotSupportedError = 258,
    kCMISPermissionDeniedError = 259,
    kCMISRuntimeError = 260,
    
    
    //error ranges for CMIS specific errors
    kCMISSpecificErrorMinimum = 512,
    kCMISSpecificErrorMaximum = 1023,
    
    //Specific errors/exceptions as defined in 2.2.1.4.2
    kCMISConstraintError = 512,
    kCMISContentAlreadyExistsError = 513,
    kCMISFilterNotValidError = 514,
    kCMISNameConstraintViolationError = 515,
    kCMISStorageError = 516,
    kCMISStreamNotSupportedError = 517,
    kCMISUpdateConflictError = 518,
    kCMISVersioningError = 519
    
}CMISErrorCodes;

extern NSString * const kCMISErrorDomainName;
//to be used in the userInfo dictionary as Localized error description
//Basic Errors
extern NSString * const kCMISNoReturnErrorDescription;
extern NSString * const kCMISConnectionErrorDescription;
extern NSString * const kCMISProxyAuthenticationErrorDescription;
extern NSString * const kCMISUnauthorizedErrorDescription;
//General errors as defined in 2.2.1.4.1 of spec
extern NSString * const kCMISInvalidArgumentErrorDescription;
extern NSString * const kCMISObjectNotFoundErrorDescription;
extern NSString * const kCMISNotSupportedErrorDescription;
extern NSString * const kCMISPermissionDeniedErrorDescription;
extern NSString * const kCMISRuntimeErrorDescription;
//Specific errors as defined in 2.2.1.4.2
extern NSString * const kCMISConstraintErrorDescription;
extern NSString * const kCMISContentAlreadyExistsErrorDescription;
extern NSString * const kCMISFilterNotValidErrorDescription;
extern NSString * const kCMISNameConstraintViolationErrorDescription;
extern NSString * const kCMISStorageErrorDescription;
extern NSString * const kCMISStreamNotSupportedErrorDescription;
extern NSString * const kCMISUpdateConflictErrorDescription;
extern NSString * const kCMISVersioningErrorDescription;

