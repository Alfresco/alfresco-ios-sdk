//
// Alfresco Focus
//
// Created by Joram Barrez
//


#import "HttpUtil.h"
#import "CMISAuthenticationProvider.h"

@implementation HttpUtil

+ (NSData *)invokeGET:(NSURL *)url withSession:(CMISBindingSession *)session error:(NSError **)outError
{
    NSMutableURLRequest *request = [self createRequestForUrl:url withHttpMethod:@"GET" usingSession:session];
    return [self executeRequest:request error:outError];
}

+ (NSData *)invokePOST:(NSURL *)url withSession:(CMISBindingSession *)session body:(NSData *)body error:(NSError **)outError
{
    return [self invokePOST:url withSession:session body:body headers:nil error:outError];
}

+ (NSData *)invokePOST:(NSURL *)url withSession:(CMISBindingSession *)session body:(NSData *)body headers:(NSDictionary *)additionalHeaders error:(NSError **)outError
{
    NSMutableURLRequest *request = [self createRequestForUrl:url withHttpMethod:@"POST" usingSession:session];
    [request setHTTPBody:body];

    if (additionalHeaders)
    {
        [self addHeaders:additionalHeaders toURLRequest:request];
    }

    return [self executeRequest:request error:outError];
}

+ (NSData *)invokeDELETE:(NSURL *)url withSession:(CMISBindingSession *)session error:(NSError **)outError
{
    NSMutableURLRequest *request = [self createRequestForUrl:url withHttpMethod:@"DELETE" usingSession:session];
    return [self executeRequest:request error:outError];
}

#pragma mark Helper methods

+ (NSMutableURLRequest *)createRequestForUrl:(NSURL *)url withHttpMethod:(NSString *)httpMethod usingSession:(CMISBindingSession *)session
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
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

+ (NSData *)executeRequest:(NSMutableURLRequest *)request error:(NSError * *)outError
{
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:outError];

    if (data == nil)
    {
        log(@"Did not receive any data for HTTP %@ %@", request.HTTPMethod, [request.URL absoluteString]);
    }
    else if (outError && outError != NULL && *outError != nil)
    {
        log(@"Error while doing HTTP %@ %@ : %@", request.HTTPMethod, [request.URL absoluteString], [*outError description]);
    }

    //    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //    log(@"Response for %@ : %@", [url absoluteString], dataString);

    return data;
}


@end