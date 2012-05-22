//
// ObjectiveCMIS
//
// Created by Joram Barrez
//


#import <Foundation/Foundation.h>
#import "CMISBindingSession.h"

@interface HTTPResponse : NSObject

@property (readonly) NSInteger statusCode;
@property (nonatomic, strong, readonly) NSData *data;

+ (HTTPResponse *)responseUsingURLHTTPResponse:(NSHTTPURLResponse *)HTTPURLResponse andData:(NSData *)data;

@end

@interface HttpUtil : NSObject

// Synchronous calls

+ (HTTPResponse *)invokeGETSynchronous:(NSURL *)url withSession:(CMISBindingSession *)session error:(NSError **)outError;

+ (HTTPResponse *)invokePOSTSynchronous:(NSURL *)url withSession:(CMISBindingSession *)session body:(NSData *)body error:(NSError **)outError;

+ (HTTPResponse *)invokePOSTSynchronous:(NSURL *)url withSession:(CMISBindingSession *)session body:(NSData *)body headers:(NSDictionary *)additionalHeaders error:(NSError **)outError;

+ (HTTPResponse *)invokePOSTSynchronous:(NSURL *)url withSession:(CMISBindingSession *)session bodyStream:(NSInputStream *)bodyStream headers:(NSDictionary *)additionalHeaders error:(NSError **)outError;

+ (HTTPResponse *)invokeDELETESynchronous:(NSURL *)url withSession:(CMISBindingSession *)session error:(NSError **)outError;

+ (HTTPResponse *)invokePUTSynchronous:(NSURL *)url withSession:(CMISBindingSession *)session bodyStream:(NSInputStream *)bodyStream headers:(NSDictionary *)additionalHeaders error:(NSError **)outError;

+ (HTTPResponse *)invokePUTSynchronous:(NSURL *)url withSession:(CMISBindingSession *)session body:(NSData *)body  headers:(NSDictionary *)additionalHeaders error:(NSError **)outError;

// Async calls

+ (void)invokeGETAsynchronous:(NSURL *)url withSession:(CMISBindingSession *)session withDelegate:(id<NSURLConnectionDataDelegate>)delegate;

@end
