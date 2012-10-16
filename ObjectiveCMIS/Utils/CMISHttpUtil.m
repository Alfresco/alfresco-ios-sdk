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

#import "CMISHttpUtil.h"
#import "CMISAuthenticationProvider.h"
#import "CMISErrors.h"

@implementation HttpUtil

#pragma mark synchronous methods

+ (HTTPResponse *)invokeSynchronous:(NSURL *)url withHttpMethod:(CMISHttpRequestMethod)httpRequestMethod
                        withSession:(CMISBindingSession *)session body:(NSData *)body
                        headers:(NSDictionary *)additionalHeaders error:(NSError **)outError
{
    NSMutableURLRequest *request = [self createRequestForUrl:url withHttpMethod:[self stringForHttpRequestMethod:httpRequestMethod] usingSession:session];

    if (body)
    {
        [request setHTTPBody:body];
    }

    if (additionalHeaders)
    {
        [self addHeaders:additionalHeaders toURLRequest:request];
    }

    HTTPResponse *response = [self executeRequestSynchronous:request error:outError];
    [self checkStatusCodeForResponse:response withHttpRequestMethod:httpRequestMethod error:outError];
    return response;
}


+ (HTTPResponse *)invokeSynchronous:(NSURL *)url withHttpMethod:(CMISHttpRequestMethod)httpRequestMethod withSession:(CMISBindingSession *)session bodyStream:(NSInputStream *)bodyStream headers:(NSDictionary *)additionalHeaders error:(NSError **)outError
{
    NSMutableURLRequest *request = [self createRequestForUrl:url withHttpMethod:[self stringForHttpRequestMethod:httpRequestMethod] usingSession:session];

    if (bodyStream)
    {
        [request setHTTPBodyStream:bodyStream];
    }

    if (additionalHeaders)
    {
        [self addHeaders:additionalHeaders toURLRequest:request];
    }

    HTTPResponse *response = [self executeRequestSynchronous:request error:outError];
    [self checkStatusCodeForResponse:response withHttpRequestMethod:httpRequestMethod error:outError];
    return response;
}

+ (void)checkStatusCodeForResponse:(HTTPResponse *)response withHttpRequestMethod:(CMISHttpRequestMethod)httpRequestMethod error:(NSError **)error
{
    if ( (httpRequestMethod == HTTP_GET && response.statusCode != 200)
      || (httpRequestMethod == HTTP_POST && response.statusCode != 201)
      || (httpRequestMethod == HTTP_DELETE && response.statusCode != 204)
      || (httpRequestMethod == HTTP_PUT && ((response.statusCode < 200 || response.statusCode > 299))))
    {
        NSString *errorContent = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
        log(@"Error content: %@", errorContent);

        switch (response.statusCode)
        {
            case 400:
                *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeInvalidArgument withDetailedDescription:response.statusCodeMessage];
                break;
            case 401:
                *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeUnauthorized withDetailedDescription:response.statusCodeMessage];
                break;
            case 403:
                *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodePermissionDenied withDetailedDescription:response.statusCodeMessage];
                break;
            case 404:
                *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeObjectNotFound withDetailedDescription:response.statusCodeMessage];
                break;
            case 405:
                *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeNotSupported withDetailedDescription:response.statusCodeMessage];
                break;
            case 407:
                *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeProxyAuthentication withDetailedDescription:response.statusCodeMessage];
                break;
            case 409:
                // TODO: need more if-else here, see opencmis impl
                *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeConstraint withDetailedDescription:response.statusCodeMessage];
                break;
            default:
                *error = [CMISErrors createCMISErrorWithCode:kCMISErrorCodeRuntime withDetailedDescription:response.statusCodeMessage];
        }

    }
}

+ (HTTPResponse *)invokeGETSynchronous:(NSURL *)url withSession:(CMISBindingSession *)session error:(NSError **)outError
{
    return [self invokeSynchronous:url withHttpMethod:HTTP_GET withSession:session body:nil headers:nil error:outError];
}

+ (HTTPResponse *)invokePOSTSynchronous:(NSURL *)url withSession:(CMISBindingSession *)session body:(NSData *)body error:(NSError **)outError
{
    return [self invokePOSTSynchronous:url withSession:session body:body headers:nil error:outError];
}

+ (HTTPResponse *)invokePOSTSynchronous:(NSURL *)url withSession:(CMISBindingSession *)session body:(NSData *)body headers:(NSDictionary *)additionalHeaders error:(NSError **)outError
{
    return [self invokeSynchronous:url withHttpMethod:HTTP_POST
                       withSession:session body:body headers:additionalHeaders error:outError];
}

+ (HTTPResponse *)invokePOSTSynchronous:(NSURL *)url withSession:(CMISBindingSession *)session bodyStream:(NSInputStream *)bodyStream headers:(NSDictionary *)additionalHeaders error:(NSError **)outError
{
   return [self invokeSynchronous:url withHttpMethod:HTTP_POST withSession:session
                       bodyStream:bodyStream headers:additionalHeaders error:outError];
}

+ (HTTPResponse *)invokeDELETESynchronous:(NSURL *)url withSession:(CMISBindingSession *)session error:(NSError **)outError
{
    return [self invokeSynchronous:url withHttpMethod:HTTP_DELETE
                       withSession:session bodyStream:nil headers:nil error:outError];
}

+ (HTTPResponse *)invokePUTSynchronous:(NSURL *)url withSession:(CMISBindingSession *)session
                    bodyStream:(NSInputStream *)bodyStream headers:(NSDictionary *)additionalHeaders error:(NSError **)outError
{
    return [self invokeSynchronous:url withHttpMethod:HTTP_PUT
                       withSession:session bodyStream:bodyStream headers:additionalHeaders error:outError];
}

+ (HTTPResponse *)invokePUTSynchronous:(NSURL *)url withSession:(CMISBindingSession *)session body:(NSData *)body
                                                    headers:(NSDictionary *)additionalHeaders error:(NSError **)outError
{
    return [self invokeSynchronous:url withHttpMethod:HTTP_PUT
                       withSession:session body:body headers:additionalHeaders error:outError];
}

#pragma mark asynchronous methods

+ (void)invokeAsynchronous:(NSURL *)url withHttpMethod:(CMISHttpRequestMethod)httpRequestMethod
                withSession:(CMISBindingSession *)session
                bodyStream:(NSInputStream *)bodyStream headers:(NSDictionary *)additionalHeaders
                withDelegate:(id <NSURLConnectionDataDelegate>)delegate
{
    NSMutableURLRequest *request = [self createRequestForUrl:url withHttpMethod:[self stringForHttpRequestMethod:httpRequestMethod] usingSession:session];

    if (bodyStream)
    {
        [request setHTTPBodyStream:bodyStream];
    }

    if (additionalHeaders)
    {
        [self addHeaders:additionalHeaders toURLRequest:request];
    }

    // See also: http://www.ddeville.me/2011/12/broken-NSURLConnection-on-ios/
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:delegate];
//        [connection setDelegateQueue:[NSOperationQueue mainQueue]];
        [connection start];
    }];
}

+ (void)invokeAsynchronous:(NSURL *)url withHttpMethod:(CMISHttpRequestMethod)httpRequestMethod
                withSession:(CMISBindingSession *)session
                body:(NSData *)body headers:(NSDictionary *)additionalHeaders
                withDelegate:(id <NSURLConnectionDataDelegate>)delegate
{
    NSMutableURLRequest *request = [self createRequestForUrl:url withHttpMethod:[self stringForHttpRequestMethod:httpRequestMethod] usingSession:session];

    if (body)
    {
        [request setHTTPBody:body];
    }

    if (additionalHeaders)
    {
        [self addHeaders:additionalHeaders toURLRequest:request];
    }

    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    [connection start];
}

+ (void)invokeGETAsynchronous:(NSURL *)url withSession:(CMISBindingSession *)session withDelegate:(id<NSURLConnectionDataDelegate>)delegate
{
    [self invokeAsynchronous:url withHttpMethod:HTTP_GET withSession:session body:nil headers:nil withDelegate:delegate];
}

+ (void)invokePOSTAsynchronous:(NSURL *)url withSession:(CMISBindingSession *)session body:(NSData *)body withDelegate:(id <NSURLConnectionDataDelegate>)delegate
{
    [self invokePOSTAsynchronous:url withSession:session body:body headers:nil withDelegate:delegate];
}

+ (void)invokePOSTAsynchronous:(NSURL *)url withSession:(CMISBindingSession *)session body:(NSData *)body
                       headers:(NSDictionary *)additionalHeaders withDelegate:(id <NSURLConnectionDataDelegate>)delegate
{
    [self invokeAsynchronous:url withHttpMethod:HTTP_POST withSession:session body:body headers:additionalHeaders withDelegate:delegate];
}

+ (void)invokePOSTAsynchronous:(NSURL *)url withSession:(CMISBindingSession *)session bodyStream:(NSInputStream *)bodyStream
                       headers:(NSDictionary *)additionalHeaders withDelegate:(id <NSURLConnectionDataDelegate>)delegate
{
    [self invokeAsynchronous:url withHttpMethod:HTTP_POST withSession:session bodyStream:bodyStream headers:additionalHeaders withDelegate:delegate];
}

+ (void)invokePUTAsynchronous:(NSURL *)url withSession:(CMISBindingSession *)session bodyStream:(NSInputStream *)bodyStream
                      headers:(NSDictionary *)additionalHeaders withDelegate:(id <NSURLConnectionDataDelegate>)delegate
{
    [self invokeAsynchronous:url withHttpMethod:HTTP_PUT withSession:session bodyStream:bodyStream headers:additionalHeaders withDelegate:delegate];
}


#pragma mark Helper methods

+ (NSMutableURLRequest *)createRequestForUrl:(NSURL *)url withHttpMethod:(NSString *)httpMethod usingSession:(CMISBindingSession *)session
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                        cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                        timeoutInterval:60];
    [request setHTTPMethod:httpMethod];
    log(@"HTTP %@: %@", httpMethod, [url absoluteString]);

    id <CMISAuthenticationProvider> authenticationProvider = session.authenticationProvider;
    NSDictionary *headers = authenticationProvider.httpHeadersToApply;
    if (headers)
    {
        [self addHeaders:headers toURLRequest:request];
    }

    return request;
}

+ (void)addHeaders:(NSDictionary *)headers toURLRequest:(NSMutableURLRequest *)urlRequest
{
    for (NSString *headerName in headers)
    {
        [urlRequest addValue:[headers objectForKey:headerName] forHTTPHeaderField:headerName];
    }
}

+ (HTTPResponse *)executeRequestSynchronous:(NSMutableURLRequest *)request error:(NSError * *)outError
{
    NSHTTPURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:outError];

    if (data == nil || (outError && outError != NULL && *outError != nil) ) {
        log(@"Error while doing HTTP %@ %@ : %@", request.HTTPMethod, [request.URL absoluteString], [*outError description]);
    }
    else {
        log(@"HTTP response with code = %d, code String = %@",[response statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[response statusCode]]);
    }

    // Uncomment to see the actual response from the server
//    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    log(@"Response for %@ : %@", [request.URL absoluteString], dataString);

    return [HTTPResponse responseUsingURLHTTPResponse:response andData:data];
}

+ (NSString *)stringForHttpRequestMethod:(CMISHttpRequestMethod)httpRequestMethod
{
    switch (httpRequestMethod)
    {
        case HTTP_GET:
            return @"GET";
        case HTTP_POST:
            return @"POST";
        case HTTP_DELETE:
            return @"DELETE";
        case HTTP_PUT:
            return @"PUT";
    }

    log(@"Could not find matching http request for %d", httpRequestMethod);
    return nil;
}

@end


#pragma mark HTTPRespons implementation


@implementation HTTPResponse

@synthesize statusCode = _statusCode;
@synthesize data = _data;
@synthesize statusCodeMessage = _statusCodeMessage;

+ (HTTPResponse *)responseUsingURLHTTPResponse:(NSHTTPURLResponse *)httpUrlResponse andData:(NSData *)data
{
    HTTPResponse *httpResponse = [[HTTPResponse alloc] init];
    httpResponse.statusCode = httpUrlResponse.statusCode;
    httpResponse.data = data;
    httpResponse.statusCodeMessage = [NSHTTPURLResponse localizedStringForStatusCode:[httpUrlResponse statusCode]];
    return httpResponse;
}

@end