//
// Alfresco Focus
//
// Created by Joram Barrez
//


#import <Foundation/Foundation.h>
#import "CMISBindingSession.h"

@interface HttpUtil : NSObject

+ (NSData *)invokeGET:(NSURL *)url withSession:(CMISBindingSession *)session error:(NSError **)outError;

@end