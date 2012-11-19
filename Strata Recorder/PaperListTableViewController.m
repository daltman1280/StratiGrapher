//
//  PaperListTableViewController.m
//  TermPaper
//
//  Created by daltman on 6/23/10.
//  Copyright 2010 DonnieWare. All rights reserved.
//

#import "PaperListTableViewController.h"

@implementation ModelListTableViewController

@synthesize paperNames, popoverViewController, exportPaperActionSheetVisible;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	// setup toolbar
	self.toolbarItems = [NSArray arrayWithObjects:addPaper, 
						 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], 
						 deletePaper, 
						 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], 
						 renamePaper, 
						 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], 
						 duplicatePaper, 
						 [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], 
						 actionPaper, 
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
	
	[renameOKButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
	[renameOKButton setBackgroundImage:stretchableButtonImagePressed forState:UIControlStateHighlighted];
	[renameCancelButton setBackgroundImage:stretchableButtonImageCancelNormal forState:UIControlStateNormal];
	[renameCancelButton setBackgroundImage:stretchableButtonImageCancelPressed forState:UIControlStateHighlighted];
    self.clearsSelectionOnViewWillAppear = YES;
	exportPaperActionSheetVisible = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self.tableView reloadData];
	NSUInteger indexes[2];
	indexes[0] = 0;
//	indexes[1] = [paperNames indexOfObject:[TermPaperModel activeTermPaper].name];
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
	[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
	self.contentSizeForViewInPopover = CGSizeMake(300, 342);		// TODO: get the appropriate size
	[self setDeleteButtonEnabled];
}

- (void)setDeleteButtonEnabled
{
	deletePaper.enabled = self.paperNames.count > 1; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.paperNames.count;
}

// Customize the appearance of table view cells.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
	cell.textLabel.text = [self.paperNames objectAtIndex:[indexPath indexAtPosition:1]];
//	if ([[paperNames objectAtIndex:[indexPath indexAtPosition:1]] isEqualToString:[TermPaperModel activeTermPaper].name]) {
//		cell.accessoryType = UITableViewCellAccessoryCheckmark;
//	}
//	else
//		cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//	if ([[paperNames objectAtIndex:[indexPath indexAtPosition:1]] isEqualToString:[TermPaperModel activeTermPaper].name]) {	// it's already selected, just dismiss the popover
//		return;
//	}
	NSArray *visibleCells = [tableView visibleCells];
	for (UITableViewCell *visibleCell in visibleCells) {
		if (visibleCell != cell)
			visibleCell.accessoryType = UITableViewCellAccessoryNone;
	}
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	[self performSelector:@selector(handlePaperPick:) withObject:cell.textLabel.text];	// open the selected paper
}

#pragma mark -
#pragma mark Actions

- (IBAction)handleAddPaper:(id)sender
{
#if 0
	NSString *newPaperName = [TermPaperModel newPaper];
	if (newPaperName) {
		[self.tableView reloadData];															// display the new name
		NSUInteger indexes[2];
		indexes[0] = 0;
		indexes[1] = [paperNames indexOfObject:newPaperName];
		NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
		[self handlePaperPick:newPaperName];
		[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
	}
	[self setDeleteButtonEnabled];
#endif
}

//	UIActionSheetDelegate method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	exportPaperActionSheetVisible = NO;
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
		NSLog(@"buttonIndex = %d", buttonIndex);
		switch (buttonIndex) {
			case 0:
				[self handleEmailFeedbackButton:self];
				break;
			case 1:
				[self handleEmailDOCXButton:self];
				break;
			case 2:
				[self handleExportDOCXButton:self];
				break;
			case 3:
				[self handleEmailPDFButton:self];
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

- (IBAction)handleDeletePaper:(id)sender			// TODO: implement UIPopoverControllerDelegate
{
	deletePaperActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Document" otherButtonTitles:nil];
	[deletePaperActionSheet showFromToolbar:toolbar];
}

- (IBAction)handleRenameConfirm:(id)sender
{
	[renameDocumentViewController dismissModalViewControllerAnimated:YES];
//	[renameDocumentViewController release];
	if (sender != renameOKButton) return;
//	[[TermPaperModel activeTermPaper] rename:renameText.text];
	[self.tableView reloadData];
	[self handlePaperPick:renameText.text];
}

- (IBAction)renameTextDidChange:(id)sender
{
	if (renameText.text.length == 0)
		renameOKButton.enabled = NO;
	else if ([paperNames containsObject:renameText.text])
		renameOKButton.enabled = NO;
	else
		renameOKButton.enabled = YES;
}

- (IBAction)handleRenamePaper:(id)sender
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(renameTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
	renameDocumentViewController = [[RenameViewController alloc] init];
	renameDocumentViewController.view = renameDialog;
//	renameText.text = [TermPaperModel activeTermPaper].name;
	renameOKButton.enabled = NO;
	renameDocumentViewController.modalInPopover = YES;
	renameDocumentViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
	renameDocumentViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	renameDocumentViewController.hidesBottomBarWhenPushed = NO;
	[parentNavigationController presentModalViewController:renameDocumentViewController animated:YES];
}

- (IBAction)handleDuplicatePaper:(id)sender
{
#if 0
	NSString *newPaperName = [[TermPaperModel activeTermPaper] duplicate];
	if (newPaperName) {
		[self.tableView reloadData];															// display the new name
		NSUInteger indexes[2];
		indexes[0] = 0;
		indexes[1] = [paperNames indexOfObject:newPaperName];
		NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
		[self handlePaperPick:newPaperName];
		[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
	}
	[self setDeleteButtonEnabled];
#endif
}

- (IBAction)handleExportPDFButton:(id)sender
{
	[viewController handleExportPDFButton:self];
}

- (IBAction)handleExportDOCXButton:(id)sender
{
	[viewController saveActivePaper];
	[[TermPaperModel activeTermPaper] exportDocxFile];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)handleEmailCompletion:(NSNotificationCenter *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kDWPDFCompleteNotificationName object:nil];
	if (![MFMailComposeViewController canSendMail])
		;
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:[NSString stringWithFormat:@"Printable PDF for %@", [TermPaperModel activeTermPaper].name]];
	
	NSString *emailBody = @"Please print the attached PDF document.";
	[picker setMessageBody:emailBody isHTML:NO];
	
	NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *pdfFile = [documentsFolder stringByAppendingFormat:@"/%@.pdf", [TermPaperModel activeTermPaper].name];
	NSLog(@"pdffile = %@", pdfFile);
    NSData *myData = [NSData dataWithContentsOfFile:pdfFile];
	NSLog(@"myData.length = %d", myData.length);
	NSLog(@"name = %@", [[TermPaperModel activeTermPaper].name stringByAppendingString:@".pdf"]);
	[picker addAttachmentData:myData mimeType:@"application/pdf" fileName:[[TermPaperModel activeTermPaper].name stringByAppendingString:@".pdf"]];
	
	[self presentModalViewController:picker animated:YES];
    [picker release];
}

- (IBAction)handleEmailFeedbackButton:(id)sender
{
	if (![MFMailComposeViewController canSendMail])
		;
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setToRecipients:[NSArray arrayWithObject:@"support@homebodyapps.com"]];
	[picker setSubject:[NSString stringWithFormat:@"TermPaper Question/Bug/Suggestion/Feedback"]];
	
	NSString *emailBody = [NSString stringWithFormat:@"TermPaper 1.2 for iPad v%f\n\nDear HomebodyApps Support:\n", NSFoundationVersionNumber];
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];
    [picker release];
}

- (IBAction)handleEmailPDFButton:(id)sender
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEmailCompletion:) name:kDWPDFCompleteNotificationName object:nil];
	[viewController handleExportPDFButton:self];
}

- (IBAction)handleEmailDOCXButton:(id)sender
{
	[viewController saveActivePaper];
	[[TermPaperModel activeTermPaper] exportDocxFile];
	if (![MFMailComposeViewController canSendMail])
		;
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:[NSString stringWithFormat:@"Microsoft Word® for %@", [TermPaperModel activeTermPaper].name]];
	
	NSString *emailBody = @"Please print the attached Microsoft Word® document.";
	[picker setMessageBody:emailBody isHTML:NO];
	
	NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *wordFile = [documentsFolder stringByAppendingFormat:@"/%@.docx", [TermPaperModel activeTermPaper].name];
    NSData *myData = [NSData dataWithContentsOfFile:wordFile];
	[picker addAttachmentData:myData mimeType:@"application/doc" fileName:[[TermPaperModel activeTermPaper].name stringByAppendingString:@".docx"]];
	
	[self presentModalViewController:picker animated:YES];
    [picker release];
}

- (IBAction)handleActionPaper:(id)sender
{
#if !CONSOLE
	exportPaperActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Feedback…", @"Email .docx", @"Export .docx", @"Email PDF", @"Export PDF",nil];
#else
	exportPaperActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Feedback…", @"Email .docx", @"Export .docx", @"Email PDF", @"Export PDF",@"Email Console", nil];
#endif
	[exportPaperActionSheet showFromToolbar:toolbar];
	exportPaperActionSheetVisible = YES;
}

//	User has selected a paper from the list in the popover, save the current paper and open the selected paper

- (IBAction)handlePaperPick:(NSString *)selectedPaperName
{
	[viewController saveActivePaper];
	[[NSUserDefaults standardUserDefaults] setObject:selectedPaperName forKey:@"activePaper"];
	[TermPaperModel makeActive:selectedPaperName];
	[viewController openPaper];
	[paperDetailTableController.navigationController popToRootViewControllerAnimated:NO];					// force popover navigationcontrollers back to their root views
	[citationTableController.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	NSLog(@"PaperListTableViewController didReceiveMemoryWarning");
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[viewController release];
	[paperNames release];
	[paperDetailTableController release];
	[popoverViewController release];
	[addPaper release];
	[deletePaper release];
	[renamePaper release];
	[duplicatePaper release];
	[actionPaper release];
	[renameDialog release];
	[renameText release];
	[renameOKButton release];
    [super dealloc];
}

@end

@implementation RenameViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	self.contentSizeForViewInPopover = CGSizeMake(300, 342);		// TODO: get the appropriate size
}

@end

