//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CMISURLUtil : NSObject

+ (NSString *)urlStringByAppendingParameter:(NSString *)parameterName withValue:(NSString *)parameterValue toUrlString:(NSString *)urlString;

+ (NSURL *)urlStringByAppendingParameter:(NSString *)parameterName withValue:(NSString *)parameterValue toUrl:(NSURL *)url;

@end