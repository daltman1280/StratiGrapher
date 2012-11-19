//
//  DocumentListTableViewController.m
//  Strata Recorder
//
//  Created by daltman on 11/18/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import "DocumentListTableViewController.h"

@interface DocumentListTableViewController ()

@end

@implementation DocumentListTableViewController
- (IBAction)handleAddDocument:(id)sender {
}
- (IBAction)handleDeleteDocument:(id)sender {
}
- (IBAction)handleRenameDocument:(id)sender {
}
- (IBAction)handleDuplicateDocument:(id)sender {
}
- (IBAction)handleActionDocument:(id)sender {
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// setup toolbar
	self.toolbarItems = [NSArray arrayWithObjects:self.addDocument,
						 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
						 self.deleteDocument,
						 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
						 self.renameDocument,
						 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
						 self.duplicateDocument,
						 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
						 self.actionDocument,
						 nil];
	// setup Rename buttons
	UIImage *buttonImageNormal = [UIImage imageNamed:@"redButton.png"];
	UIImage *stretchableButtonImageNormal = [buttonImageNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	UIImage *buttonImagePressed = [UIImage imageNamed:@"darkRedButton.png"];
	UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	UIImage *buttonImageCancelNormal = [UIImage imageNamed:@"blueButton.png"];
	UIImage *stretchableButtonImageCancelNormal = [buttonImageCancelNormal stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	UIImage *buttonImageCancelPressed = [UIImage imageNamed:@"darkBlueButton.png"];
	UIImage *stretchableButtonImageCancelPressed = [buttonImageCancelPressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	
#if 0
	[renameOKButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
	[renameOKButton setBackgroundImage:stretchableButtonImagePressed forState:UIControlStateHighlighted];
	[renameCancelButton setBackgroundImage:stretchableButtonImageCancelNormal forState:UIControlStateNormal];
	[renameCancelButton setBackgroundImage:stretchableButtonImageCancelPressed forState:UIControlStateHighlighted];
#endif
    self.clearsSelectionOnViewWillAppear = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)viewDidUnload {
	[self setAddDocument:nil];
	[self setDeleteDocument:nil];
	[self setRenameDocument:nil];
	[self setDuplicateDocument:nil];
	[self setActionDocument:nil];
	[super viewDidUnload];
}
@end
