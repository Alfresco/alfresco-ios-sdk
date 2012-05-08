//
// Alfresco Focus
//
// Created by Joram Barrez
//


#import <Foundation/Foundation.h>


@interface CMISAtomEntryWriter : NSObject

@property (nonatomic, strong) NSString *contentFilePath;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSDictionary *cmisProperties;

/**
* Returns a filepath pointing to a file containing the generated atom entry.
*
* Callers are responsible to remove the file again if not needed anymore.
*/
- (NSString *)filePathToGeneratedAtomEntry;

@end