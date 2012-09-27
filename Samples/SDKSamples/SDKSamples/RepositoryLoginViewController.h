//
//  RepositoryLoginViewController.h
//  SDKSamples
//
//  Created by Peter Schmidt on 26/09/2012.
//  Copyright (c) 2012 Alfresco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
@interface RepositoryLoginViewController : BaseTableViewController <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UITextField *urlField;
@property (nonatomic, weak) IBOutlet UITextField *usernameField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *doneButton;
- (IBAction)authenticateWhenDone:(id)sender;
@end
