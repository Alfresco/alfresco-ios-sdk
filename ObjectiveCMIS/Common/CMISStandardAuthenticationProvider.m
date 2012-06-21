/*
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 */

#import "CMISBase64Encoder.h"
#import "CMISStandardAuthenticationProvider.h"

@interface CMISStandardAuthenticationProvider ()
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
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
    NSString *encodedLoginData = [CMISBase64Encoder stringByEncodingText:[loginString dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *authHeader = [NSString stringWithFormat:@"Basic %@", encodedLoginData];
    return [NSDictionary dictionaryWithObject:authHeader forKey:@"Authorization"];
}

@end
