//
//  AlfrescoBase64Encoder.h
//  RemoteAPI
//
//  Created by Tijs Rademakers on 02/05/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMISBase64Encoder : NSObject

+(NSString *)encode:(NSData *)plainText;

@end
