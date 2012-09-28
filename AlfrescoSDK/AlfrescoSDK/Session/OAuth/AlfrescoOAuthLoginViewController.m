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
#import "AlfrescoOAuthHelper.h"

@interface AlfrescoOAuthLoginViewController ()
@property (nonatomic, strong, readwrite) NSURLConnection    * connection;
@property (nonatomic, strong, readwrite) NSMutableData      * receivedData;
@property (nonatomic, copy, readwrite) AlfrescoOAuthCompletionBlock completionBlock;
@property (nonatomic, strong, readwrite) AlfrescoOAuthData  * oauthData;
@property (nonatomic, strong, readwrite) NSString *baseURL;
@property BOOL isLoginScreenLoad;
@property BOOL isTest;
- (void)loadWebView;
- (NSString *)authorizationCodeFromURL:(NSURL *)url;

@end

@implementation AlfrescoOAuthLoginViewController

@synthesize webView = _webView;
@synthesize isLoginScreenLoad = _isLoginScreenLoad;
@synthesize connection = _connection;
@synthesize receivedData = _receivedData;
@synthesize completionBlock = _completionBlock;
@synthesize isTest = _isTest;
@synthesize oauthData = _oauthData;
@synthesize baseURL = _baseURL;

- (id)initWithAPIKey:(NSString *)apiKey
           secretKey:(NSString *)secretKey
     completionBlock:(AlfrescoOAuthCompletionBlock)completionBlock
{
    return [self initWithAPIKey:apiKey
                      secretKey:secretKey
                    redirectURI:kAlfrescoCloudDefaultRedirectURI
                completionBlock:completionBlock
                     parameters:nil];
}

- (id)initWithAPIKey:(NSString *)apiKey
           secretKey:(NSString *)secretKey
         redirectURI:(NSString *)redirectURI
     completionBlock:(AlfrescoOAuthCompletionBlock)completionBlock
{
    return [self initWithAPIKey:apiKey
                      secretKey:secretKey
                    redirectURI:redirectURI
                completionBlock:completionBlock
                     parameters:nil];
}

- (id)initWithAPIKey:(NSString *)apiKey
           secretKey:(NSString *)secretKey
     completionBlock:(AlfrescoOAuthCompletionBlock)completionBlock
          parameters:(NSDictionary *)parameters
{
    return [self initWithAPIKey:apiKey
                      secretKey:secretKey
                    redirectURI:kAlfrescoCloudDefaultRedirectURI
                completionBlock:completionBlock
                     parameters:parameters];
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
            if ([[parameters allKeys] containsObject:kAlfrescoSessionCloudURL])
            {
                self.baseURL = [parameters valueForKey:kAlfrescoSessionCloudURL];
            }
            else
            {
                self.baseURL = kAlfrescoOAuthAuthorizeURL;
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
    [stagingURLString appendString:self.baseURL];
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
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
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
        [AlfrescoOAuthHelper retrieveOAuthDataForAuthorizationCode:code
                                                         oauthData:self.oauthData
                                                   completionBlock:self.completionBlock];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"connection error with message %@ and code %d", [error localizedDescription], [error code]);
    self.completionBlock(nil, error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
}


@end
