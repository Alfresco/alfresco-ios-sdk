//
//  CMISExtensionElement.h
//  ObjectiveCMIS
//
//  Created by Gi Lee on 5/21/12.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMISExtensionElement : NSObject

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *namespaceUri;
@property (nonatomic, strong, readonly) NSString *value;
@property (nonatomic, strong, readonly) NSDictionary *attributes;
@property (nonatomic, strong, readonly) NSArray *children;

- (id)initNodeWithName:(NSString *)name namespaceUri:(NSString *)namespaceUri attributes:(NSDictionary *)attributesDict children:(NSArray *)children;
- (id)initLeafWithName:(NSString *)name namespaceUri:(NSString *)namespaceUri attributes:(NSDictionary *)attributesDict value:(NSString *)value;

// TODO GHL Should children be nil or empty array?
// TODO GHL Should attributes be bil or empty dictionary?
// TODO GHL Document me!!!

@end
