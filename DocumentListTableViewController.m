//
//  DocumentListTableViewController.m
//  Strata Recorder
//
//  Created by daltman on 11/18/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import "DocumentListTableViewController.h"

@interface DocumentListTableViewController ()

@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;

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
	exportPaperActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Feedback…", @"Email .docx", @"Export .docx", @"Email PDF", @"Export PDF",nil];
	[exportPaperActionSheet showFromBarButtonItem:self.actionDocument animated:YES];
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
    self.clearsSelectionOnViewWillAppear = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
#if 0
	[self.tableView reloadData];
	NSUInteger indexes[2];
	indexes[0] = 0;
	indexes[1] = [paperNames indexOfObject:[TermPaperModel activeTermPaper].name];
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
	[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
#endif
	self.contentSizeForViewInPopover = CGSizeMake(300, 342);		// TODO: get the appropriate size
//	[self setDeleteButtonEnabled];
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
	[self setToolbar:nil];
	[super viewDidUnload];
}

- (IBAction)handleExportPDFButton:(id)sender
{
	[self.delegate handleExportPDFButton:self];
}

//	UIActionSheetDelegate method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
//	exportPaperActionSheetVisible = NO;
	if (buttonIndex == actionSheet.cancelButtonIndex) return;									// user canceled
	if (actionSheet == deletePaperActionSheet) {
#if 0
		int previousSelectionIndex = [paperNames indexOfObject:[TermPaperModel activeTermPaper].name];
		[[TermPaperModel activeTermPaper] remove];
		if (previousSelectionIndex >= paperNames.count) --previousSelectionIndex;					// in case user has deleted the last paper in the list
		NSUInteger indexes[2];
		indexes[0] = 0;
		indexes[1] = previousSelectionIndex;
		NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
		[self.tableView reloadData];
		if (self.paperNames.count > 0) {
			[self handlePaperPick:[paperNames objectAtIndex:previousSelectionIndex]];
			[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
		}
		[self setDeleteButtonEnabled];
#endif
	} else if (actionSheet == exportPaperActionSheet) {
		switch (buttonIndex) {
			case 0:
//				[self handleEmailFeedbackButton:self];
				break;
			case 1:
//				[self handleEmailDOCXButton:self];
				break;
			case 2:
//				[self handleExportDOCXButton:self];
				break;
			case 3:
//				[self handleEmailPDFButton:self];
				break;
			case 4:
				[self handleExportPDFButton:self];
				break;
#if CONSOLE
			case 5:
				NSLog(@"console output");
				[self handleEmailConsoleButton:self];
				break;
#endif
		}
	} else
		NSAssert(NO, @"Illegal value for actionSheet.");
}

@end
