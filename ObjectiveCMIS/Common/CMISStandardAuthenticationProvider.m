//
//  CMISStandardAuthenticationProvider.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 10/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISStandardAuthenticationProvider.h"

@interface CMISStandardAuthenticationProvider ()
@property (nonatomic, strong, readwrite) NSString *username;
@property (nonatomic, strong, readwrite) NSString *password;
@end

@implementation CMISStandardAuthenticationProvider

@synthesize username = _username;
@synthesize password = _password;
@synthesize httpHeadersToApply = _httpHeadersToApply;


- (id)initWithUsername:(NSString *)username andPassword:(NSString *)password
{
    if (self = [super init]) 
    {
        self.username = username;
        self.password = password;
    }
    
    return self;
}

@end
