//
//  CMISStandardAuthenticationProvider.m
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 10/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISBase64Encoder.h"
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
    self = [super init];
    if (self)
    {
        self.username = username;
        self.password = password;
    }
    
    return self;
}

- (NSDictionary *)httpHeadersToApply
{
    NSMutableString *loginString = [NSMutableString stringWithFormat:@"%@:%@", self.username, self.password];
    NSString *encodedLoginData = [CMISBase64Encoder encode:[loginString dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *authHeader = [NSString stringWithFormat:@"Basic %@", encodedLoginData];
    return [NSDictionary dictionaryWithObject:authHeader forKey:@"Authorization"];
}

@end
