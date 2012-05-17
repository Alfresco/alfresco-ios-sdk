//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Simple wrapper class for parameters that are needed as input for a
 * certain operation, but which can also change as a result of executing
 * that operation.
 *
 * Used for example for operations with multiple return results.
 */
@interface CMISStringInOutParameter : NSObject

@property (nonatomic, strong) NSString *inParameter;
@property (nonatomic, strong) NSString *outParameter;

+ (CMISStringInOutParameter *)inOutParameterUsingInParameter:(NSString *)inParameter;

@end