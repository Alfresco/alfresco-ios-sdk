//
//  CMISExtensionElement.m
//  ObjectiveCMIS
//
//  Created by Gi Lee on 5/21/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISExtensionElement.h"

@interface CMISExtensionElement ()

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *namespaceUri;
@property (nonatomic, strong, readwrite) NSString *value;
@property (nonatomic, strong, readwrite) NSDictionary *attributes;
@property (nonatomic, strong, readwrite) NSArray *children;

/** Designated Initializer.  This initializer is private since we do not want the user to use one of the two public init methods defined in the header
 */
- (id)initWithName:(NSString *)name namespaceUri:(NSString *)namespaceUri;
@end

@implementation CMISExtensionElement

@synthesize name = _name;
@synthesize namespaceUri = _namespaceUri;
@synthesize value = _value;
@synthesize attributes = _attributes;
@synthesize children = _children;

#pragma mark -
#pragma mark Initializers

- (id)initWithName:(NSString *)name namespaceUri:(NSString *)namespaceUri
{
    self = [super init];
    if (self)
    {
        self.name = name;
        self.namespaceUri = namespaceUri;
    }
    return self;
}

- (id)initNodeWithName:(NSString *)name namespaceUri:(NSString *)namespaceUri attributes:(NSDictionary *)attributesDict children:(NSArray *)children
{
    self = [self initWithName:name namespaceUri:namespaceUri];
    if (self)
    {
        self.value = nil;
        self.attributes = attributesDict;
        self.children = children;
    }
    return self;
}

- (id)initLeafWithName:(NSString *)name namespaceUri:(NSString *)namespaceUri attributes:(NSDictionary *)attributesDict value:(NSString *)value
{
    self = [self initWithName:name namespaceUri:namespaceUri];
    if (self)
    {
        self.value = value;
        self.attributes = attributesDict;
        self.children = nil;
    }
    return self;
}

#pragma mark - 
#pragma mark NSObject Overrides

- (NSString *)description
{
    return [NSString stringWithFormat:@"CMISExtensionElement: {%@}%@ %@:%@", 
            self.namespaceUri, self.name, self.attributes, self.children];
}


@end
