/*******************************************************************************
 * Copyright (C) 2005-2012 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Mobile SDK.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ******************************************************************************/

#import "AlfrescoOAuthLoginViewController.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoErrors.h"

@interface AlfrescoOAuthLoginViewController ()
@property (nonatomic, strong, readwrite) NSURLConnection    * connection;
@property (nonatomic, strong, readwrite) NSMutableData      * receivedData;
@property (nonatomic, copy, readwrite) AlfrescoOAuthCompletionBlock completionBlock;
@property (nonatomic, strong, readwrite) AlfrescoOAuthData  * oauthData;
@property BOOL isLoginScreenLoad;
@property BOOL isTest;
- (void)loadWebView;
- (void)setOAuthDataFromJSONResponseWithError:(NSError **)outError;
- (NSString *)authorizationCodeFromURL:(NSURL *)url;
- (void)authenticateWithAuthorisationCode:(NSString *)code;

@end

@implementation AlfrescoOAuthLoginViewController

@synthesize webView = _webView;
@synthesize isLoginScreenLoad = _isLoginScreenLoad;
@synthesize connection = _connection;
@synthesize receivedData = _receivedData;
@synthesize completionBlock = _completionBlock;
@synthesize isTest = _isTest;
@synthesize oauthData = _oauthData;

- (id)initWithAPIKey:(NSString *)apiKey
           secretKey:(NSString *)secretKey
         redirectURI:(NSString *)redirectURI
     completionBlock:(AlfrescoOAuthCompletionBlock)completionBlock
{
    return [self initWithAPIKey:apiKey secretKey:secretKey redirectURI:redirectURI completionBlock:completionBlock parameters:nil];
}

- (id)initWithAPIKey:(NSString *)apiKey
           secretKey:(NSString *)secretKey
         redirectURI:(NSString *)redirectURI
     completionBlock:(AlfrescoOAuthCompletionBlock)completionBlock
          parameters:(NSDictionary *)parameters
{
    self = [super init];
    if (nil != self)
    {
        self.oauthData = [[AlfrescoOAuthData alloc] initWithAPIKey:apiKey secretKey:secretKey redirectURI:redirectURI];
        self.completionBlock = completionBlock;
        if (nil != parameters)
        {
            if ([[parameters allKeys] containsObject:kAlfrescoCloudTestParameter])
            {
                
                self.isTest = [[parameters valueForKey:kAlfrescoCloudTestParameter] boolValue];
            }
            
        }
        else
        {
            self.isTest = NO;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isLoginScreenLoad = YES;
    [self loadWebView];
}

- (void)viewDidUnload
{
    self.oauthData = nil;
    self.connection = nil;
    self.receivedData = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    self.oauthData = nil;
    self.connection = nil;
    self.receivedData = nil;
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma private methods
- (void)loadWebView
{
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    NSMutableString *stagingURLString = [NSMutableString string];
    NSString *baseURL = (self.isTest) ? kAlfrescoOAuthTestAuthorizeURL : kAlfrescoOAuthAuthorizeURL;
    [stagingURLString appendString:baseURL];
    [stagingURLString appendString:@"?"];
    [stagingURLString appendString:[kAlfrescoOAuthClientID stringByReplacingOccurrencesOfString:kAlfrescoClientID withString:self.oauthData.apiKey]];
    [stagingURLString appendString:@"&"];
    [stagingURLString appendString:[kAlfrescoOAuthRedirectURI stringByReplacingOccurrencesOfString:kAlfrescoRedirectURI withString:self.oauthData.redirectURI]];
    [stagingURLString appendString:@"&"];
    [stagingURLString appendString:kAlfrescoOAuthScope];
    [stagingURLString appendString:@"&"];
    [stagingURLString appendString:kAlfrescoOAuthResponseType];
    NSLog(@"Staging URL is %@",stagingURLString);
    NSURL *stagingURL = [NSURL URLWithString:stagingURLString];
    [self.webView loadRequest:[NSURLRequest requestWithURL:stagingURL]];
}

- (void)authenticateWithAuthorisationCode:(NSString *)code
{
    NSLog(@"IN authenticateWithAuthorisationCode:%@",code);
    NSString *baseURL = (self.isTest) ? kAlfrescoOAuthTestTokenURL : kAlfrescoOAuthTokenURL;
    NSURL *url = [NSURL URLWithString:baseURL];
    [self.connection cancel];
    self.connection = nil;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url
                                                           cachePolicy: NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval: 60];
    
    [request setHTTPMethod:@"POST"];
    
    NSMutableString *contentString = [NSMutableString string];
    NSString *codeID   = [kAlfrescoOAuthCode stringByReplacingOccurrencesOfString:kAlfrescoCode withString:code];
    NSString *clientID = [kAlfrescoOAuthClientID stringByReplacingOccurrencesOfString:kAlfrescoClientID withString:self.oauthData.apiKey];
    NSString *secretID = [kAlfrescoOAuthClientSecret stringByReplacingOccurrencesOfString:kAlfrescoClientSecret withString:self.oauthData.secretKey];
    NSString *redirect = [kAlfrescoOAuthRedirectURI stringByReplacingOccurrencesOfString:kAlfrescoRedirectURI withString:self.oauthData.redirectURI];
    
    [contentString appendString:codeID];
    [contentString appendString:@"&"];
    [contentString appendString:clientID];
    [contentString appendString:@"&"];
    [contentString appendString:secretID];
    [contentString appendString:@"&"];
    [contentString appendString:kAlfrescoOAuthGrantType];
    [contentString appendString:@"&"];
    [contentString appendString:redirect];
    NSLog(@"Token Staging URL is %@",contentString);
    
    NSData *data = [contentString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
}



- (void)setOAuthDataFromJSONResponseWithError:(NSError **)outError
{
    if (nil == self.receivedData)
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        else
        {
            NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        return;
    }
    if (0 == self.receivedData.length)
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        else
        {
            NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        return;
    }
    NSError *error = nil;
    id jsonDictionary = [NSJSONSerialization JSONObjectWithData:self.receivedData options:kNilOptions error:&error];
    if (nil == jsonDictionary)
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        else
        {
            NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:error andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsingNilData];
        }
        return;
    }
    
    if (![jsonDictionary isKindOfClass:[NSDictionary class]])
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        else
        {
            NSError *underlyingError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:underlyingError andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        return;
    }
    
    if ([[jsonDictionary allKeys] containsObject:kAlfrescoJSONError])
    {
        if (nil == *outError)
        {
            *outError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        else
        {
            NSError *underlyingError = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
            *outError = [AlfrescoErrors alfrescoErrorWithUnderlyingError:underlyingError andAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
        }
        return;
    }
    
    [self.oauthData setOAuthDataWithJSONDictionary:jsonDictionary];
    
}

- (NSString *)authorizationCodeFromURL:(NSURL *)url
{
    if (nil == url)
    {
        return nil;
    }
    NSArray *components = [[url absoluteString] componentsSeparatedByString:@"code="];
    if (2 == components.count)
    {
        self.receivedData = [NSMutableData data];
        NSString *codeString = [components objectAtIndex:1];
        NSArray *codeComponents = [codeString componentsSeparatedByString:@"&"];
        if (codeComponents.count > 0)
        {
            return [codeComponents objectAtIndex:0];
        }
        
    }
    return nil;
}


#pragma WebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"UIWebviewDelegate webViewDidFinishLoad");
    if (self.isLoginScreenLoad)
    {
        self.isLoginScreenLoad = NO;
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"UIWebviewDelegate shouldStartLoadWithRequest");
    if (!self.isLoginScreenLoad)
    {
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        return NO;
    }
    return YES;
}


- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"UIWebviewDelegate webViewDidStartLoad");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"UIWebviewDelegate didFailLoadWithError");
    NSLog(@"Error occurred while loading page: %@ with code %d and reason %@", [error localizedDescription], [error code], [error localizedFailureReason]);
}

#pragma NSURLConnection Delegate methods
/**
 this method is used to receive the JSON data back from the server as a response to the 2nd call. The expected
 JSON data should contain access/refresh token
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (nil != data && data.length > 0)
    {
        NSError *error = nil;
        id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (nil != jsonObj)
        {
            if ([jsonObj isKindOfClass:[NSDictionary class]])
            {
                [self.receivedData appendBytes:[data bytes] length:data.length];
            }
            
        }
    }
    
}

/**
 this method is used for extracting the authentication code we receive back from the server when we
 first submit username/password
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSString *code = [self authorizationCodeFromURL:response.URL];
    if (nil != code)
    {
        [self authenticateWithAuthorisationCode:code];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.completionBlock(nil, error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error = nil;
    [self setOAuthDataFromJSONResponseWithError:&error];
    self.completionBlock(self.oauthData, error);
}


@end
