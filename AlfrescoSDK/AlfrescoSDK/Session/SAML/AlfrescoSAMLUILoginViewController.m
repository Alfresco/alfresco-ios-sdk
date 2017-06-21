/*
 ******************************************************************************
 * Copyright (C) 2005-2017 Alfresco Software Limited.
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
 *****************************************************************************
 */

#import "AlfrescoSAMLUILoginViewController.h"
#import "AlfrescoSAMLConstants.h"
#import "AlfrescoErrors.h"
#import "AlfrescoLog.h"
#import "AlfrescoSAMLAuthHelper.h"

@interface AlfrescoSAMLUILoginViewController () <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic) BOOL searchForResponse;
@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, copy) AlfrescoSAMLAuthCompletionBlock completionBlock;

@end

@implementation AlfrescoSAMLUILoginViewController

- (instancetype)initWithBaseURLString:(NSString *)baseURLString completionBlock:(AlfrescoSAMLAuthCompletionBlock)completionBlock
{
    if (self = [super init])
    {
        self.baseURL = baseURLString;
        self.completionBlock = completionBlock;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadWebView];
    
    if (!self.activityIndicator)
    {
        [self createActivityView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.activityIndicator stopAnimating];
    [super viewWillDisappear:animated];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if([request.URL.absoluteString containsString:kAlfrescoSAMLAuthenticateResponseSufix])
    {
        self.searchForResponse = YES;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
    
    if(self.searchForResponse)
    {
        self.webView.hidden = YES;
        
        NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.getElementsByTagName('pre')[0].innerHTML"];
        NSData *jsonData = [html dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
        NSError *error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        if(jsonDict && jsonDict[@"entry"][@"id"])
        {
            NSString *ticket = jsonDict[@"entry"][@"id"];
            NSString *userID = jsonDict[@"entry"][@"userId"];
            AlfrescoSAMLTicket *samlTicket = [[AlfrescoSAMLTicket alloc] initWithTicket:ticket userID:userID];
            AlfrescoSAMLData *samlData = [[AlfrescoSAMLData alloc] initWithSamlInfo:nil samlTicket:samlTicket];
            [self performCompletionBlockWithSAMLData:samlData andError:nil];
        }
        else
        {
            NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeSAMLDataMissing];
            [self performCompletionBlockWithSAMLData:nil andError:error];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    AlfrescoLogError(@"UIWebViewDelegate didFailLoadWithError");
    AlfrescoLogError(@"Error occurred while loading page: %@ with code %d and reason %@", [error localizedDescription], [error code], [error localizedFailureReason]);
    [self.activityIndicator stopAnimating];
    [self performCompletionBlockWithSAMLData:nil andError:error];
}

#pragma mark - Private methods

- (void)loadWebView
{
    if (nil != self.webView)
    {
        self.webView = nil;
    }
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    if (!self.activityIndicator)
    {
        [self createActivityView];
    }
    [self.activityIndicator startAnimating];
    
    NSURL *baseURL = [NSURL URLWithString:self.baseURL];
    AlfrescoSAMLAuthHelper *helper = [[AlfrescoSAMLAuthHelper alloc] initWithBaseURL:baseURL];
    NSURL *initialAuthURL = [helper authenticateURL];
    NSURLRequest *authRequest = [NSURLRequest requestWithURL:initialAuthURL];

    AlfrescoLogDebug(@"Loading webview with URL: %@", initialAuthURL);
    [self.webView loadRequest:authRequest];
}

- (void)createActivityView
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view insertSubview:self.activityIndicator aboveSubview:self.webView];
    
    // Width constraint
    [self.activityIndicator addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1.0
                                                                        constant:100]];
    
    // Height constraint
    [self.activityIndicator addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeHeight
                                                                      multiplier:1.0
                                                                        constant:100]];
    
    // Center horizontally
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    // Center vertically
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)performCompletionBlockWithSAMLData:(AlfrescoSAMLData *)samlData andError:(NSError *)error
{
    if(self.completionBlock)
    {
        self.completionBlock(samlData, error);
    }
}

@end
