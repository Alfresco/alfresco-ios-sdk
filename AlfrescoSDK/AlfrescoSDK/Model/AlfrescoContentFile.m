/*******************************************************************************
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
 ******************************************************************************/

#import "AlfrescoContentFile.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AlfrescoErrors.h"
#import <math.h>
#import "AlfrescoFileManager.h"
#import "AlfrescoConstants.h"

@interface AlfrescoContentFile ()
+ (NSString *) mimeTypeFromFilename:(NSString *)filename;
+ (NSString *) GUIDString;
@property (nonatomic, strong, readwrite) NSString *mimeType;
@property (nonatomic, assign, readwrite) unsigned long long length;
@property (nonatomic, strong, readwrite) NSURL *fileUrl;
@end

@implementation AlfrescoContentFile
@synthesize fileUrl = _fileUrl;
@synthesize mimeType = _mimeType;
@synthesize length = _length;

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithUrl:(NSURL *)url
{
    return [self initWithUrl:url mimeType:nil];
}


- (id)initWithUrl:(NSURL *)url mimeType:(NSString *)mimeType
{
    self = [super init];
    if (nil != self && nil != url)
    {
        
        NSString *filename = [url lastPathComponent];
        if (nil == mimeType)
        {
            self.mimeType = [AlfrescoContentFile mimeTypeFromFilename:filename];
        }
        else
        {
            self.mimeType = mimeType;
        }
        if ([url isFileReferenceURL])
        {
            self.fileUrl = url;
        }
        else
        {
            NSString *pathname = [[[AlfrescoFileManager sharedManager] temporaryDirectory] stringByAppendingPathComponent:filename];
            NSData *fileContent = [[AlfrescoFileManager sharedManager] dataWithContentsOfURL:url];
            
            NSURL *fileURL = [NSURL fileURLWithPath:pathname];
            [[AlfrescoFileManager sharedManager] createFileAtPath:[fileURL path] contents:fileContent error:nil];
            self.fileUrl = fileURL;
        }
        NSError *fileError = nil;
        NSDictionary *fileDictionary =  [[AlfrescoFileManager sharedManager] attributesOfItemAtPath:[self.fileUrl path] error:&fileError];
        self.length = [[fileDictionary valueForKey:kAlfrescoFileSize] unsignedLongLongValue];
    }
    return self;    
}


- (id)initWithData:(NSData *)data mimeType:(NSString *)mimeType
{
    self = [super init];
    if (nil != self)
    {
        NSString *tmpName = [AlfrescoContentFile GUIDString];
        self.mimeType = mimeType;
        if (nil != tmpName) 
        {
            NSURL *pathURL = [NSURL fileURLWithPath:[[[AlfrescoFileManager sharedManager] temporaryDirectory] stringByAppendingPathComponent:tmpName]];
            [[AlfrescoFileManager sharedManager] createFileAtPath:[pathURL path] contents:data error:nil];
            self.fileUrl = pathURL;
            self.length = data.length;
        }
    }
    return self;
}


#pragma mark - private methods
+ (NSString *)mimeTypeFromFilename:(NSString *)filename
{
    NSRange extensionRange = [filename rangeOfString:@"." options:NSBackwardsSearch];
    if (NSNotFound == extensionRange.location) 
    {
        return nil;
    }
    NSString *extension = [[filename substringFromIndex:extensionRange.location + 1] lowercaseString];
    // Get the UTI from the file's extension:
    CFStringRef pathExtension = (__bridge_retained CFStringRef)extension;
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension, NULL);
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);
    if (NULL != type) 
    {
        CFRelease(type);
    }
    if (NULL != pathExtension) 
    {
        CFRelease(pathExtension);
    }
    return mimeType;
}

+ (NSString *) GUIDString
{
    CFUUIDRef CFGUID = CFUUIDCreate(NULL);
    CFStringRef guidString = CFUUIDCreateString(NULL, CFGUID);
    if (NULL != CFGUID) 
    {
        CFRelease(CFGUID);
    }
    NSString *returnString = (__bridge NSString *)guidString;
    if (NULL != guidString)
    {
        CFRelease(guidString);
    }
    return returnString;
}


@end
