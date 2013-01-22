/*
 ******************************************************************************
 * Copyright (C) 2005-2012 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Mobile SDK.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *****************************************************************************
 */

#import "AlfrescoGDFileManager.h"
#import <GD/GDCReadStream.h>
#import "GD/GDFileSystem.h"
#import "AlfrescoConstants.h"

@implementation AlfrescoGDFileManager

static NSString * const kAlfrescoHomeDirectory = @"/";
static NSString * const kAlfrescoDocumentsFolder = @"Documents";
static NSString * const kAlfrescoTemporaryFolder = @"tmp";

- (NSString *)homeDirectory
{
    return kAlfrescoHomeDirectory;
}

- (NSString *)documentsDirectory
{
    NSString *documentsDirectory = [[self homeDirectory] stringByAppendingPathComponent:kAlfrescoDocumentsFolder];
    if (![self fileExistsAtPath:documentsDirectory])
    {
        [self createDirectoryAtPath:documentsDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return documentsDirectory;
}

- (NSString *)temporaryDirectory
{
    NSString *tempDirectory = [[self homeDirectory] stringByAppendingPathComponent:kAlfrescoTemporaryFolder];
    if (![self fileExistsAtPath:tempDirectory])
    {
        [self createDirectoryAtPath:tempDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return tempDirectory;
}

- (BOOL)fileExistsAtPath:(NSString *)path
{
    BOOL isDirectory = NO;
    return [GDFileSystem fileExistsAtPath:path isDirectory:&isDirectory];
}

- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory
{
    return [GDFileSystem fileExistsAtPath:path isDirectory:isDirectory];
}

- (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)data error:(NSError **)error
{
    return [GDFileSystem writeToFile:data name:path error:error];
}

- (BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes error:(NSError **)error
{
    return [GDFileSystem createDirectoryAtPath:path withIntermediateDirectories:createIntermediates attributes:attributes error:error];
}

- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error
{
    return [GDFileSystem removeItemAtPath:path error:error];
}

- (BOOL)copyItemAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError **)error
{
    // check to see if path is a folder
    if ([[self attributesOfItemAtPath:sourcePath error:error] objectForKey:kAlfrescoIsFolder])
    {
        return NO;
    }
    
    NSData *originalDataFile = [GDFileSystem readFromFile:sourcePath error:error];
    
    if (originalDataFile)
    {
        return [GDFileSystem writeToFile:originalDataFile name:destinationPath error:error];
    }
    
    return NO;
}

- (BOOL)moveItemAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError **)error
{
    return [GDFileSystem moveItemAtPath:sourcePath toPath:destinationPath error:error];
}

- (NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error
{
    GDFileStat fileStats;
    
    BOOL statsRecievedSuccessfully = [GDFileSystem getFileStat:path to:&fileStats error:error];
    
    if (statsRecievedSuccessfully)
    {
        return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedLong:fileStats.fileLen], kAlfrescoFileSize,
                [NSDate dateWithTimeIntervalSince1970:fileStats.lastModifiedTime], kAlfrescoFileLastModification,
                [NSNumber numberWithBool:fileStats.isFolder], kAlfrescoIsFolder,
                nil];
    }

    return nil;
}

- (NSArray *)contentsOfDirectoryAtPath:(NSString *)directoryPath error:(NSError **)error
{
    return [GDFileSystem contentsOfDirectoryAtPath:directoryPath error:error];
}

- (void)enumerateThroughDirectory:(NSString *)directory includingSubDirectories:(BOOL)includeSubDirectories error:(NSError **)error withBlock:(void (^)(NSString *fullFilePath))block
{
    // check to see if path is infact a folder
    if (![[[self attributesOfItemAtPath:directory error:nil] objectForKey:kAlfrescoIsFolder] boolValue])
    {
        return;
    }
    
    // get contents of the folder
    NSArray *contentsArray = [GDFileSystem contentsOfDirectoryAtPath:directory error:error];
    
    // for each object, do block logic
    for (NSString *filePath in contentsArray)
    {
        NSString *fullFilePath = [directory stringByAppendingPathComponent:filePath];
        if (![[[self attributesOfItemAtPath:fullFilePath error:nil] objectForKey:kAlfrescoIsFolder] boolValue] && ![filePath hasPrefix:@"."])
        {
            block(fullFilePath);
        }
        else if (includeSubDirectories)
        {
            [self enumerateThroughDirectory:fullFilePath includingSubDirectories:YES error:error withBlock:block];
        }
    }
    
}

- (NSData *)dataWithContentsOfURL:(NSURL *)url
{
    return [GDFileSystem readFromFile:[url path] error:nil];
}

- (void)appendToFileAtPath:(NSString *)filePath data:(NSData *)data
{
    NSInteger fileSize = [[[self attributesOfItemAtPath:filePath error:nil] objectForKey:kAlfrescoFileSize] intValue];
    
    [GDFileSystem writeToFile:data name:filePath fromOffset:fileSize error:nil];
}

- (NSString *)internalFilePathFromName:(NSString *)fileName
{
    return [[self temporaryDirectory] stringByAppendingPathComponent:fileName];
}

- (BOOL)fileStreamIsOpen:(NSStream *)stream
{
    BOOL isStreamOpen = NO;
    GDCWriteStream *writeStream = (GDCWriteStream *)stream;
    isStreamOpen = writeStream.streamError == nil;
    return isStreamOpen;
}

@end
