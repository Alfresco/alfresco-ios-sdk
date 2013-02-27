//
//  CMISBase64InputStream.h
//  ObjectiveCMIS
//
//  Created by Peter Schmidt on 22/02/2013.
//  Copyright (c) 2013 Apache Software Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMISProperties.h"

@interface CMISBase64InputStream : NSInputStream <NSStreamDelegate>
@property (nonatomic, assign, readonly) NSUInteger encodedBytes;
- (id)initWithInputStream:(NSInputStream *)nonEncodedStream
           cmisProperties:(CMISProperties *)cmisProperties
                 mimeType:(NSString *)mimeType
          nonEncodedBytes:(NSUInteger)nonEncodedBytes;

@end
