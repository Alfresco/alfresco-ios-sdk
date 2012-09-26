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

#import "FolderViewController.h"
#import "DocumentViewController.h"

@interface FolderViewController ()
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) AlfrescoDocumentFolderService *documentFolderService;
@property BOOL hasMoreItems;
@end

@interface FolderViewController (PrivateMethods)
- (void)loadChildrenForCurrentPage:(UIActivityIndicatorView *)activityIndicator;
@end

@implementation FolderViewController

@synthesize folder = _folder;
@synthesize items = _items;
@synthesize displayItemsCount = _displayItemsCount;
@synthesize listingContext = _listingContext;
@synthesize hasMoreItems = _hasMoreItems;
@synthesize documentFolderService = _documentFolderService;

#pragma mark - Alfresco Methods for retrieving content of folders


/**
 loadChildrenForCurrentPage gets a specified number of children for the given folder. 
 To specify the number of childrens retrieved for a given folder you need to create an
 AlfrescoListingContext object and set the maxItems member variable to the number of items per page.
 */
- (void)loadChildrenForCurrentPage:(UIActivityIndicatorView *)activityIndicator
{
    if (nil == self.session || nil == self.folder) 
    {
        [activityIndicator stopAnimating];
        return;
    }
    
    self.documentFolderService = [[AlfrescoDocumentFolderService alloc] initWithSession:self.session];
    __weak FolderViewController *weakSelf = self;
    [self.documentFolderService retrieveChildrenInFolder:self.folder listingContext:self.listingContext
                                         completionBlock:^(AlfrescoPagingResult *pagingResult, NSError *error){
         [activityIndicator stopAnimating];
         if (nil == pagingResult) 
         {
             [weakSelf showFailureAlert:@"error_retrieve_children"];
         }
         else 
         {
             [weakSelf.items addObjectsFromArray:pagingResult.objects];
             weakSelf.displayItemsCount = weakSelf.displayItemsCount + pagingResult.objects.count;
             weakSelf.hasMoreItems = pagingResult.hasMoreItems;
             [weakSelf.tableView reloadData];
         }
     }];
}


#pragma mark View Controller methods


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.items = [NSMutableArray array];
    self.hasMoreItems = NO;
    self.displayItemsCount = 0;
    self.title = self.folder.name;
    self.listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:MAXNUMBERITEMS skipCount:0];
    [self loadChildrenForCurrentPage:nil];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.hasMoreItems) 
    {
        return self.items.count + 1;
    }
    else 
    {
        return self.items.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == self.items.count && self.hasMoreItems)
    {
        NSString *CellIdentifier = @"loadMoreCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UILabel *textLabel = (UILabel *)[cell viewWithTag:1];
        textLabel.text = localized(@"load_more");
        return cell;
    }
    else 
    {
        NSString *CellIdentifier;
        if(indexPath.row > self.items.count)
        {
            return [tableView dequeueReusableCellWithIdentifier:@"docCell"];
        }
        
        AlfrescoNode *node = [self.items objectAtIndex:indexPath.row];
        if (node.isFolder)
        {
            CellIdentifier = @"nodeCell";
        }
        else
        {
            CellIdentifier = @"docCell";
        }
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.textLabel.text = node.name;
        if(node.summary != nil && [node.summary length] > 0)
        {
            cell.detailTextLabel.text = node.summary;
        }
        else 
        {
            cell.detailTextLabel.text = localized(@"no_description");
        }
        if (node.isFolder)
        {
            UIImage *img = [UIImage imageNamed:@"folder.png"];
            cell.imageView.image  = img;
        }
        else 
        {
            UIImage *img;
            NSRange extensionRange = [node.name rangeOfString:@"." options:NSBackwardsSearch];
            if (NSNotFound == extensionRange.location) 
            {
                img = [UIImage imageNamed:@"generic.png"];
            }
            else 
            {
                NSString *extension = [[node.name substringFromIndex:extensionRange.location + 1] lowercaseString];
                if ([extension isEqualToString:@"doc"] || [extension isEqualToString:@"docx"])
                {
                    img = [UIImage imageNamed:@"mime_doc.png"];
                }
                else if ([extension isEqualToString:@"pdf"])
                {
                    img = [UIImage imageNamed:@"mime_pdf.png"];
                }
                else if ([extension isEqualToString:@"txt"])
                {
                    img = [UIImage imageNamed:@"mime_txt.png"];
                }
                else if ([extension isEqualToString:@"ppt"] || [extension isEqualToString:@"pptx"])
                {
                    img = [UIImage imageNamed:@"mime_ppt.png"];
                }
                else if ([extension isEqualToString:@"xls"] || [extension isEqualToString:@"xlsx"])
                {
                    img = [UIImage imageNamed:@"mime_xls.png"];
                }
                else if ([extension isEqualToString:@"jpg"] || [extension isEqualToString:@"jpeg"] || 
                         [extension isEqualToString:@"png"] || [extension isEqualToString:@"bmp"])
                {
                    img = [UIImage imageNamed:@"mime_img.png"];
                }
                else if ([extension isEqualToString:@"avi"] || [extension isEqualToString:@"mpg"] || 
                         [extension isEqualToString:@"mpeg"])
                {
                    img = [UIImage imageNamed:@"mime_video.png"];
                }
                else if ([extension isEqualToString:@"xml"])
                {
                    img = [UIImage imageNamed:@"mime_xml.png"];
                }
                else if ([extension isEqualToString:@"zip"])
                {
                    img = [UIImage imageNamed:@"mime_zip.png"];
                }
                else 
                {
                    img = [UIImage imageNamed:@"generic.png"];
                }
            }
            cell.imageView.image  = img;
        }
        
        return cell;
    }
    return nil;    
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"addFolder"]) 
    {
        [[segue destinationViewController] setAddNewItemDelegate:self];
        [[segue destinationViewController] setSession:self.session];
        [[segue destinationViewController] setFolder:self.folder];        
    }
    else 
    {
        if (0 == [self.items count]) 
        {
            return;
        }
        AlfrescoNode *node = [self.items objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        if (node.isFolder)
        {
            [[segue destinationViewController] setSession:self.session];
            [[segue destinationViewController] setFolder:(AlfrescoFolder *)node];
            AlfrescoListingContext *nextListingContext = [[AlfrescoListingContext alloc] initWithMaxItems:self.listingContext.maxItems skipCount:0];
            [[segue destinationViewController] setListingContext:nextListingContext];
        }
        else
        {
            [[segue destinationViewController] setSession:self.session];
            [[segue destinationViewController] setDocument:(AlfrescoDocument *)node];
        }
    }    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([[cell reuseIdentifier] isEqualToString:@"loadMoreCell"])
    {
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell viewWithTag:2];
        [activityIndicator startAnimating];
        int maxItems = self.listingContext.maxItems;
        int skipCount = self.displayItemsCount;
        self.listingContext = nil;
        self.listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:maxItems skipCount:skipCount];
        [self loadChildrenForCurrentPage:activityIndicator];
    }
}

#pragma mark - Add Folder delegate method
- (void)updateFolderContent
{
    self.items = [NSMutableArray array];
    self.displayItemsCount = 0;
    int maxItems = self.listingContext.maxItems;
    self.listingContext = nil;
    self.listingContext = [[AlfrescoListingContext alloc] initWithMaxItems:maxItems skipCount:0];
    [self loadChildrenForCurrentPage:nil];
}




@end
