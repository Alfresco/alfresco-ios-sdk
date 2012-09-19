//
//  OAuthLoginWebViewController.h
//  HelloRepo
//
//  Created by Peter Schmidt on 19/09/2012.
//  Copyright (c) 2012 Gavin Cornwell. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APIKEY @"l7xx6f56d3e7e94343afb788f4d6a148e8da"
#define SECRETKEY @"275263c89d9044dd8c5aebb99188e1bb"
#define BASEURL @"https://api.alfresco.com/auth/oauth/versions/2/authorize"

@interface OAuthLoginWebViewController : UIViewController <UIWebViewDelegate>
@property (nonatomic, strong) UIWebView * webView;
- (id)initWithAPIKey:(NSString *)apiKey secretKey:(NSString *)secretKey redirectURI:(NSString *)redirectURI;
@end
