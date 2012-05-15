//
//  Created by Joram Barrez
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CMISQueryAtomEntryWriter : NSObject

@property (nonatomic, strong) NSString *statement;
@property BOOL searchAllVersions;
@property (nonatomic, strong) NSNumber * skipCount;
@property (nonatomic, strong) NSNumber * maxItems;

- (NSString *)generateAtomEntryXML;

@end