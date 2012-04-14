//
//  CMISSessionParameters.h
//  HybridApp
//
//  Created by Cornwell Gavin on 22/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISConstants.h"
#import "CMISBindingProtocols.h"

// TODO: Add mutable dictionary methods to allow arbitary objects to be added

@interface CMISSessionParameters : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *repositoryId;
@property (nonatomic, strong) NSURL *atomPubUrl;
@property (nonatomic, strong) id<CMISBindingDelegate> binding;
@property (nonatomic, strong) id<CMISAuthenticationProvider> authenticationProvider;

@property (nonatomic, assign, readonly) CMISBindingType bindingType;

- (id)initWithBindingType:(CMISBindingType)bindingType;

@end
