//
//  CMISBindingSession.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 04/05/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISSessionParameters.h"
#import "CMISAuthenticationProvider.h"

extern NSString * const kCMISBindingSessionKeyAtomPubUrl;
extern NSString * const kCMISBindingSessionKeyObjectByIdUriBuilder;

@interface CMISBindingSession : NSObject

@property (nonatomic, strong, readonly) NSString *username;
@property (nonatomic, strong, readonly) NSString *repositoryId;
@property (nonatomic, strong, readonly) id<CMISAuthenticationProvider> authenticationProvider;

- (id)initWithSessionParameters:(CMISSessionParameters *)sessionParameters;

// Object storage methods
- (NSArray *)allKeys;
- (id)objectForKey:(id)key;
- (id)objectForKey:(id)key withDefaultValue:(id)defaultValue;
- (void)setObject:(id)object forKey:(id)key;
- (void)removeKey:(id)key;

@end
