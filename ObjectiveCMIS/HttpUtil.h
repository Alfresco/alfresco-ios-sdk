//
// Alfresco Focus
//
// Created by Joram Barrez
//


#import <Foundation/Foundation.h>

@protocol CMISBindingSession;


@interface HttpUtil : NSObject

+ (NSData *)invokeGET:(NSURL *)url withSession:(id<CMISBindingSession>)session error:(NSError **)outError;

@end