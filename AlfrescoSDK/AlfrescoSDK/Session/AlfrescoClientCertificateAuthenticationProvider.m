//
//  AlfrescoClientCertificateAuthenticationProvider.m
//  AlfrescoSDK
//
//  Created by Mohamad Saeedi on 09/12/2013.
//
//

#import "AlfrescoClientCertificateAuthenticationProvider.h"
#import "CMISBase64Encoder.h"

@interface AlfrescoClientCertificateAuthenticationProvider ()

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSURLCredential *credentials;
@property (nonatomic, strong, readwrite) NSMutableDictionary *httpHeaders;

@end

@implementation AlfrescoClientCertificateAuthenticationProvider

- (id)initWithUsername:(NSString *)username password:(NSString *)password credentials:(NSURLCredential *)credentials
{
    self = [super init];
    if(self)
    {
        self.username = username;
        self.password = password;
        self.credentials = credentials;
    }
    return self;
}

#pragma mark AlfrescoAuthenticationProvider Delegate methods

- (NSDictionary *)willApplyHTTPHeadersForSession:(id<AlfrescoSession>)session;
{
    if (self.httpHeaders == nil)
    {
        self.httpHeaders = [NSMutableDictionary dictionaryWithCapacity:1];
        
        // create a plaintext string in the format username:password
        NSMutableString *loginString = [NSMutableString stringWithFormat:@"%@:%@", self.username, self.password];
        
        // employ the Base64 encoding above to encode the authentication tokens
        NSString *encodedLoginData = [CMISBase64Encoder stringByEncodingText:[loginString dataUsingEncoding:NSUTF8StringEncoding]];
        
        // create the contents of the header
        NSString *authHeader = [NSString stringWithFormat:@"Basic %@", encodedLoginData];
        [self.httpHeaders setValue:authHeader forKey:@"Authorization"];
    }
    
    return self.httpHeaders;
}

@end
