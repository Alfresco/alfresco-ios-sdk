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

#import "ActivitiesTableViewController.h"
#import "AlfrescoActivityEntry.h"
#import "AlfrescoContentFile.h"
#import "AlfrescoErrors.h"
#import "AlfrescoLog.h"

@interface ActivitiesTableViewController ()
@property (nonatomic, strong) AlfrescoActivityStreamService *activityStreamService;
@property (nonatomic, strong) NSMutableArray *activities;
@property (nonatomic, strong) NSMutableDictionary *avatarDictionary;
- (void)loadActivities;
- (NSString *)replaceStringWithPlaceholders:(NSString *)originalString placeholderReplacements:(NSArray *)replacements error:(NSError **)error;
- (NSString *)stringKeyFromOriginal:(NSString *)stringKey;
@end

@implementation ActivitiesTableViewController

#pragma mark - Alfresco methods

/**
 loadActivities - gets the list of activities using the AlfrescoActivityStreamService.
 */
- (void)loadActivities
{
    if (nil == self.session) 
    {
        return;
    }
    self.activityStreamService = [[AlfrescoActivityStreamService alloc] initWithSession:self.session];
    [self.activityIndicator startAnimating];
    [self.activityStreamService retrieveActivityStreamWithCompletionBlock:^(NSArray *array, NSError *error){
         if (nil == array) 
         {
             [self showFailureAlert:@"error_retrieve_activities"];
         }
         else 
         {
             self.activities = [NSMutableArray arrayWithArray:array];
             [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
         }
         [self.activityIndicator stopAnimating];
     }];    
}

/**
 loadAvatars - gets the avatar images using the AlfrescoPersonService. The avatars are loaded at the point of table (re)loading.
 */
- (void)loadAvatar:(UIImageView *) avatarImageView withUserId:(NSString *)userId
{
    if (nil == self.session) 
    {
        return;
    }
    
    if ([self.avatarDictionary objectForKey:userId])
    {
        avatarImageView.image = [UIImage imageWithData:[self.avatarDictionary objectForKey:userId]];
        return;
    }
    else
    {
        // set a default placeholder to display until the real avatar (if there is one) is retrieved
        [avatarImageView setImage:[UIImage imageNamed:@"avatar.png"]];
    }
    
    [self.personService retrievePersonWithIdentifier:userId completionBlock:^(AlfrescoPerson *person, NSError *error) {
        if (nil != person)
        {
            [self.personService retrieveAvatarForPerson:person completionBlock:^(AlfrescoContentFile *contentFile, NSError *error){
                if (nil != contentFile)
                {
                    NSData *data = [[NSFileManager defaultManager] contentsAtPath:[contentFile.fileUrl path]];
                    [self.avatarDictionary setObject:data forKey:userId];
                    avatarImageView.image = [UIImage imageWithData:data];
                }
                else
                {
                    AlfrescoLogDebug(@"Failed to load avatar, error message is %@ and code is %d", [error localizedDescription], [error code]);
                }
            }];
        }
    }];
}

#pragma mark - helper methods

- (NSString *)replaceStringWithPlaceholders:(NSString *)originalString placeholderReplacements:(NSArray *)replacements  error:(NSError **)error
{
    if (nil == replacements || nil == originalString)
    {
        return originalString;
    }
    if (0 == replacements.count)
    {
        return originalString;
    }
    if (0 == originalString.length)
    {
        return originalString;
    }
    int index = 0;
    for (id replacement in replacements)
    {
        NSString *placeholderString = [NSString stringWithFormat:@"{%d}",index];
        NSString *replacementString = nil;
        
        if ([replacement isKindOfClass:[NSString class]]) {
            replacementString = (NSString *)replacement;
        }
        else if ([replacement isKindOfClass:[NSNumber class]])
        {
            NSNumber *number = (NSNumber *)replacement;
            replacementString = [NSString stringWithFormat:@"%d",[number intValue]];
        }
        else
        {
            if (error)
            {
                *error = [AlfrescoErrors alfrescoErrorWithAlfrescoErrorCode:kAlfrescoErrorCodeJSONParsing];
            }
            
            return nil;
        }
        originalString = [originalString
                          stringByReplacingOccurrencesOfString:placeholderString
                          withString:replacementString];
        index++;
    }
    return originalString;
}

- (NSString *)stringKeyFromOriginal:(NSString *)stringKey
{
    stringKey = [stringKey stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
    return [stringKey stringByReplacingOccurrencesOfString:@"." withString:@"_"];
}

#pragma mark - View Controller methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.activities = [NSMutableArray array];
    self.avatarDictionary = [NSMutableDictionary dictionary];
    self.personService = [[AlfrescoPersonService alloc] initWithSession:self.session];

    self.navigationItem.title = localized(@"select_activities_title");
    [self loadActivities];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.activities.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UIUserInterfaceIdiomPhone == [[UIDevice currentDevice] userInterfaceIdiom]) 
    {
        return 75.0;        
    }
    else 
    {
        return 63.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"activityCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    AlfrescoActivityEntry *activityEntry = (AlfrescoActivityEntry *)[self.activities objectAtIndex:indexPath.row];
    
    UIImageView *documentThumbnailView = (UIImageView *)[cell viewWithTag:1];
    documentThumbnailView.contentMode = UIViewContentModeScaleAspectFit;
    documentThumbnailView.image = nil;
    
    /**
     load the avatar for the person
     */
    [self loadAvatar:documentThumbnailView withUserId:activityEntry.createdBy];
    
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:3];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setLocale:[NSLocale currentLocale]];
    dateLabel.text = [formatter stringFromDate:activityEntry.createdAt];

    NSString *localizedTypeKey = [self stringKeyFromOriginal:activityEntry.type];
    NSString *parametisedString = localized(localizedTypeKey);
    id titleData = [activityEntry.data valueForKey:@"title"];
        
    NSArray *replacementStrings = [NSArray arrayWithObjects:titleData, activityEntry.createdBy, @"", @"", activityEntry.siteShortName, nil];
    NSError *error = nil;
    NSString *displayedText = [self replaceStringWithPlaceholders:parametisedString placeholderReplacements:replacementStrings error:&error];
    if (nil != displayedText) 
    {
        UILabel *activityLabel = (UILabel *)[cell viewWithTag:4];
        activityLabel.text = displayedText;
    }    
    
    return cell;
}

@end
