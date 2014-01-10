//
//  AlfrescoClientCertificateAuthenticationProvider.h
//  AlfrescoSDK
//
//  Created by Mohamad Saeedi on 09/12/2013.
//
//

#import "AlfrescoAuthenticationProvider.h"

@interface AlfrescoClientCertificateAuthenticationProvider : NSObject <AlfrescoAuthenticationProvider>

- (id)initWithUsername:(NSString *)username password:(NSString *)password credentials:(NSURLCredential *)credentials;

@end
