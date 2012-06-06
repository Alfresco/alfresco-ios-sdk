//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISURLUtil.h"


@implementation CMISURLUtil

+ (NSString *)urlStringByAppendingParameter:(NSString *)parameterName withValue:(NSString *)parameterValue toUrlString:(NSString *)urlString
{
    if (parameterName == nil || parameterValue == nil)
    {
        return urlString;
    }

    NSMutableString *result = [NSMutableString stringWithString:urlString];

    // Append '?' if not yet in url, else append ampersand
    if ([result rangeOfString:@"?"].location == NSNotFound)
    {
        [result appendString:@"?"];
    }
    else
    {
        [result appendString:@"&"];
    }

    // Append param
    [result appendString:parameterName];
    [result appendString:@"="];
    [result appendString:[parameterValue stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];

    return result;
}

+ (NSURL *)urlStringByAppendingParameter:(NSString *)parameterName withValue:(NSString *)parameterValue toUrl:(NSURL *)url
{
    return [NSURL URLWithString:[CMISURLUtil urlStringByAppendingParameter:parameterName withValue:parameterValue toUrlString:[url absoluteString]]];
}

@end