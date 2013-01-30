/*
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>
typedef enum {
    HTTP_GET,
    HTTP_POST,
    HTTP_PUT,
    HTTP_DELETE
} CMISHttpRequestMethod;

@class CMISBindingSession, CMISRequest, CMISHttpResponse;


@protocol CMISNetworkProvider <NSObject>

- (void)invoke:(NSURL *)url
withHttpMethod:(CMISHttpRequestMethod)httpRequestMethod
   withSession:(CMISBindingSession *)session
          body:(NSData *)body
       headers:(NSDictionary *)additionalHeaders
completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock;

- (void)invoke:(NSURL *)url
withHttpMethod:(CMISHttpRequestMethod)httpRequestMethod
   withSession:(CMISBindingSession *)session
   inputStream:(NSInputStream *)inputStream
       headers:(NSDictionary *)additionalHeaders
completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock;


- (void)invoke:(NSURL *)url withHttpMethod:(CMISHttpRequestMethod)httpRequestMethod
   withSession:(CMISBindingSession *)session
   inputStream:(NSInputStream *)inputStream
       headers:(NSDictionary *)additionalHeaders
 bytesExpected:(unsigned long long)bytesExpected
completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
 progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
 requestObject:(CMISRequest *)requestObject;

- (void)invoke:(NSURL *)url
withHttpMethod:(CMISHttpRequestMethod)httpRequestMethod
   withSession:(CMISBindingSession *)session
  outputStream:(NSOutputStream *)outputStream
 bytesExpected:(unsigned long long)bytesExpected
completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
 progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
 requestObject:(CMISRequest*)requestObject;



- (void)invokeGET:(NSURL *)url
      withSession:(CMISBindingSession *)session
  completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock;


- (void)invokePOST:(NSURL *)url
       withSession:(CMISBindingSession *)session
              body:(NSData *)body
           headers:(NSDictionary *)additionalHeaders
   completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock;

- (void)invokePUT:(NSURL *)url
      withSession:(CMISBindingSession *)session
             body:(NSData *)body
          headers:(NSDictionary *)additionalHeaders
  completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock;

- (void)invokeDELETE:(NSURL *)url
         withSession:(CMISBindingSession *)session
     completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock;



@end
