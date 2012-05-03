//
// Alfresco Focus
//
// Created by Joram Barrez
//

@protocol CMISAuthenticationProvider;

@protocol CMISBindingSession <NSObject>

@property (nonatomic, strong) id<CMISAuthenticationProvider> authenticationProvider;

// Session cache operations
- (NSArray *)allKeys;
- (NSObject *)objectForKey:(NSString *)key;
- (NSObject *)objectForKey:(NSString *)key withDefaultValue:(NSObject *)defaultValue;
- (void)setObject:(NSObject *)object forKey:(NSString *)key;
- (void)removeKey:(NSString *)key;

@end