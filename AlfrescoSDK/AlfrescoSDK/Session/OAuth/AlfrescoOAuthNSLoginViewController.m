/*
 ******************************************************************************
 * Copyright (C) 2005-2020 Alfresco Software Limited.
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

#import "AlfrescoOAuthNSLoginViewController.h"
#import "AlfrescoInternalConstants.h"
#import "AlfrescoErrors.h"
#import "AlfrescoOAuthHelper.h"
#import "AlfrescoLog.h"

@interface AlfrescoOAuthNSLoginViewController () <NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSAlertDelegate>

@property (nonatomic, strong, readwrite) NSURLConnection *connection;
@property (nonatomic, strong, readwrite) NSMutableData *receivedData;
@property (nonatomic, copy, readwrite) AlfrescoOAuthCompletionBlock completionBlock;
@property (nonatomic, strong, readwrite) AlfrescoOAuthData *oauthData;
@property (nonatomic, strong, readwrite) NSString *baseURL;
@property (nonatomic, strong, readwrite) NSDictionary *parameters;
@property (nonatomic, assign) BOOL isLoginScreenLoad;
@property (nonatomic, assign) BOOL hasValidAuthenticationCode;
@property (nonatomic) AlfrescoCloudConnectionStatus cloudConnectionStatus;

@end

@implementation AlfrescoOAuthNSLoginViewController

- (id)initWithAPIKey:(NSString *)apiKey
           secretKey:(NSString *)secretKey
     completionBlock:(AlfrescoOAuthCompletionBlock)completionBlock
{
    return [self initWithAPIKey:apiKey
                      secretKey:secretKey
                    redirectURI:kAlfrescoCloudDefaultRedirectURI
                     parameters:nil
                completionBlock:completionBlock];
}

/**
 apiKey, secretKey and completionBlock are mandatory. redirectURI isn't. Hence we do the assertArgument check only on 3 parameters
 */
- (id)initWithAPIKey:(NSString *)apiKey
           secretKey:(NSString *)secretKey
         redirectURI:(NSString *)redirectURI
     completionBlock:(AlfrescoOAuthCompletionBlock)completionBlock
{
    return [self initWithAPIKey:apiKey
                      secretKey:secretKey
                    redirectURI:redirectURI
                     parameters:nil
                completionBlock:completionBlock];
}

/**
 apiKey, secretKey and completionBlock are mandatory. parameters isn't. Hence we do the assertArgument check only on 3 parameters
 */
- (id)initWithAPIKey:(NSString *)apiKey
           secretKey:(NSString *)secretKey
          parameters:(NSDictionary *)parameters
     completionBlock:(AlfrescoOAuthCompletionBlock)completionBlock
{
    return [self initWithAPIKey:apiKey
                      secretKey:secretKey
                    redirectURI:kAlfrescoCloudDefaultRedirectURI
                     parameters:parameters
                completionBlock:completionBlock];
}

/**
 apiKey, secretKey and completionBlock are mandatory. redirectURI and/or parameters aren't. Hence we do the assertArgument check only on 3 parameters
 */
- (id)initWithAPIKey:(NSString *)apiKey
           secretKey:(NSString *)secretKey
         redirectURI:(NSString *)redirectURI
          parameters:(NSDictionary *)parameters
     completionBlock:(AlfrescoOAuthCompletionBlock)completionBlock
{
    [AlfrescoErrors assertStringArgumentNotNilOrEmpty:apiKey argumentName:@"apiKey"];
    [AlfrescoErrors assertStringArgumentNotNilOrEmpty:secretKey argumentName:@"secretKey"];
    [AlfrescoErrors assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    self = [super init];
    if (nil != self)
    {        
        self.oauthData = [[AlfrescoOAuthData alloc] initWithAPIKey:apiKey secretKey:secretKey redirectURI:redirectURI];
        self.completionBlock = completionBlock;
        self.baseURL = [AlfrescoOAuthHelper buildCloudURLFromParameters:parameters];
    }
    return self;
}

#pragma mark - Lifecycle Methods

- (void)loadView
{
    NSView *view = [[NSView alloc] init];
    view.autoresizesSubviews = YES;
    view.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;

    // setup the webview
    WebView *webView = [[WebView alloc] initWithFrame:view.frame];
    webView.frameLoadDelegate = self;
    webView.policyDelegate = self;
    webView.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;
    [view addSubview:webView];
    self.webView = webView;
    
    self.view = view;
    
    self.isLoginScreenLoad = YES;
    self.cloudConnectionStatus = AlfrescoCloudConnectionStatusInactive;
    [self loadWebView];
    
}

#pragma mark - Private Methods

- (void)loadWebView
{
    if (!self.activityIndicator)
    {
        [self createActivityView];
    }
    [self.activityIndicator startAnimation:self];
    
    NSString *authURLString = [AlfrescoOAuthHelper buildOAuthURLWithBaseURLString:self.baseURL apiKey:self.oauthData.apiKey redirectURI:self.oauthData.redirectURI];
    
    // load the authorization URL in the web view
    NSURL *authURL = [NSURL URLWithString:authURLString];
    AlfrescoLogDebug(@"Loading webview with baseURL", self.baseURL);
    [self.webView.mainFrame loadRequest:[NSURLRequest requestWithURL:authURL]];
}

- (void)createActivityView
{
    CGSize size = self.view.bounds.size;
    CGFloat xOffset = size.width/2 - 50;
    CGFloat yOffset = size.height/2 - 50;
    CGRect viewFrame = CGRectMake(xOffset, yOffset, 100, 100);
    
    self.activityIndicator = [[NSProgressIndicator alloc] init];
    self.activityIndicator.style = NSProgressIndicatorSpinningStyle;
    self.activityIndicator.controlTint = NSGraphiteControlTint;
    [self.activityIndicator sizeToFit];
    self.activityIndicator.frame = viewFrame;
    self.activityIndicator.autoresizingMask = NSViewMinXMargin | NSViewMinYMargin | NSViewMaxXMargin | NSViewMaxYMargin;
    [self.activityIndicator setDisplayedWhenStopped:NO];
    [self.view addSubview:self.activityIndicator positioned:NSWindowAbove relativeTo:self.webView];
}

- (void)reloadAndReset
{
    if (nil != self.connection)
    {
        [self.connection cancel];
        self.cloudConnectionStatus = AlfrescoCloudConnectionStatusInactive;
        self.connection = nil;
    }
    
    [self.activityIndicator stopAnimation:self];
    
    [self.activityIndicator removeFromSuperview];
    self.activityIndicator = nil;
    
    self.isLoginScreenLoad = YES;
}

#pragma mark - WebFrameLoadDelegate Methods

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    AlfrescoLogDebug(@"WebFrameLoadDelegate didStartProvisionalLoadForFrame");
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    [self.activityIndicator stopAnimation:self];
    
    if (self.isLoginScreenLoad)
    {
        self.isLoginScreenLoad = NO;
    }
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame
{
    AlfrescoLogError(@"WebFrameLoadDelegate didFailLoadWithError");
    AlfrescoLogError(@"Error occurred while loading page: %@ with code %d and reason %@", [error localizedDescription], [error code], [error localizedFailureReason]);
    if (nil != self.oauthDelegate)
    {
        if ([self.oauthDelegate respondsToSelector:@selector(oauthLoginDidFailWithError:)])
        {
            [self.oauthDelegate oauthLoginDidFailWithError:error];
        }
        
        if (self.completionBlock != NULL)
        {
            self.completionBlock(nil, error);
        }
    }
    else
    {
        [self reloadAndReset];
    }
}

#pragma mark - WebPolicyDelegate Methods

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener
{
    int navigationType = [[actionInformation objectForKey: WebActionNavigationTypeKey] intValue];
    
    switch (navigationType)
    {
        case WebNavigationTypeFormSubmitted:
            self.isLoginScreenLoad = NO;
            break;
        case WebNavigationTypeFormResubmitted:
            self.isLoginScreenLoad = NO;
            break;
            
        default:
            break;
    }
    
    if (!self.isLoginScreenLoad)
    {
        NSArray *requestComponents = [[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"&"];
        
        if ([requestComponents containsObject:kAlfrescoOAuthRequestDenyAction])
        {
            NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeNetworkRequestCancelled];
            if ([self.oauthDelegate respondsToSelector:@selector(oauthLoginDidCancel)])
            {
                [self.oauthDelegate oauthLoginDidCancel];
            }
            else if ([self.oauthDelegate respondsToSelector:@selector(oauthLoginDidFailWithError:)])
            {
                [self.oauthDelegate oauthLoginDidFailWithError:error];
            }
            
            if (self.completionBlock != NULL)
            {
                self.completionBlock(nil, error);
            }
        }
        else if(self.cloudConnectionStatus == AlfrescoCloudConnectionStatusInactive)
        {
            [self.activityIndicator startAnimation:self];
            self.cloudConnectionStatus = AlfrescoCloudConnectionStatusActive;
            self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        }
        [listener ignore];
    }
    else
    {
        [listener use];
    }
}

#pragma mark - NSURLConnectionDelegate methods

/**
 this method is used for extracting the authentication code we receive back from the server when we
 first submit username/password
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    AlfrescoLogDebug(@"LoginNSViewController:didReceiveResponse");
    AlfrescoOAuthHelper *helper = [[AlfrescoOAuthHelper alloc] initWithParameters:self.parameters delegate:self.oauthDelegate];
    NSString *code = [helper authorizationCodeFromURL:response.URL];
    AlfrescoLogDebug(@"Extracted auth code: %@", code);
    
    if (nil != code)
    {
        self.hasValidAuthenticationCode = YES;
        
        // MOBSDK-772: if, for some reason, oauthData is nil, create and return an error
        if (self.oauthData == nil)
        {
            NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeOAuthDataMissing];
            
            AlfrescoLogError(@"OAuth data is missing!");
            if (nil != self.oauthDelegate)
            {
                if ([self.oauthDelegate respondsToSelector:@selector(oauthLoginDidFailWithError:)])
                {
                    [self.oauthDelegate oauthLoginDidFailWithError:error];
                }
            }
            
            self.completionBlock(nil, error);
            [self reloadAndReset];
        }
        else
        {
            [helper retrieveOAuthDataForAuthorizationCode:code oauthData:self.oauthData completionBlock:^(AlfrescoOAuthData *oauthData, NSError *error) {
                self.cloudConnectionStatus = error? AlfrescoCloudConnectionStatusInactive : AlfrescoCloudConnectionStatusGotAuthCode;
                self.completionBlock(oauthData, error);
            }];
        }
    }
    else
    {
        AlfrescoLogDebug(@"We don't have a valid authentication code");
        [self.activityIndicator stopAnimation:self];
        self.cloudConnectionStatus = AlfrescoCloudConnectionStatusInactive;
        self.hasValidAuthenticationCode = NO;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    AlfrescoLogDebug(@"LoginNSViewController:connection error with message %@ and code %d", [error localizedDescription], [error code]);
    [self.activityIndicator stopAnimation:self];
    if (nil != self.oauthDelegate)
    {
        if ([self.oauthDelegate respondsToSelector:@selector(oauthLoginDidFailWithError:)])
        {
            [self.oauthDelegate oauthLoginDidFailWithError:error];
        }
    }
    self.completionBlock(nil, error);
    [self reloadAndReset];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    AlfrescoLogDebug(@"LoginNSViewController:connectionDidFinishLoading");
    if (!self.hasValidAuthenticationCode)
    {
        NSError *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeHTTPResponse];
        BOOL showAlert = NO;
        AlfrescoLogDebug(@"We don't have a valid authentication code");
        if (nil != self.oauthDelegate)
        {
            if ([self.oauthDelegate respondsToSelector:@selector(oauthLoginDidFailWithError:)])
            {
                [self.oauthDelegate oauthLoginDidFailWithError:error];
            }
            else
            {
                showAlert = YES;
            }
            
            if (self.completionBlock != NULL)
            {
                self.completionBlock(nil, error);
                showAlert = NO;
            }
        }
        else
        {
            showAlert = YES;
        }
        if (showAlert)
        {
            NSAlert *alertView = [NSAlert alertWithMessageText:@"Error"
                                                 defaultButton:@"Ok"
                                               alternateButton:nil
                                                   otherButton:nil
                                     informativeTextWithFormat:@"Could not obtain authentication code from server. Possibly incorrect password/username"];
            [alertView beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            }];
        }
    }
}

@end
