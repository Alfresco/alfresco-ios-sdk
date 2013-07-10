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

#import "AddCommentViewController.h"

@implementation AddCommentViewController

/**
 this method uses the AlfrescoCommentService class addCommentToNode method.
 */
- (IBAction)addComment:(id)sender
{
    if(nil != self.session && self.document != nil)
    {
        // add a comment using an AlfrescoCommentService
        AlfrescoCommentService *commentService = [[AlfrescoCommentService alloc] initWithSession:self.session];
        [commentService addCommentToNode:self.document content:self.commentView.text title:nil completionBlock:^(AlfrescoComment *comment, NSError *error) {
            if (nil == comment) 
            {
                [self showFailureAlert:@"error_add_comment"];
            }
            else if ([self.addCommentDelegate respondsToSelector:@selector(updateComments)])
            {
                [self.addCommentDelegate updateComments];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.commentView becomeFirstResponder];
}


@end
