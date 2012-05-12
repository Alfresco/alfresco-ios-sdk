//
// ObjectiveCMIS
//
// Created by Joram Barrez
//


#import <Foundation/Foundation.h>


@interface FileUtil : NSObject

+ (void)appendToFileAtPath:(NSString *)filePath data:(NSData *)data;

+ (long long)fileSizeForFileAtPath:(NSString *)filePath error:(NSError * *)outError;

@end