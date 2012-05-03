//
//  CMISAuthenticationProvider.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 10/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CMISAuthenticationProvider

@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSString *password;

/**
* Returns a set of HTTP headers (key-value pairs) that should be added to a
* HTTP call. This will be called by the AtomPub and the Web Services
* binding. You might want to check the binding in use before you set the
* headers.
*
* @return the HTTP headers or nil if no additional headers should be set
*/
@property(nonatomic, strong, readonly) NSDictionary *httpHeadersToApply;

@end
