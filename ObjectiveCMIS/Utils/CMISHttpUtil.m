//
// ObjectiveCMIS
//
// Created by Joram Barrez
//


#import "CMISHttpUtil.h"
#import "CMISAuthenticationProvider.h"
#import "CMISErrors.h"

@implementation HttpUtil

#pragma mark synchronous methods

+ (HTTPResponse *)invokeGETSynchronous:(NSURL *)url withSession:(CMISBindingSession *)session error:(NSError **)outError
{
    NSMutableURLRequest *request = [self createRequestForUrl:url withHttpMethod:@"GET" usingSession:session];
    return [self executeRequestSynchronous:request error:outError];
}

+ (HTTPResponse *)invokePOSTSynchronous:(NSURL *)url withSession:(CMISBindingSession *)session body:(NSData *)body error:(NSError **)outError
{
    return [self invokePOSTSynchronous:url withSession:session body:body headers:nil error:outError];
}

+ (HTTPResponse *)invokePOSTSynchronous:(NSURL *)url withSession:(CMISBindingSession *)session body:(NSData *)body headers:(NSDictionary *)additionalHeaders error:(NSError **)outError
{
    NSMutableURLRequest *request = [self createRequestForUrl:url withHttpMethod:@"POST" usingSession:session];
    [request setHTTPBody:body];

    if (additionalHeaders)
    {
        [self addHeaders:additionalHeaders toURLRequest:request];
    }

    return [self executeRequestSynchronous:request error:outError];
}

+ (HTTPResponse *)invokePOSTSynchronous:(NSURL *)url withSession:(CMISBindingSession *)session bodyStream:(NSInputStream *)bodyStream headers:(NSDictionary *)additionalHeaders error:(NSError **)outError
{
    NSMutableURLRequest *request = [self createRequestForUrl:url withHttpMethod:@"POST" usingSession:session];
   [request setHTTPBodyStream:bodyStream];

   if (additionalHeaders)
   {
       [self addHeaders:additionalHeaders toURLRequest:request];
   }

   return [self executeRequestSynchronous:request error:outError];
}

+ (HTTPResponse *)invokeDELETESynchronous:(NSURL *)url withSession:(CMISBindingSession *)session error:(NSError **)outError
{
    NSMutableURLRequest *request = [self createRequestForUrl:url withHttpMethod:@"DELETE" usingSession:session];
    return [self executeRequestSynchronous:request error:outError];
}

+ (HTTPResponse *)invokePUTSynchronous:(NSURL *)url withSession:(CMISBindingSession *)session
                    bodyStream:(NSInputStream *)bodyStream headers:(NSDictionary *)additionalHeaders error:(NSError **)outError
{
    NSMutableURLRequest *request = [self createRequestForUrl:url withHttpMethod:@"PUT" usingSession:session];
    [request setHTTPBodyStream:bodyStream];

    if (additionalHeaders)
    {
         [self addHeaders:additionalHeaders toURLRequest:request];
    }

    return [self executeRequestSynchronous:request error:outError];
}

+ (HTTPResponse *)invokePUTSynchronous:(NSURL *)url withSession:(CMISBindingSession *)session body:(NSData *)body
                                                    headers:(NSDictionary *)additionalHeaders error:(NSError **)outError
{
    NSMutableURLRequest *request = [self createRequestForUrl:url withHttpMethod:@"PUT" usingSession:session];
    [request setHTTPBody:body];

    if (additionalHeaders)
    {
        [self addHeaders:additionalHeaders toURLRequest:request];
    }

    return [self executeRequestSynchronous:request error:outError];
}

#pragma mark asynchronous methods

+ (void)invokeGETAsynchronous:(NSURL *)url withSession:(CMISBindingSession *)session withDelegate:(id<NSURLConnectionDataDelegate>)delegate
{
    NSMutableURLRequest *request = [self createRequestForUrl:url withHttpMethod:@"GET" usingSession:session];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:delegate];
    [connection start];
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
    /*
    else if (outError && outError != NULL && *outError != nil)
    {
        log(@"Error while doing HTTP %@ %@ : %@", request.HTTPMethod, [request.URL absoluteString], [*outError description]);
    }
     */
    // Uncomment to see the actual response from the server
//    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    log(@"Response for %@ : %@", [request.URL absoluteString], dataString);

    return [HTTPResponse responseUsingURLHTTPResponse:response andData:data];
}


@end


#pragma mark HTTPRespons implementation


@interface HTTPResponse ()

@property (readwrite) NSInteger statusCode;
@property (nonatomic, strong, readwrite) NSData *data;

@end

@implementation HTTPResponse

@synthesize statusCode = _statusCode;
@synthesize data = _data;

+ (HTTPResponse *)responseUsingURLHTTPResponse:(NSHTTPURLResponse *)HTTPURLResponse andData:(NSData *)data
{
    HTTPResponse *httpResponse = [[HTTPResponse alloc] init];
    httpResponse.statusCode = HTTPURLResponse.statusCode;
    httpResponse.data = data;
    return httpResponse;
}

@end