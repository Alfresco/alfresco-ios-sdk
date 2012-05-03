//
// Alfresco Focus
//
// Created by Joram Barrez
//


#import "HttpUtil.h"
#import "CMISBindingSession.h"
#import "CMISAuthenticationProvider.h"


@implementation HttpUtil

+ (NSData *)invokeGET:(NSURL *)url withSession:(id<CMISBindingSession>)session error:(NSError **)error
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    log(@"HTTP GET: %@", [url absoluteString]);

    id<CMISAuthenticationProvider> authenticationProvider = session.authenticationProvider;
    NSDictionary *headers = authenticationProvider.httpHeadersToApply;
    if (headers)
    {
        for (NSString *headerName in headers)
        {
            [request addValue:[headers objectForKey:headerName] forHTTPHeaderField:headerName];
        }
    }

    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];

    if (data == nil) {
        log(@"Did not receive any data for HTTP GET %@", [url absoluteString]);
    }
    else if (error && error != NULL && *error != nil)
    {
        log(@"Error while doing HTTP GET %@ : %@", [url absoluteString], [*error description]);
    }

//    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    log(@"Response for %@ : %@", [url absoluteString], dataString);

    return data;
}

@end