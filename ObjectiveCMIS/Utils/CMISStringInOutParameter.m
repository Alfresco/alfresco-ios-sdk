//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISStringInOutParameter.h"


@implementation CMISStringInOutParameter

@synthesize inParameter = _inParameter;
@synthesize outParameter = _outParameter;

+ (CMISStringInOutParameter *)inOutParameterUsingInParameter:(NSString *)inParameter
{
    CMISStringInOutParameter *result = [[CMISStringInOutParameter alloc] init];
    result.inParameter = inParameter;
    return result;
}


@end