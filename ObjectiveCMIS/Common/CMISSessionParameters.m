//
//  CMISSessionParameters.m
//  HybridApp
//
//  Created by Cornwell Gavin on 22/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISSessionParameters.h"

@interface CMISSessionParameters ()
@property (nonatomic, assign, readwrite) CMISBindingType bindingType;
@end

@implementation CMISSessionParameters

@synthesize username = _username;
@synthesize password = _password;
@synthesize repositoryId = _repositoryId;
@synthesize bindingType = _bindingType;
@synthesize atomPubUrl = _atomPubUrl;
@synthesize authenticationProvider = _authenticationProvider;

- (id)init
{
    return [self initWithBindingType:CMISBindingTypeAtomPub];
}

- (id)initWithBindingType:(CMISBindingType)bindingType
{
    if (self = [super init]) 
    {
        self.bindingType = bindingType;
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"bindingType: %@, username: %@, password: %@, atomPubUrl: %@", 
            self.bindingType, self.username, self.password, self.atomPubUrl];
}

@end
