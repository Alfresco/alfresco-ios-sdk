//
//  CMISDocument.h
//  HybridApp
//
//  Created by Cornwell Gavin on 29/02/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import "CMISFileableObject.h"

@interface CMISDocument : CMISFileableObject <NSURLConnectionDataDelegate>

@property (nonatomic, strong, readonly) NSString *contentStreamId;
@property (nonatomic, strong, readonly) NSURL *contentURL;

/**
* Downloads the content to a local file and returns the filepath.
* This is a synchronous call and will not return until the file is written to the given path.
*/
- (void)writeContentToFile:(NSString *)filePath withError:(NSError * *)error;

/**
* Deletes the document from the document store.
*/
- (BOOL)deleteAllVersionsAndReturnError:(NSError **)error;

@end
