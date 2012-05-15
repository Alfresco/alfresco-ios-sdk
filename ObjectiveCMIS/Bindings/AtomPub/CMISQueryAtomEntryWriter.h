//
// Alfresco Focus
//
// Created by Joram Barrez
//


#import <Foundation/Foundation.h>


@interface CMISQueryAtomEntryWriter : NSObject

@property (nonatomic, strong) NSString *statement;
@property BOOL searchAllVersions;
@property (nonatomic, strong) NSNumber * skipCount;
@property (nonatomic, strong) NSNumber * maxItems;

- (NSString *)generateAtomEntryXML;

@end