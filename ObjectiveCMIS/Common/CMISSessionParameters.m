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
@property (nonatomic, strong, readwrite) NSMutableDictionary *sessionData;
@end

@implementation CMISSessionParameters

@synthesize username = _username;
@synthesize password = _password;
@synthesize repositoryId = _repositoryId;
@synthesize bindingType = _bindingType;
@synthesize atomPubUrl = _atomPubUrl;
@synthesize authenticationProvider = _authenticationProvider;
@synthesize sessionData = _sessionData;

- (id)init
{
    self.sessionData = [[NSMutableDictionary alloc] init];
    return [self initWithBindingType:CMISBindingTypeAtomPub];
}

- (id)initWithBindingType:(CMISBindingType)bindingType
{
    self = [super init];
    if (self)
    {
        self.sessionData = [[NSMutableDictionary alloc] init];
        self.bindingType = bindingType;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"bindingType: %@, username: %@, password: %@, atomPubUrl: %@", 
            self.bindingType, self.username, self.password, self.atomPubUrl];
}

- (NSArray *)allKeys
{
    return [self.sessionData allKeys];
}

- (NSObject *)objectForKey:(NSString *)key
{
    return [self.sessionData objectForKey:key];
}

- (NSObject *)objectForKey:(NSString *)key withDefaultValue:(NSObject *)defaultValue
{
    NSObject *value = [self.sessionData objectForKey:key];
    return value != nil ? value : defaultValue;
}

- (void)setObject:(NSObject *)object forKey:(NSString *)key
{
    [self.sessionData setObject:object forKey:key];
}

- (void)removeKey:(NSString *)key
{
    [self.sessionData removeObjectForKey:key];
}


@end
