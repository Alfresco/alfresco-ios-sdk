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

#import "AddNewItemTableViewController.h"

@interface AddNewItemTableViewController ()
@property (nonatomic, strong) UIImage *selectedPhoto;
@property BOOL isFolderTextInput;
@property BOOL isIPad;
@property (nonatomic, strong) UIPopoverController *iPadPopoverController;

- (void)loadImagePicker;
- (void)showTextInputAlert;
- (void)saveNewFolder;
- (void)uploadPhotoWithName:(NSString *)name description:(NSString *)description tags:(NSArray *)tags;
@end

@implementation AddNewItemTableViewController

#pragma mark - Alfresco methods

/**
 saveNewFolder: saves and adds the folder to the parent folder using the method createFolderWithName 
 of the AlfrescoDocumentFolderService. 
 After that is pops the view controller back to the parent view controller
 */
- (void)saveNewFolder
{
    [self.activityIndicatorView startAnimating];
    self.documentFolderService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.session];

    __weak typeof(self) weakSelf = self;
    [self.documentFolderService createFolderWithName:self.folderLabel.text inParentFolder:self.folder properties:nil completionBlock:^(AlfrescoFolder *folder, NSError *error){
        if (nil == folder)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localized(@"error_title")
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:localized(@"dialog_cancel")
                                                  otherButtonTitles: nil];
            [alert show];
            [weakSelf.activityIndicatorView stopAnimating];
            weakSelf.folderLabel.text = localized(@"add_folder_option");
        }
        else
        {
            if ([weakSelf.addNewItemDelegate respondsToSelector:@selector(updateFolderContent)])
            {
                [weakSelf.addNewItemDelegate updateFolderContent];
            }
            [weakSelf.activityIndicatorView stopAnimating];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}

/**
 uploadPhoto: uses the AlfrescoDocumentFolderService to upload an image using the method createDocumentWithName method
 */
- (void)uploadPhotoWithName:(NSString *)name description:(NSString *)description tags:(NSArray *)tags
{
    self.progressView.hidden = NO;
    [self.progressView setProgress:0.0];
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithObject:name forKey:@"cm:title"];
    if (description)
    {
        [properties setValue:description forKey:@"cm:description"];
    }
    
    self.documentFolderService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.session];
    AlfrescoContentFile *imageFile = nil;
    if ([[name lowercaseString] hasSuffix:@".jpg"]) 
    {
        imageFile = [[AlfrescoContentFile alloc] 
                     initWithData:UIImageJPEGRepresentation(self.selectedPhoto, 1.0) 
                     mimeType:@"image/jpeg"];
    }
    else if ([[name lowercaseString] hasSuffix:@".png"]) 
    {
        imageFile = [[AlfrescoContentFile alloc] 
                     initWithData:UIImagePNGRepresentation(self.selectedPhoto) 
                     mimeType:@"image/png"];
    }
    else 
    {
        imageFile = [[AlfrescoContentFile alloc] 
                     initWithData:UIImageJPEGRepresentation(self.selectedPhoto, 1.0) 
                     mimeType:@"image/jpeg"];
    }
    
    [self.documentFolderService createDocumentWithName:name
                                        inParentFolder:self.folder 
                                           contentFile:imageFile
                                            properties:properties
                                       completionBlock:^(AlfrescoDocument *document, NSError *error){
          if (nil == document) 
          {                                               
              self.progressView.hidden = YES;
              UIAlertView *alert = [[UIAlertView alloc] 
                                    initWithTitle:localized(@"error_title")
                                    message:[NSString stringWithFormat:@"%@, %@", localized(@"error_uploading_document"), [error localizedDescription]]
                                    delegate:nil 
                                    cancelButtonTitle:localized(@"dialog_cancel")
                                    otherButtonTitles: nil];
              alert.alertViewStyle = UIAlertViewStyleDefault;
              [alert show];    
              self.photoLabel.text = localized(@"add_photo_option");
          }
          else 
          {
              if (tags.count > 0)
              {
                  // convert tag objects into strings
                  NSMutableArray *tagStrings = [NSMutableArray arrayWithCapacity:tags.count];
                  for (AlfrescoTag *tag in tags)
                  {
                      [tagStrings addObject:tag.value];
                  }
                  
                  self.taggingService = [[AlfrescoTaggingService alloc] initWithSession:self.session];
                  __weak typeof(self) weakSelf = self;
                  [self.taggingService addTags:tagStrings toNode:document completionBlock:^(BOOL success, NSError *error){
                      if (!success) 
                      {
                          weakSelf.progressView.hidden = YES;
                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:localized(@"error_title")
                                                                          message:[NSString stringWithFormat:@"%@, %@",localized(@"error_adding_tags"), [error localizedDescription]] 
                                                                         delegate:nil 
                                                                cancelButtonTitle:localized(@"dialog_cancel")
                                                                otherButtonTitles:nil];
                          alert.alertViewStyle = UIAlertViewStyleDefault;
                          [alert show];
                      }
                      else 
                      {
                          weakSelf.progressView.progress = 1.0;
                          if ([weakSelf.addNewItemDelegate respondsToSelector:@selector(updateFolderContent)])
                          {
                              [weakSelf.addNewItemDelegate updateFolderContent];
                          }
                          weakSelf.progressView.hidden = YES;
                          [weakSelf.navigationController popViewControllerAnimated:YES];
                      }
                       
                  }];
              }
              else 
              {
                  self.progressView.progress = 1.0;
                  if ([self.addNewItemDelegate respondsToSelector:@selector(updateFolderContent)])
                  {
                      [self.addNewItemDelegate updateFolderContent];
                  }
                  self.progressView.hidden = YES;
                  [self.navigationController popViewControllerAnimated:YES];                                                   
              }
          }
      } progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal) {
          self.progressView.progress = ((float)bytesTransferred/(float)bytesTotal) - 0.3;
      }];
}

#pragma mark - Add photo delegate

- (void) updatePhotoInfoWithName:(NSString *)name description:(NSString *)description tags:(NSArray *)tags
{
    self.photoLabel.text = name;            
    [self uploadPhotoWithName:name description:description tags:tags];
}

#pragma mark - View Controller methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.progressView.hidden = YES;
    self.activityIndicatorView.hidden = YES;
    self.isFolderTextInput = YES;
    if (self.activityIndicatorView.isAnimating) 
    {
        [self.activityIndicatorView stopAnimating];
    }
    
    if (UIUserInterfaceIdiomPhone == [[UIDevice currentDevice] userInterfaceIdiom]) 
    {
        self.isIPad = NO;
    }
    else 
    {
        self.isIPad = YES;
    }
        
    self.navigationItem.title = localized(@"add_new_title");
    self.photoLabel.text = localized(@"add_photo_option");
    self.folderLabel.text = localized(@"add_folder_option");
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.row) 
    {
        self.isFolderTextInput = YES;
        [self showTextInputAlert];
    }
    if (1 == indexPath.row) 
    {
        self.isFolderTextInput = NO;
        [self loadImagePicker];
    }
}



#pragma mark - Alert View Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (UIAlertViewStylePlainTextInput != alertView.alertViewStyle) 
    {
        return;
    }
    
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle hasPrefix:localized(@"dialog_ok")])
    {
        UITextField *alertTextfield = [alertView textFieldAtIndex:0];
        self.folderLabel.text = alertTextfield.text;
        [self saveNewFolder];
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if ([alertView textFieldAtIndex:0].text.length == 0)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark - Image Picker Controller Delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.isIPad) 
    {
        [self.iPadPopoverController dismissPopoverAnimated:YES];
    }
    
    self.selectedPhoto = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSString *fileName = [[info objectForKey:UIImagePickerControllerReferenceURL] lastPathComponent];
    NSString *extension;
    if ([[fileName lowercaseString] hasSuffix:@".png"]) 
    {
        extension = @"png";
    }
    else 
    {
        extension = @"jpg";
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMddHHmmss"];
    [formatter setLocale:[NSLocale currentLocale]];
    NSString *dateString = [formatter stringFromDate:[NSDate new]];
    NSString *photoName = [NSString stringWithFormat:@"photo-%@.%@", dateString, extension];
    
    self.photoLabel.text = photoName;
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier:@"setDocumentInfo" sender:photoName];
}

#pragma mark - Segue logic
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setSession:self.session];
    [[segue destinationViewController] setDocumentName:sender];
    [[segue destinationViewController] setAddPhotoDelegate:self];
}

#pragma mark - private methods
- (void)showTextInputAlert
{
    NSString *message = localized(@"folder_dialog_message");
    UIAlertView *newFolderAlertView = [[UIAlertView alloc]initWithTitle:localized(@"add_folder_option") 
                                                                message: message
                                                               delegate:self 
                                                      cancelButtonTitle:localized(@"dialog_cancel")  
                                                      otherButtonTitles:localized(@"dialog_ok"), nil]; 
    
    [newFolderAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [newFolderAlertView show];    
}


- (void)loadImagePicker
{
    if (self.isIPad && [self.iPadPopoverController isPopoverVisible]) 
    {
        [self.iPadPopoverController dismissPopoverAnimated:YES];
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) 
    {
        [self showFailureAlert:localized(@"error_no_photo_library")];
        return;
    }
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate:self];
    [imagePicker setAllowsEditing:NO];
    
    if (self.isIPad) 
    {
        self.iPadPopoverController = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
        self.iPadPopoverController.delegate = self;
        [self.iPadPopoverController presentPopoverFromRect:self.photoLabel.bounds inView:self.photoLabel permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else 
    {
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}



@end
