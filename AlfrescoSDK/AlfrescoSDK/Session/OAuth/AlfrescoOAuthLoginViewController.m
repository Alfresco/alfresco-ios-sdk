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
@property (nonatomic, strong, readwrite) NSDictionary *parameters;
@property BOOL isLoginScreenLoad;
- (void)loadWebView;
- (NSString *)authorizationCodeFromURL:(NSURL *)url;
- (void)createActivityView;
@end

@implementation AlfrescoOAuthLoginViewController

@synthesize webView = _webView;
@synthesize isLoginScreenLoad = _isLoginScreenLoad;
@synthesize connection = _connection;
@synthesize receivedData = _receivedData;
@synthesize completionBlock = _completionBlock;
@synthesize oauthData = _oauthData;
@synthesize baseURL = _baseURL;
@synthesize parameters = _parameters;
@synthesize activityIndicator = _activityIndicator;

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
        [AlfrescoErrors assertStringArgumentNotNilOrEmpty:apiKey argumentName:@"apiKey"];
        [AlfrescoErrors assertStringArgumentNotNilOrEmpty:secretKey argumentName:@"secretKey"];
//        [AlfrescoErrors assertStringArgumentNotNilOrEmpty:redirectURI argumentName:@"redirectURI"];
        [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
        
        self.oauthData = [[AlfrescoOAuthData alloc] initWithAPIKey:apiKey secretKey:secretKey redirectURI:redirectURI];
        self.completionBlock = completionBlock;
        self.baseURL = [NSString stringWithFormat:@"%@%@",kAlfrescoOAuthCloudURL,kAlfrescoOAuthAuthorize];
        
        if (nil != parameters)
        {
            self.parameters = parameters;
            if ([[parameters allKeys] containsObject:kAlfrescoSessionCloudURL])
            {
                NSString *supplementedURL = [parameters valueForKey:kAlfrescoSessionCloudURL];
                self.baseURL = [NSString stringWithFormat:@"%@%@",supplementedURL,kAlfrescoOAuthAuthorize];
            }
        }
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isLoginScreenLoad = YES;
    [self loadWebView];
    [self createActivityView];
}

- (void)viewDidUnload
{
    self.oauthData = nil;
    self.connection = nil;
    self.receivedData = nil;
    [super viewDidUnload];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [self.activityIndicator stopAnimating];
    [super viewWillDisappear:animated];
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
    
    NSLog(@"baseurl: %@", self.baseURL);
    NSLog(@"apikey: %@", self.oauthData.apiKey);
    NSLog(@"apisecret: %@", self.oauthData.secretKey);
    NSLog(@"redirect: %@", self.oauthData.redirectURI);
    
    NSMutableString *authURLString = [NSMutableString string];
    [authURLString appendString:self.baseURL];
    [authURLString appendString:@"?"];
    [authURLString appendString:[kAlfrescoOAuthClientID stringByReplacingOccurrencesOfString:kAlfrescoClientID withString:self.oauthData.apiKey]];
    [authURLString appendString:@"&"];
    [authURLString appendString:[kAlfrescoOAuthRedirectURI stringByReplacingOccurrencesOfString:kAlfrescoRedirectURI withString:self.oauthData.redirectURI]];
    [authURLString appendString:@"&"];
    [authURLString appendString:kAlfrescoOAuthScope];
    [authURLString appendString:@"&"];
    [authURLString appendString:kAlfrescoOAuthResponseType];
    NSLog(@"Auth URL is %@", authURLString);
    
    // load the authorization URL in the web view
    NSURL *authURL = [NSURL URLWithString:authURLString];
    [self.webView loadRequest:[NSURLRequest requestWithURL:authURL]];
}


- (NSString *)authorizationCodeFromURL:(NSURL *)url
{
    NSLog(@"callbackURL: %@", url);
    
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


- (void)createActivityView
{
    CGSize size = self.view.bounds.size;
    CGFloat xOffset = size.width/2 - 50;
    CGFloat yOffset = size.height/2 - 50;
    CGRect viewFrame = CGRectMake(xOffset, yOffset, 100, 100);
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.activityIndicator.frame = viewFrame;
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view insertSubview:self.activityIndicator aboveSubview:self.webView];
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
    
    if (self.isLoginScreenLoad)
    {
        NSLog(@"isLoginScreenLoad = YES");
    }
    else
    {
        NSLog(@"isLoginScreenLoad = NO");
    }
    
    if (!self.isLoginScreenLoad)
    {
        NSLog(@"isLoginScreenLoad = NO and we start the NSURLConnection requet");
        [self.activityIndicator startAnimating];
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
    NSLog(@"LoginViewController:NSURLConnectionDelegate didReceiveData");
}

/**
 this method is used for extracting the authentication code we receive back from the server when we
 first submit username/password
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"LoginViewController:didReceiveResponse");
    NSString *code = [self authorizationCodeFromURL:response.URL];
    NSLog(@"Extracted auth code: %@", code);
    
    if (nil != code)
    {
        AlfrescoOAuthHelper *helper = nil;
        if (nil != self.parameters)
        {
            helper = [[AlfrescoOAuthHelper alloc] initWithParameters:self.parameters];
        }
        else
        {
            helper = [[AlfrescoOAuthHelper alloc] init];
        }
        [helper retrieveOAuthDataForAuthorizationCode:code oauthData:self.oauthData completionBlock:self.completionBlock];
    }
    else
    {
        [self.activityIndicator stopAnimating];
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not obtain authentication code from server. Possibly incorrect password/username" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertview show];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"LoginViewController:connection error with message %@ and code %d", [error localizedDescription], [error code]);
    [self.activityIndicator stopAnimating];
    self.completionBlock(nil, error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"LoginViewController:connectionDidFinishLoading");
}


@end
