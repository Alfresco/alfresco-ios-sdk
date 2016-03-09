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

#import "CMISDefaultNetworkProvider.h"
#import "CMISErrors.h"
#import "CMISHttpRequest.h"
#import "CMISHttpDownloadRequest.h"
#import "CMISHttpUploadRequest.h"
#import "CMISLog.h"

@interface CMISDefaultNetworkProvider ()
+ (NSMutableURLRequest *)createRequestForUrl:(NSURL *)url
                                  httpMethod:(CMISHttpRequestMethod)httpRequestMethod
                                     session:(CMISBindingSession *)session;
@end

@implementation CMISDefaultNetworkProvider
#pragma mark block based methods


- (void)invoke:(NSURL *)url
    httpMethod:(CMISHttpRequestMethod)httpRequestMethod
       session:(CMISBindingSession *)session
          body:(NSData *)body
       headers:(NSDictionary *)additionalHeaders
   cmisRequest:(CMISRequest *)cmisRequest
completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
{
    NSMutableURLRequest *urlRequest = [CMISDefaultNetworkProvider createRequestForUrl:url
                                                                           httpMethod:httpRequestMethod
                                                                              session:session];
    if (!cmisRequest.isCancelled)
    {
        CMISHttpRequest* request = [CMISHttpRequest startRequest:urlRequest
                                                      httpMethod:httpRequestMethod
                                                     requestBody:body
                                                         headers:additionalHeaders
                                          authenticationProvider:session.authenticationProvider
                                                 completionBlock:completionBlock];
        if (request)
        {
            cmisRequest.httpRequest = request;
        }
    } else {
        if (completionBlock) {
            completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeCancelled
                                                 detailedDescription:@"Request was cancelled"]);
        }
    }
}

- (void)invoke:(NSURL *)url
    httpMethod:(CMISHttpRequestMethod)httpRequestMethod
       session:(CMISBindingSession *)session
   inputStream:(NSInputStream *)inputStream
       headers:(NSDictionary *)additionalHeaders
   cmisRequest:(CMISRequest *)cmisRequest
completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
{
    if (!cmisRequest.isCancelled) {
        NSMutableURLRequest *urlRequest = [CMISDefaultNetworkProvider createRequestForUrl:url
                                                                               httpMethod:httpRequestMethod
                                                                                  session:session];
        
        CMISHttpUploadRequest* request = [CMISHttpUploadRequest startRequest:urlRequest
                                                           httpMethod:httpRequestMethod
                                                          inputStream:inputStream
                                                              headers:additionalHeaders
                                                        bytesExpected:0
                                               authenticationProvider:session.authenticationProvider
                                                      completionBlock:completionBlock
                                                        progressBlock:nil];
        if (request)
        {
            cmisRequest.httpRequest = request;
        }
    } else {
        if (completionBlock) {
            completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeCancelled
                                                 detailedDescription:@"Request was cancelled"]);
        }
    }
}

- (void)invoke:(NSURL *)url
    httpMethod:(CMISHttpRequestMethod)httpRequestMethod
       session:(CMISBindingSession *)session
   inputStream:(NSInputStream *)inputStream
       headers:(NSDictionary *)additionalHeaders
 bytesExpected:(unsigned long long)bytesExpected
   cmisRequest:(CMISRequest *)cmisRequest
completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
 progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    if (!cmisRequest.isCancelled) {
        NSMutableURLRequest *urlRequest = [CMISDefaultNetworkProvider createRequestForUrl:url
                                                                               httpMethod:httpRequestMethod
                                                                                  session:session];
        
        CMISHttpUploadRequest* request = [CMISHttpUploadRequest startRequest:urlRequest
                                                           httpMethod:httpRequestMethod
                                                          inputStream:inputStream
                                                              headers:additionalHeaders
                                                        bytesExpected:bytesExpected
                                               authenticationProvider:session.authenticationProvider
                                                      completionBlock:completionBlock
                                                        progressBlock:progressBlock];
        if (request){
            cmisRequest.httpRequest = request;
        }
    } else {
        if (completionBlock) {
            completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeCancelled
                                                 detailedDescription:@"Request was cancelled"]);
        }
    }
}

- (void)invoke:(NSURL *)url
    httpMethod:(CMISHttpRequestMethod)httpRequestMethod
       session:(CMISBindingSession *)session
   inputStream:(NSInputStream *)inputStream
       headers:(NSDictionary *)additionalHeaders
 bytesExpected:(unsigned long long)bytesExpected
   cmisRequest:(CMISRequest *)cmisRequest
     startData:(NSData *)startData
       endData:(NSData *)endData
useBase64Encoding:(BOOL)useBase64Encoding
completionBlock:(void (^)(CMISHttpResponse *, NSError *))completionBlock
 progressBlock:(void (^)(unsigned long long, unsigned long long))progressBlock
{
    if (!cmisRequest.isCancelled) {
        NSMutableURLRequest *urlRequest = [CMISDefaultNetworkProvider createRequestForUrl:url
                                                                               httpMethod:httpRequestMethod
                                                                                  session:session];
        
        CMISHttpUploadRequest* request = [CMISHttpUploadRequest startRequest:urlRequest
                                                                  httpMethod:httpRequestMethod
                                                                 inputStream:inputStream
                                                                     headers:additionalHeaders
                                                               bytesExpected:bytesExpected
                                                      authenticationProvider:session.authenticationProvider
                                                              startData:startData
                                                                    endData:endData
                                                           useBase64Encoding:useBase64Encoding
                                                             completionBlock:completionBlock
                                                               progressBlock:progressBlock];
        if (request){
            cmisRequest.httpRequest = request;
        }
    } else {
        if (completionBlock) {
            completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeCancelled
                                                 detailedDescription:@"Request was cancelled"]);
        }
    }
}

- (void)invoke:(NSURL *)url
    httpMethod:(CMISHttpRequestMethod)httpRequestMethod
       session:(CMISBindingSession *)session
  outputStream:(NSOutputStream *)outputStream
 bytesExpected:(unsigned long long)bytesExpected
   cmisRequest:(CMISRequest *)cmisRequest
completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
 progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    [self invoke:url httpMethod:httpRequestMethod session:session outputStream:outputStream bytesExpected:bytesExpected offset:nil length:nil cmisRequest:cmisRequest completionBlock:completionBlock progressBlock:^(unsigned long long bytesDownloaded, unsigned long long bytesTotal) {
        if (progressBlock) {
            progressBlock(bytesDownloaded, bytesTotal);
        }
    }];
}

- (void)invoke:(NSURL *)url
    httpMethod:(CMISHttpRequestMethod)httpRequestMethod
       session:(CMISBindingSession *)session
  outputStream:(NSOutputStream *)outputStream
 bytesExpected:(unsigned long long)bytesExpected
        offset:(NSDecimalNumber*)offset
        length:(NSDecimalNumber*)length
   cmisRequest:(CMISRequest *)cmisRequest
completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
 progressBlock:(void (^)(unsigned long long bytesDownloaded, unsigned long long bytesTotal))progressBlock
{
    if (!cmisRequest.isCancelled) {
        NSMutableURLRequest *urlRequest = [CMISDefaultNetworkProvider createRequestForUrl:url
                                                                               httpMethod:HTTP_GET
                                                                                  session:session];
        
        CMISHttpDownloadRequest* request = [CMISHttpDownloadRequest startRequest:urlRequest
                                                             httpMethod:httpRequestMethod
                                                           outputStream:outputStream
                                                          bytesExpected:bytesExpected
                                                                 offset:offset
                                                                 length:length
                                                 authenticationProvider:session.authenticationProvider
                                                        completionBlock:completionBlock
                                                          progressBlock:progressBlock];
        if (request) {
            cmisRequest.httpRequest = request;
        }
    } else {
        if (completionBlock) {
            completionBlock(nil, [CMISErrors createCMISErrorWithCode:kCMISErrorCodeCancelled
                                                 detailedDescription:@"Request was cancelled"]);
            
        }
    }
}

- (void)invokeGET:(NSURL *)url
          session:(CMISBindingSession *)session
      cmisRequest:(CMISRequest *)cmisRequest
  completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
{
    return [self invoke:url
             httpMethod:HTTP_GET
                session:session
                   body:nil
                headers:nil
            cmisRequest:cmisRequest
        completionBlock:completionBlock];
}

- (void)invokePOST:(NSURL *)url
           session:(CMISBindingSession *)session
              body:(NSData *)body
           headers:(NSDictionary *)additionalHeaders
       cmisRequest:(CMISRequest *)cmisRequest
   completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
{
    return [self invoke:url
             httpMethod:HTTP_POST
                session:session
                   body:body
                headers:additionalHeaders
            cmisRequest:cmisRequest
        completionBlock:completionBlock];
}

- (void)invokePUT:(NSURL *)url
          session:(CMISBindingSession *)session
             body:(NSData *)body
          headers:(NSDictionary *)additionalHeaders
      cmisRequest:(CMISRequest *)cmisRequest
  completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
{
    return [self invoke:url
             httpMethod:HTTP_PUT
                session:session
                   body:body
                headers:additionalHeaders
            cmisRequest:cmisRequest
        completionBlock:completionBlock];
}

- (void)invokeDELETE:(NSURL *)url
             session:(CMISBindingSession *)session
         cmisRequest:(CMISRequest *)cmisRequest
     completionBlock:(void (^)(CMISHttpResponse *httpResponse, NSError *error))completionBlock
{
    return [self invoke:url
             httpMethod:HTTP_DELETE
                session:session
                   body:nil
                headers:nil
            cmisRequest:cmisRequest
        completionBlock:completionBlock];
}

#pragma mark Helper methods
+ (NSMutableURLRequest *)createRequestForUrl:(NSURL *)url
                                  httpMethod:(CMISHttpRequestMethod)httpRequestMethod
                                     session:(CMISBindingSession *)session
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:60];
    NSString *httpMethod;
    switch (httpRequestMethod) {
        case HTTP_GET:
            httpMethod = @"GET";
            break;
        case HTTP_POST:
            httpMethod = @"POST";
            break;
        case HTTP_DELETE:
            httpMethod = @"DELETE";
            break;
        case HTTP_PUT:
            httpMethod = @"PUT";
            break;
        default:
            CMISLogError(@"Invalid http request method: %d", (int)httpRequestMethod);
            return nil;
    }
    
    [request setHTTPMethod:httpMethod];
    CMISLogDebug(@"HTTP %@: %@", httpMethod, [url absoluteString]);
    
    // turn off cookies if configured to do so
    id sendCookies = [session objectForKey:kCMISSessionParameterSendCookies];
    if (sendCookies && ![sendCookies boolValue])
    {
        request.HTTPShouldHandleCookies = NO;
    }
    
    return request;
}

@end
