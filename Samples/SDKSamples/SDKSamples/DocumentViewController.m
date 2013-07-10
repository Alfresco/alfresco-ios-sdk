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

#import "DocumentViewController.h"
#import "AlfrescoVersionService.h"
#import "AlfrescoComment.h"
#import "AlfrescoDocument.h"
#import "BasicPreviewItem.h"
#import "AlfrescoPerson.h"
#import "AlfrescoTag.h"
#import "AlfrescoLog.h"

@interface DocumentViewController ()

@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, strong) NSMutableArray *versions;
@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, strong) id<QLPreviewItem> documentPreviewItem;
@property (nonatomic, strong) NSMutableDictionary *avatarDictionary;
@property (nonatomic, strong) NSMutableDictionary *personDictionary;
- (void)loadComments;
- (void)loadVersions;
- (void)loadTags;
- (void)loadLike;
- (void)loadDocumentContent;
- (void)loadThumbnail;
- (void)loadAvatar:(UIImageView *) avatarImageView withUserId:(NSString *)userId;
- (NSString *)formattedStringUsingFormat:(NSString *)dateFormat date:(NSDate *)date;
- (NSString *) stringByStrippingHTML:(NSString *)htmlString;
- (NSString *)stringFromTagsArray:(NSArray *)tagsArray;
@end

@implementation DocumentViewController

@synthesize document = _document;
@synthesize commentService = _commentService;
@synthesize versionService = _versionService;
@synthesize documentService = _documentService;
@synthesize comments = _comments;
@synthesize versions = _versions;
@synthesize documentPreviewItem = _documentPreviewItem;
@synthesize downloadButton = _downloadButton;
@synthesize likeButton = _likeButton;
@synthesize commentButton = _commentButton;
@synthesize taggingService = _taggingService;
@synthesize ratingService = _ratingService;
@synthesize isLiked = _isLiked;
@synthesize tags = _tags;
@synthesize activityIndicator = _activityIndicator;
@synthesize thumbnail = _thumbnail;
@synthesize progressView = _progressView;
@synthesize tableView = _tableView;
@synthesize activityBarButton = _activityBarButton;
@synthesize avatarDictionary = _avatarDictionary;
@synthesize personDictionary = _personDictionary;
@synthesize personService = _personService;

#pragma mark - Alfresco Methods
/**
 This class demonstrates a variety of different methods that can be executed on documents. The Alfresco class to be used is
 AlfrescoDocumentFolderService - and it is probably one of the central pieces of functionality of the Alfresco SDK.
 The functionalities shown are
    - loading document
    - retrieving comments for the given document
    - retrieving tags for the given documents
    - retrieving a thumbnail for the given document
    - retrieving the versions for the given document
    - retrieving and setting the Ratings (Like) for the document
    - downloading the document
    - retrieving the avatar image of the users who commented
 
 A word on using references to 'self' from within blocks.
 Objects are stored as strong references within a block. This means, if you declare a block as a class property you run into the danger of
 creating a strong reference cycle (retain cycle).
 
 Say your class contains a property
 @property (nonatomic, copy)  AlfrescoArrayCompletionBlock completionBlock;
 
 And you reference the block in your code as
 myclass.completionBlock = ^(void)(NSArray *array, NSError *error)
 {
    [self.doSomething];
 };
 
 this would be a candidate for a retain cycle, as self is referenced strongly from within the block through its instance variable, while the class itself has a relationship to the block
 through its property.
 The recommended way to deal with this scenario is to do the following:
 
 MyClass __weak *weakSelf = self;
 myclass.completionBlock = ^(void)(NSArray *array, NSError *error)
 {
    [weakSelf.doSomething];
 }
 
 However, if you use the block locally from within the lexical scope of a function, then there is no need for this. The block gets created on the stack and goes out of scope once the method/block complete.

 */

/**
 loadThumbnail - gets the thumbnail image using the AlfrescoRenditionService.
 If no thumbnail is found it returns with a failure block. Note, failure block is also executed in case the thumbnail exists but the download fails.
 In either case, this is a non-fatal error and we simply show a dummy placeholder image
 */
- (void)loadThumbnail
{
    if(nil != self.session && self.document != nil)
    {
        self.documentService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.session];
//        __weak DocumentViewController *weakSelf = self;
        [self.documentService retrieveRenditionOfNode:self.document renditionName:kAlfrescoThumbnailRendition completionBlock:^(AlfrescoContentFile *contentFile, NSError *error){
             if (nil != contentFile)
             {
                 NSData *data = [[NSFileManager defaultManager] contentsAtPath:[contentFile.fileUrl path]];
                 self.thumbnail = [UIImage imageWithData:data];
                 [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
             }
         }];
    }
}

/**
 loadComments - gets an array of comments for the document using the AlfrescoCommentService.
 */
- (void)loadComments
{
    if(nil != self.session && self.document != nil)
    {
        // get the comments using an AlfrescoCommentService
        self.commentService = [[AlfrescoCommentService alloc] initWithSession:self.session];
//        __weak DocumentViewController *weakSelf = self;
        [self.activityIndicator startAnimating];
        
        [self.commentService retrieveCommentsForNode:self.document completionBlock:^(NSArray *array, NSError *error){
            if (nil == array) 
            {
                [self showFailureAlert:@"error_retrieve_comments"];
            }
            else if (0 < [array count]) 
            {
                self.comments = [NSArray arrayWithArray:array];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
            }
            [self.activityIndicator stopAnimating];
        }];
    }
}

/**
 loads the avatar of the user who commented on the document. It is using the AlfrescoPersonService to obtain the image.
 The avatar is being retrieved while the table is being loaded (see tableview method below).
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
    
//    __weak DocumentViewController *weakSelf = self;
    [self.personService retrievePersonWithIdentifier:userId completionBlock:^(AlfrescoPerson *person, NSError *error) {
        if (nil != person)
        {
            [self.personService retrieveAvatarForPerson:person completionBlock:^(AlfrescoContentFile *contentFile, NSError *error){
                if (nil != contentFile)
                {
                    NSData *data = [[NSFileManager defaultManager] contentsAtPath:[contentFile.fileUrl path]];
                    AlfrescoLogDebug(@"the avatar file is at location %@ and the length of the image data is %d",[contentFile.fileUrl path], data.length);
                    [self.avatarDictionary setObject:data forKey:userId];
                    avatarImageView.image = [UIImage imageWithData:data];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
                }
                else
                {
                    AlfrescoLogDebug(@"Failed to load avatar, error message is %@ and code is %d", [error localizedDescription], [error code]);
                }
            }];
        }
        
    }];
}

/**
 loadTags - gets an array of tags associated with the document using the AlfrescoTaggingService
 */
- (void)loadTags
{
    if(nil != self.session && self.document != nil)
    {
        self.taggingService = [[AlfrescoTaggingService alloc] initWithSession:self.session];
//        __weak DocumentViewController *weakSelf = self;
        [self.activityIndicator startAnimating];
        [self.taggingService retrieveTagsForNode:self.document 
                                 completionBlock:^(NSArray *array, NSError *error){
             if (nil == array) 
             {
                 [self showFailureAlert:@"error_retrieve_tags"];
             }
             else 
             {
                 [self.activityIndicator stopAnimating];
                 self.tags = [NSMutableArray arrayWithArray:array];
             }
             [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationNone];
         }];        
    }
}

/**
 loadVersions - gets the version IDs associated with the document using the AlfrescoVersionService
 */
- (void)loadVersions
{
    if(nil != self.session && self.document != nil)
    {
        // get the document versions using the AlfrescoVersionService
        self.versionService = [[AlfrescoVersionService alloc] initWithSession:self.session];
//        __weak DocumentViewController *weakSelf = self;
        [self.activityIndicator startAnimating];
        
        [self.versionService retrieveAllVersionsOfDocument:self.document completionBlock:^(NSArray *array, NSError *error){
            if (nil == array) 
            {
                [self showFailureAlert:@"error_retrieve_versions"];
            }
            else 
            {
                [self.activityIndicator stopAnimating];
                self.versions = [NSArray arrayWithArray:array];
            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:4] withRowAnimation:UITableViewRowAnimationNone];
        }];
    }
}


/**
 loadLike - gets the like tags associated with the document using the AlfrescoLikeService.
 For each user accessing the document the rating system is a simple binary value. 
 A user can either 'like' a document or 'unlike' it. Not that 'unlike'
 is not the same as dislike. It means, that the rating for the document has not been set.
 
 Note: retrieveLikeCountForNode of the AlfrescoLikeService counts the like 
 left behind by any user who tagged the document with a 'like'. 
 */
- (void)loadLike
{
    if(nil != self.session && self.document != nil)
    {
        self.ratingService = [[AlfrescoRatingService alloc] initWithSession:self.session];
//        __weak DocumentViewController *weakSelf = self;
        [self.activityIndicator startAnimating];
        [self.ratingService isNodeLiked:self.document 
                      completionBlock:^(BOOL success, BOOL pIsLiked, NSError *error){
             if (!success) 
             {
                 [self showFailureAlert:@"error_retrieve_likes"];
             }
             else 
             {
                 self.isLiked = pIsLiked;
                 if (pIsLiked == YES) 
                 {
                     [self.likeButton setImage:[UIImage imageNamed:@"like-checked.png"]];
                 }
                 else 
                 {
                     [self.likeButton setImage:[UIImage imageNamed:@"like-unchecked.png"]];
                 }
                 [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
             }
             [self.activityIndicator stopAnimating];
         }];        
    }
}

/**
 setLikeDocumentTag - illustrates how users can rate a document with a Like/unlike. 
 This is called when the user presses the like/unlike button in the toolbar
 of the sample app.
 */
- (IBAction)setLikeDocumentTag:(id)sender
{
    [self.activityIndicator startAnimating];
//    __weak DocumentViewController *weakSelf = self;
    if (self.isLiked == YES) 
    {
        [self.ratingService unlikeNode:self.document 
                     completionBlock:^(BOOL success, NSError *error){
             if (!success) 
             {
                 [self showFailureAlert:@"error_retrieve_likes"];
             }
             else 
             {
                 [self.likeButton setImage:[UIImage imageNamed:@"like-unchecked.png"]];
                 self.isLiked = NO;
             }
             [self.activityIndicator stopAnimating];
         }];
    }
    else 
    {
        [self.ratingService likeNode:self.document 
                   completionBlock:^(BOOL success, NSError *error){
             if (!success) 
             {
                 [self showFailureAlert:@"error_retrieve_likes"];
             }
             else 
             {
                 [self.likeButton setImage:[UIImage imageNamed:@"like-checked.png"]];
                 self.isLiked = YES;
             }
             [self.activityIndicator stopAnimating];
         }];
    }
}


/**
 loadDocumentContent - downloads the document content and shows it in a Preview. 
 This is activated when the user clicks on the download button in the
 tool bar of the Sample app
 */
- (void) loadDocumentContent
{
    self.documentService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.session];
    self.progressView.hidden = NO;
    self.progressView.progress = 0.0;
//    __weak DocumentViewController *weakSelf = self;
    if(nil != self.session && self.document != nil)
    {
        [self.documentService retrieveContentOfDocument:self.document
                                        completionBlock:^(AlfrescoContentFile *contentFile, NSError *error){
             if (nil == contentFile) 
             {
                 [self showFailureAlert:@"error_downloading_document"];
             }
             else 
             {
                 self.progressView.progress = 1.0;
                 self.documentPreviewItem = [[BasicPreviewItem alloc] initWithUrl:contentFile.fileUrl andTitle:self.document.name];
                 QLPreviewController *previewController = [[QLPreviewController alloc] init];
                 
                 //setting the datasource property to self
                 previewController.dataSource = self;
                 
                 //pushing the QLPreviewController to the navigation stack
                 [[self navigationController] pushViewController:previewController animated:YES];
                 [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
             }
             self.progressView.hidden = YES;
             [self.activityIndicator stopAnimating];
         } progressBlock:^(unsigned long long bytesTransferred, unsigned long long bytesTotal) {
             self.progressView.progress = (float)bytesTransferred/(float)bytesTotal;
         }];
    }
}


#pragma mark View Controller methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    //person service is used in more than one method so we init it here
    self.personService = [[AlfrescoPersonService alloc] initWithSession:self.session];
    self.progressView.hidden = YES;
    if (self.activityIndicator.isAnimating) 
    {
        [self.activityIndicator stopAnimating];
    }
    
    self.thumbnail = [UIImage imageNamed:@"mime_img.png"]; // for the case we don't have a thumbnail
    [self.activityBarButton setCustomView:self.activityIndicator];
    
    self.comments = [NSMutableArray array];
    self.tags = [NSMutableArray array];
    self.versions = [NSMutableArray array];
    self.avatarDictionary = [NSMutableDictionary dictionary];
    self.personDictionary = [NSMutableDictionary dictionary];
    
    self.title = self.document.name;
    [self loadComments];
    [self loadTags];
    [self loadVersions];
    [self loadThumbnail];
    
    if (self.session.repositoryInfo.capabilities.doesSupportLikingNodes)
    {
        [self loadLike];
    }
    else
    {
        self.likeButton.enabled = false;
    }
}

#pragma mark - Segue preparation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setSession:self.session];
    [[segue destinationViewController] setDocument:self.document];
    [[segue destinationViewController] setAddCommentDelegate:self];
}

#pragma mark - Selector methods

- (IBAction)downloadDocument:(id)sender
{
    [self loadDocumentContent];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headerTitle = @"";
    if (1 == section) 
    {
        headerTitle = @"document_general_metadata_header";
    }
    else if (2 == section)
    {
        headerTitle = @"document_comments_header";
    }
    else if (3 == section) 
    {
        headerTitle = @"document_tags_header";
    }
    else if (4 == section)
    {
        headerTitle = @"document_version_header";
    }
    return localized(headerTitle);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 1;
    }
    else if (1 == section)
    {
        return 6;
    }
    else if (2 == section)
    {
        if (self.comments.count > 0)
        {
            return self.comments.count;
        }
        else 
        {
            return 1;
        }
    }
    else if (3 == section) 
    {
        return 1;
    }
    else 
    {
        if (self.versions.count > 0)
        {
            return self.versions.count;
        }
        else 
        {
            return 1;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        return 105.0;
    }
    else if (2 == indexPath.section && self.comments.count > 0)
    {
        return 108.0;
    }
    else
    {
        return 45.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(0 == indexPath.section)
    {
        static NSString *CellIdentifier = @"thumbnailCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];        
        UIImageView *documentThumbnailView = (UIImageView *)[cell viewWithTag:0];
        [documentThumbnailView setImage:self.thumbnail];
        
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
        nameLabel.text = self.document.name;
        UILabel *versionLabel = (UILabel *)[cell viewWithTag:3];
        if (!self.document.versionLabel || [self.document.versionLabel isEqualToString:@"0.0"])
        {
            versionLabel.text = @"v1.0";
        }
        else 
        {
            versionLabel.text = [NSString stringWithFormat:@"v%@", self.document.versionLabel];
        }
    }
    else if (1 == indexPath.section) 
    {
        static NSString *CellIdentifier = @"subTitleCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        NSString *noneLocalized = localized(@"document_general_nodata");
        
        if (indexPath.row == 0)
        {
            cell.textLabel.text = localized(@"document_general_metadata_title");
            cell.detailTextLabel.text = ((self.document.title && ![self.document.title isEqualToString:@"(null)"]) ? self.document.title : noneLocalized);
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = localized(@"document_general_metadata_description");
            cell.detailTextLabel.text = ((self.document.summary) ? self.document.summary : noneLocalized);
        }
        else if (indexPath.row == 2)
        {
            cell.textLabel.text = localized(@"document_general_metadata_createdby");
            cell.detailTextLabel.text = ((self.document.createdBy) ? self.document.createdBy : noneLocalized);
        }
        else if (indexPath.row == 3)
        {
            cell.textLabel.text = localized(@"document_general_metadata_createdon");
            cell.detailTextLabel.text = [self formattedStringUsingFormat:@"yyyy-MM-dd HH:mm:ss" date:self.document.createdAt];
        }
        else if (indexPath.row == 4)
        {
            cell.textLabel.text = localized(@"document_general_metadata_modifiedby");
            cell.detailTextLabel.text = ((self.document.modifiedBy) ? self.document.modifiedBy : noneLocalized);
        }
        else if (indexPath.row == 5)
        {
            cell.textLabel.text = localized(@"document_general_metadata_modifiedon");
            cell.detailTextLabel.text = [self formattedStringUsingFormat:@"yyyy-MM-dd HH:mm:ss" date:self.document.modifiedAt];
        }
        
    }
    else if(indexPath.section == 2)
    {
        if (self.comments.count > 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
            UILabel *authorLabel = (UILabel *)[cell viewWithTag:1];
            UILabel *dataLabel = (UILabel *)[cell viewWithTag:2];
            
            AlfrescoComment *comment = [self.comments objectAtIndex:indexPath.row];
            authorLabel.text = comment.createdBy;
            dataLabel.text = [self formattedStringUsingFormat:@"yyyy-MM-dd HH:mm:ss" date:comment.createdAt];
            
            UILabel *commentView = (UILabel *)[cell viewWithTag:3];
            commentView.text = [self stringByStrippingHTML:comment.content];
            
            UIImageView *avatarView = (UIImageView *)[cell viewWithTag:4];
            avatarView.contentMode = UIViewContentModeScaleAspectFit;
            [avatarView setImage:[UIImage imageNamed:@"avatar.png"]];
            /**
             load the avatar for the person
             */
            [self loadAvatar:avatarView withUserId:comment.createdBy];
        }
        else 
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"noCommentCell"];
            cell.textLabel.text = localized(@"document_comments_nocomments");
        }
    }
    else if (3 == indexPath.section) 
    {
        
        if (self.tags.count > 0) 
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell"];
            UILabel *textLabel = (UILabel *)[cell viewWithTag:1];
            NSString *tagsText = [self stringFromTagsArray:self.tags];
            textLabel.text = tagsText;
        }
        else 
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"noCommentCell"];
            cell.textLabel.text = localized(@"document_tags_notags");
        }
    }
    else 
    {
        if (self.versions.count > 0) 
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"titleCell"];
            UILabel *textLabel = (UILabel *)[cell viewWithTag:1];
            AlfrescoDocument *document = [self.versions objectAtIndex:indexPath.row];
            NSString *versionText;
            if (!document.versionLabel || [document.versionLabel isEqualToString:@"0.0"])
            {
                versionText = @"v1.0";
            }
            else 
            {
                versionText = [NSString stringWithFormat:@"v%@", document.versionLabel];
            }
            textLabel.text = [NSString stringWithFormat:@"%@ - %@ - %@", versionText, document.modifiedBy, 
                                   [self formattedStringUsingFormat:@"yyyy-MM-dd HH:mm:ss" date:document.modifiedAt]];
        }
        else 
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"noCommentCell"];
            cell.textLabel.text = localized(@"document_versions_noversions");
          
        }
    }
    
    return cell;
}

#pragma mark comment delegate

- (void)updateComments
{
    [self loadComments];
}

#pragma mark - QLPreviewControllerDataSource methods.

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}


- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller
                    previewItemAtIndex:(NSInteger)index {
    return self.documentPreviewItem;
}


#pragma mark - Private Methods


- (NSString *)formattedStringUsingFormat:(NSString *)dateFormat date:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:[NSLocale currentLocale]];
    NSString *ret = [formatter stringFromDate:date];
    return ret;
}

- (NSString *) stringByStrippingHTML:(NSString *)htmlString 
{
    NSRange r;
    NSString *s = [htmlString copy];
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s; 
}


- (NSString *)stringFromTagsArray:(NSArray *)tagsArray
{
    NSMutableString *combinedTagString = [NSMutableString string];
    BOOL first = YES;
    for (AlfrescoTag *tag in tagsArray)
    {
        if (first == YES)
        {
            first = NO;
        }
        else 
        {
            [combinedTagString appendString:@", "];
        }
        [combinedTagString appendString:tag.value];
    }
    return combinedTagString;
}

@end
