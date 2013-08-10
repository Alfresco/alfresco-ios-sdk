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

#import "SearchViewController.h"
#import "SearchResultViewController.h"

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = localized(@"search_title");
    [self.searchField becomeFirstResponder];
    self.searchButton.enabled = NO;
}

#pragma mark - Table View

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setSession:self.session];
    [[segue destinationViewController] setSearchText:self.searchField.text];
    [[segue destinationViewController] setFullText:self.fullTextSwitch.isOn];
    [[segue destinationViewController] setExact:self.exactSwitch.isOn];
    [[segue destinationViewController] setAllMetadata:self.allMetadataSwitch.isOn];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.searchButton.enabled = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (!self.searchButton.isEnabled) 
    {
        self.searchButton.enabled = YES;
    }
}

@end
