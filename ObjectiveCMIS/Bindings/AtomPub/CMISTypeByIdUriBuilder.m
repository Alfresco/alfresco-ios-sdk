//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISTypeByIdUriBuilder.h"

@interface CMISTypeByIdUriBuilder ()

@property (nonatomic, strong) NSString *templateUrl;

@end


@implementation CMISTypeByIdUriBuilder

@synthesize id = _id;
@synthesize templateUrl = _templateUrl;

- (id)initWithTemplateUrl:(NSString *)templateUrl
{
    self = [super init];
       if (self)
       {
           self.templateUrl = templateUrl;
       }
       return self;
}

- (NSURL *)buildUrl
{
    return [NSURL URLWithString:[self.templateUrl stringByReplacingOccurrencesOfString:@"{id}" withString:self.id]];
}


@end