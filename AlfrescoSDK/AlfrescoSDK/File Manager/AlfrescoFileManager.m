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

#import "AlfrescoFileManager.h"
#import "AlfrescoPlaceholderFileManager.h"

@implementation AlfrescoFileManager

+ (id)alloc
{
    if (self == [AlfrescoFileManager self])
    {
        return [[AlfrescoPlaceholderFileManager alloc] init];
    }
    else
    {
        return [super alloc];
    }
}

+ (id)defaultManager
{
    static dispatch_once_t onceToken;
    static AlfrescoPlaceholderFileManager *placeholderFileManager = nil;
    
    dispatch_once(&onceToken, ^{
        placeholderFileManager = [[self alloc] init];
    });
    return placeholderFileManager;
}

- (NSString *)homeDirectory
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)documentsDirectory
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)temporaryDirectory
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (BOOL)fileExistsAtPath:(NSString *)path
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)data error:(NSError **)error
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary *)attributes error:(NSError **)error
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)copyItemAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError **)error
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (BOOL)moveItemAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath error:(NSError **)error
{
    [self doesNotRecognizeSelector:_cmd];
    return NO;
}

- (NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSArray *)contentsOfDirectoryAtPath:(NSString *)directoryPath error:(NSError **)error
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)enumerateThroughDirectory:(NSString *)directory includingSubDirectories:(BOOL)includeSubDirectories error:(NSError **)error withBlock:(void (^)(NSString *fullFilePath))block
{
    [self doesNotRecognizeSelector:_cmd];
}

- (NSData *)dataWithContentsOfURL:(NSURL *)url
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)appendToFileAtPath:(NSString *)filePath data:(NSData *)data
{
    [self doesNotRecognizeSelector:_cmd];
}

- (NSString *)internalFilePathFromName:(NSString *)fileName
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
