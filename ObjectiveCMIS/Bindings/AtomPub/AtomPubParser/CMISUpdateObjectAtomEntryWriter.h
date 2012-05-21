//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMISProperties;


@interface CMISUpdateObjectAtomEntryWriter : NSObject

@property (nonatomic, strong) CMISProperties *properties;

- (NSString *)generateAtomEntryXml;

@end