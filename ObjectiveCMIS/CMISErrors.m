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
//Basic Errors
NSString * const kCMISNoReturnErrorDescription = @"";//should be NULL?
NSString * const kCMISConnectionErrorDescription = @"Connection Error";
NSString * const kCMISProxyAuthenticationErrorDescription = @"Proxy Authentication Error";
NSString * const kCMISUnauthorizedErrorDescription = @"Unauthorized access error";

//General errors as defined in 2.2.1.4.1 of spec
NSString * const kCMISInvalidArgumentErrorDescription = @"Invalid Argument Error: One or more of the input parameters to the service method is missing or invalid";
NSString * const kCMISObjectNotFoundErrorDescription = @"Object Not Found Error: The service call has specified an object that does not exist in the repository";
NSString * const kCMISNotSupportedErrorDescription = @"Not supported Error: The service method invoked requires an optional capability not supported by the repository.";
NSString * const kCMISPermissionDeniedErrorDescription = @"Permission Denied Error: The caller of the service method does not have sufficient permissions to perform the operation";
NSString * const kCMISRuntimeErrorDescription = @"Runtime Error: Any other cause not expressible by another CMIS errors has occurred";

//Specific errors as defined in 2.2.1.4.2
NSString * const kCMISConstraintErrorDescription = @"Constraint Error: The operation violates a Repository- or Object-level constraint defined in the CMIS domain model.";
NSString * const kCMISContentAlreadyExistsErrorDescription = @"Content Already Exists Error: The operation attempts to set the content stream for a Document that already has a content stream without explicitly specifying the 'overwriteFlag' parameter.";
NSString * const kCMISFilterNotValidErrorDescription = @"Filter Not Valid Error: The property filter or rendition filter input to the operation is not valid.";
NSString * const kCMISNameConstraintViolationErrorDescription = @"Name Constraint Violation Error: The repository is not able to store the object that the user is creating/updating due to a name constraint violation.";
NSString * const kCMISStorageErrorDescription = @"Storage Error: The repository is not able to store the object that the user is creating/updating due to an internal storage problem.";
NSString * const kCMISStreamNotSupportedErrorDescription = @"Stream Not Supported Error: The operation is attempting to get or set a contentStream for a Document whose Object-type specifies that a content stream is not allowed for Document‟s of that type.";
NSString * const kCMISUpdateConflictErrorDescription = @"Update Conflict Error: The operation is attempting to update an object that is no longer current (as determined by the repository).";
NSString * const kCMISVersioningErrorDescription = @"Versioning Error: The operation is attempting to perform an action on a non-current version of a Document that cannot be performed on a non-current version.";
