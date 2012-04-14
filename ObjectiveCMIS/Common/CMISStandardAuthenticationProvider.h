//
//  CMISStandardAuthenticationProvider.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 10/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISAuthenticationProvider.h"

@interface CMISStandardAuthenticationProvider : NSObject <CMISAuthenticationProvider>

- (id)initWithUsername:(NSString *)username andPassword:(NSString *)password;

@end