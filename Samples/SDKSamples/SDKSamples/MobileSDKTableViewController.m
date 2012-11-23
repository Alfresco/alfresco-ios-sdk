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

#import "MobileSDKTableViewController.h"
#import "MobileSDKWebViewController.h"
#import "AlfrescoErrors.h"

@interface MobileSDKTableViewController ()
@end

@implementation MobileSDKTableViewController
@synthesize samplesLabel = _samplesLabel;
@synthesize referenceLabel = _referenceLabel;
@synthesize learnMoreLabel = _learnMoreLabel;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = localized(@"sample_app_name");
    self.samplesLabel.text = localized(@"samples_option");
    self.referenceLabel.text = localized(@"api_reference_option");
    self.learnMoreLabel.text = localized(@"learn_more_option");
    
    log(@"SDKSamples is using v%@ of the Alfresco SDK.", kAlfrescoSDKVersion);
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *revisionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *revisionLabel = localized(@"revision_label");
    return [NSString stringWithFormat:@"%@ %@.", revisionLabel, revisionNumber];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"apiReference"]) 
    {
        [[segue destinationViewController] setNavTitle:localized(@"api_reference_option")];
        [[segue destinationViewController] setUrlToLoad:[NSURL URLWithString:localized(@"api_reference_url")]];
    }
    if ([[segue identifier] isEqualToString:@"learnMore"]) 
    {
        [[segue destinationViewController] setNavTitle:localized(@"learn_more_option")];
        [[segue destinationViewController] setUrlToLoad:[NSURL URLWithString:localized(@"learn_more_url")]];
    }
}

@end
