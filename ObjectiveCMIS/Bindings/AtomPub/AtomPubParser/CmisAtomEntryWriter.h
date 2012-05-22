//
// ObjectiveCMIS
//
// Created by Joram Barrez
//


#import <Foundation/Foundation.h>

@class CMISProperties;


@interface CMISAtomEntryWriter : NSObject

@property (nonatomic, strong) NSString *contentFilePath;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) CMISProperties *cmisProperties;

/**
 * If YES: the xml will be created and stored fully in-memory.
 * If NO: the xml will be streamed to a file on disk.
 *
 * Defaults to YES;
 */
@property BOOL generateXmlInMemory;

/**
* Generates the atom entry XML for the given properties on this class.
*
* NOTE: if <code>generateXmlInMemory</code> boolean is set to NO, a filepath pointing to a file
* containing the generated atom entry is returned.
* Callers are responsible to remove the file again if not needed anymore.
*
* If set to YES, the return value of this method is the XML is its whole.
*
*/
- (NSString *)generateAtomEntryXml;

@end