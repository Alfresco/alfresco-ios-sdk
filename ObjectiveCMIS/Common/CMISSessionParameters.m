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

- (id)objectForKey:(id)key
{
    return [self.sessionData objectForKey:key];
}

- (id)objectForKey:(id)key withDefaultValue:(id)defaultValue
{
    NSObject *value = [self.sessionData objectForKey:key];
    return value != nil ? value : defaultValue;
}

- (void)setObject:(id)object forKey:(id)key
{
    [self.sessionData setObject:object forKey:key];
}

- (void)addEntriesFromDictionary:(NSDictionary *)dictionary
{
    [self.sessionData addEntriesFromDictionary:dictionary];
}

- (void)removeKey:(id)key
{
    [self.sessionData removeObjectForKey:key];
}


@end
