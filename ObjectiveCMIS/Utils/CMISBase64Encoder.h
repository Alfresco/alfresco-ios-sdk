//
//  AlfrescoBase64Encoder.h
//  RemoteAPI
//
//  Created by Tijs Rademakers on 02/05/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMISBase64Encoder : NSObject

+ (NSString *)stringByEncodingText:(NSData *)plainText;

+ (NSData *)dataByEncodingText:(NSData *)plainText;

+ (NSString *)encodeContentOfFile:(NSString *)sourceFilePath;

+ (void)encodeContentOfFile:(NSString *)sourceFilePath andAppendToFile:(NSString *)destinationFilePath;

@end
