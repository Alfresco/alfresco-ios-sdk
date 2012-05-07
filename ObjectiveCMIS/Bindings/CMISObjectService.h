//
//  CMISObjectService.h
//  ObjectiveCMIS
//
//  Created by Cornwell Gavin on 20/04/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISObjectData.h"

@class CMISDocument;

@protocol CMISObjectService <NSObject>

// Retrieves the object with the given object identifier
- (CMISObjectData *)retrieveObject:(NSString *)objectId error:(NSError **)error;

/**
* Downloads the content to a local file and returns the filepath.
* This is a synchronous call and will not return until the file is written to the given path.
*/
- (void)writeContentOfCMISObject:(NSString *)objectId toFile:(NSString *)filePath withError:(NSError * *)error;

/**
* uploads the file from the given path to the given folder.
*
* This is a synchronous call and will not return until the file is completely uploaded to the server.
*/
- (NSString *)createDocumentFromFilePath:(NSString *)filePath withProperties:(NSDictionary *)properties inFolder:(NSString *)folderObjectId error:(NSError * *)error;

/**
* Deletes the given object.
*
* The allVersions parameter is currently ignored.
*/
- (BOOL)deleteObject:(NSString *)objectId allVersions:(BOOL)allVersions error:(NSError * *)error;

@end
