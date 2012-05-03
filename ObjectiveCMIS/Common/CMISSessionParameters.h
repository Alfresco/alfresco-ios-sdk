//
//  CMISSessionParameters.h
//  HybridApp
//
//  Created by Cornwell Gavin on 22/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISEnums.h"
#import "CMISBinding.h"
#import "CMISAuthenticationProvider.h"
#import "CMISBindingSession.h"

@interface CMISSessionParameters : NSObject <CMISBindingSession>

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *repositoryId;
@property (nonatomic, strong) NSURL *atomPubUrl;

@property (nonatomic, assign, readonly) CMISBindingType bindingType;

- (id)initWithBindingType:(CMISBindingType)bindingType;

@end
