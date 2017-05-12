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
#import "SAMLConstants.h"
#import "AlfrescoErrors.h"
#import "AlfrescoLog.h"

@interface AlfrescoSAMLUILoginViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic) BOOL searchForResponse;
@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, copy) void (^completionBlock)(NSDictionary *, NSError *);

@end

@implementation AlfrescoSAMLUILoginViewController

- (instancetype)initWithBaseURL:(NSString *)baseURLString completionBlock:(AlfrescoSAMLAuthCompletionBlock)completionBlock
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass([AlfrescoSAMLUILoginViewController class]) bundle:nil];
    self = [storyboard instantiateInitialViewController];
    self.baseURL = baseURLString;
    self.completionBlock = completionBlock;
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadWebView];
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
        NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.getElementsByTagName('pre')[0].innerHTML"];
        NSData *jsonData = [html dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
        NSError *error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        if(jsonDict && jsonDict[@"entry"][@"id"])
        {
            [self performCompletionBlockWithSAMLData:jsonDict andError:nil];
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
    NSURL *initialAuthURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", self.baseURL, kAlfrescoSAMLAuthenticateSufix]];
    NSURLRequest *authRequest = [NSURLRequest requestWithURL:initialAuthURL];
    [self.activityIndicator startAnimating];
    AlfrescoLogDebug(@"Loading webview with URL: %@", initialAuthURL);
    [self.webView loadRequest:authRequest];
}

- (void)performCompletionBlockWithSAMLData:(NSDictionary *)samlData andError:(NSError *)error
{
    if(self.completionBlock)
    {
        self.completionBlock(samlData, error);
    }
}

@end
