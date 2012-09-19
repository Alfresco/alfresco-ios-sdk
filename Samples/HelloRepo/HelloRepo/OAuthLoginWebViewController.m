//
//  OAuthLoginWebViewController.m
//  HelloRepo
//
//  Created by Peter Schmidt on 19/09/2012.
//  Copyright (c) 2012 Gavin Cornwell. All rights reserved.
//

#import "OAuthLoginWebViewController.h"
#import "AlfrescoCloudSession.h"

@interface OAuthLoginWebViewController ()
@property (nonatomic, strong) NSString * apiKey;
@property (nonatomic, strong) NSString * secretKey;
@property (nonatomic, strong) NSString * redirectURI;
@property BOOL isLoginScreenLoad;
@end

@implementation OAuthLoginWebViewController
@synthesize webView = _webView;
@synthesize apiKey = _apiKey;
@synthesize secretKey = _secretKey;
@synthesize redirectURI = _redirectURI;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithAPIKey:(NSString *)apiKey secretKey:(NSString *)secretKey redirectURI:(NSString *)redirectURI
{
    self = [super init];
    if (nil != self)
    {
        self.redirectURI = redirectURI;
        self.apiKey = apiKey;
        self.secretKey = secretKey;
        self.isLoginScreenLoad = YES;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    NSString *stagingURLString = [NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&scope=pub_api&response_type=code",BASEURL, APIKEY, self.redirectURI];
    NSURL *testURL = [NSURL URLWithString:stagingURLString];
    NSMutableURLRequest *testRequest = [NSMutableURLRequest requestWithURL: testURL
                                                           cachePolicy: NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval: 60];
    
    [self.webView loadRequest:testRequest];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
        [AlfrescoCloudSession connectWithRequest:request apiKey:self.apiKey secretKey:self.secretKey redirectURI:self.redirectURI parameters:nil completionBlock:^(id<AlfrescoSession>session, NSError *error){
            if (nil == session)
            {
                NSLog(@"We get nil back as expected");
            }
        }];
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

@end
