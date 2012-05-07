//
// Alfresco Focus
//
// Created by Joram Barrez
//


#import <Foundation/Foundation.h>
#import "CMISBindingSession.h"

@interface HttpUtil : NSObject

+ (NSData *)invokeGET:(NSURL *)url withSession:(CMISBindingSession *)session error:(NSError **)outError;

+ (NSData *)invokePOST:(NSURL *)url withSession:(CMISBindingSession *)session body:(NSData *)body error:(NSError **)outError;

+ (NSData *)invokePOST:(NSURL *)url withSession:(CMISBindingSession *)session body:(NSData *)body headers:(NSDictionary *)additionalHeaders error:(NSError **)outError;

+ (NSData *)invokeDELETE:(NSURL *)url withSession:(CMISBindingSession *)session error:(NSError **)outError;

@end