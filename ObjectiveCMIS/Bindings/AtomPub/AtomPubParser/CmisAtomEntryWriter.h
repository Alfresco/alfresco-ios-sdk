//
// Alfresco Focus
//
// Created by Joram Barrez
//


#import <Foundation/Foundation.h>


@interface CMISAtomEntryWriter : NSObject

@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSDictionary *cmisProperties;

- (NSData *)generateAtomEntry;

@end