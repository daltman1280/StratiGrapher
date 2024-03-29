//
//  DocumentListTableViewController.m
//  Strata Recorder
//
//  Created by daltman on 11/18/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import "StrataModel.h"
#import "StrataModelState.h"
#import "DocumentListTableViewController.h"
#import "StrataNotifications.h"

const static int kSGTextFieldTagNumber = 99;

@interface DocumentListTableViewController ()

@property (strong, nonatomic) IBOutlet UIToolbar*	toolbar;
@property (strong, nonatomic) NSMutableArray*		strataFiles;
@property (assign) NSInteger						activeEditingSessionIndex;				// in case user taps another row during an active editing session (rename drawing). -1: no active session

@end

@implementation DocumentListTableViewController

- (IBAction)handleAddDocument:(id)sender {
	if (self.activeEditingSessionIndex >= 0)
		[self deselectedActiveEditingSession];																// need to handle deselected row BEFORE calling active document setter!
	StrataDocument *document = [[StrataDocument alloc] init];
	[document save];
	[self populateDocumentsList];
	[self.tableView reloadData];
	NSInteger index = [self.strataFiles indexOfObject:document.name];
	[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
	[self.delegate setActiveStrataDocument:self.strataFiles[index]];
	[self setDeleteButtonEnabled];
}

- (IBAction)handleDeleteDocument:(id)sender {
	if (self.activeEditingSessionIndex >= 0)
		[self deselectedActiveEditingSession];																// need to handle deselected row BEFORE calling active document setter!
	deleteDocumentActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Drawing" otherButtonTitles:nil];
	[deleteDocumentActionSheet showFromBarButtonItem:self.actionDocument animated:YES];
}

//	make the cell's label invisible and activate the text field

- (IBAction)handleRenameStart:(id)sender {
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
	cell.textLabel.hidden = YES;
	UITextField *textField = (UITextField *)[cell.contentView viewWithTag:kSGTextFieldTagNumber];
	textField.hidden = NO;
	textField.text = cell.textLabel.text;
	textField.delegate = self;
	[textField becomeFirstResponder];
	self.activeEditingSessionIndex = [[self.tableView indexPathForSelectedRow] indexAtPosition:1];					// active editing session here!
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]];
	[self closeEditingSessionOfCell:cell textField:textField];
	return YES;																										// always allow the session to end
}

//	User has tapped a different row from the active editing session, we need to end it (and possibly rename its drawing)

- (void)deselectedActiveEditingSession
{
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:self.activeEditingSessionIndex inSection:0]];		// row that contained active editing session
	UITextField *textField = (UITextField *) [cell.contentView viewWithTag:kSGTextFieldTagNumber];
	[self closeEditingSessionOfCell:cell textField:textField];														// close the editing session
	self.activeEditingSessionIndex = -1;																			// no active editing session
}

/*
 Active editing session terminated, either because user dismissed keyboard, dismissed popover, or tapped a different drawing
 row in the popover.
 */

- (void)closeEditingSessionOfCell:(UITableViewCell *)cell textField:(UITextField *)textField
{
	if (textField.text.length > 0 && ![self.strataFiles containsObject:textField.text]) {							// rename the drawing if it's legal
		BOOL success = [self.activeDocument rename:textField.text];
		if (success) {																								// test return code from rename operation
			[self populateDocumentsList];
			NSInteger index = [self.strataFiles indexOfObject:self.activeDocument.name];
			[self.delegate setActiveStrataDocument:self.strataFiles[index]];
		}
	}
	// deactivate editing control and activate original cell label
	textField.hidden = YES;
	textField.delegate = nil;
	[textField resignFirstResponder];
	cell.textLabel.hidden = NO;
	cell.textLabel.text = self.activeDocument.name;
}

- (IBAction)handleDuplicateDocument:(id)sender
{
	if (self.activeEditingSessionIndex >= 0)
		[self deselectedActiveEditingSession];																// need to handle deselected row BEFORE calling active document setter!
	StrataDocument *document = [self.activeDocument duplicate];
	[self populateDocumentsList];
	[self.tableView reloadData];
	NSInteger index = [self.strataFiles indexOfObject:document.name];
	[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
	[self.delegate setActiveStrataDocument:self.strataFiles[index]];
	[self setDeleteButtonEnabled];
}

- (IBAction)handleActionDocument:(id)sender {
	exportDocumentActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Feedback…", @"Dropbox PDF", @"Email PDF", @"Export PDF",nil];
	[exportDocumentActionSheet showFromBarButtonItem:self.actionDocument animated:YES];
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
	[self populateDocumentsList];
    self.clearsSelectionOnViewWillAppear = NO;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleActiveDocumentSelectionChanged:) name:SRActiveDocumentSelectionChangedNotification object:nil];
	[self.tableView reloadData];
	NSUInteger indexes[2];
	indexes[0] = 0;
	indexes[1] = [self.strataFiles indexOfObject:self.activeDocument.name];
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
	[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
	[self setDeleteButtonEnabled];
	[[NSNotificationCenter defaultCenter] postNotificationName:SRPopupVisibleNotification object:self];
	self.activeEditingSessionIndex = -1;																		// initially, no active editing session. Will have row index whenever a session begins
}

- (void)populateDocumentsList
{
	NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[StrataDocument documentsFolderPath] error:nil];
	self.strataFiles = [[NSMutableArray alloc] init];
	for (NSString *filename in files) {
		if ([filename hasSuffix:@".strata"])
			[self.strataFiles addObject:[filename stringByDeletingPathExtension]];
	}
}

- (void)handleActiveDocumentSelectionChanged:(NSNotification *)notification
{
	self.activeDocument = [notification.userInfo objectForKey:@"activeDocument"];
}

- (void)setDeleteButtonEnabled
{
	self.deleteDocument.enabled = self.strataFiles.count > 1;
}

- (void)didReceiveMemoryWarning
{
	NSLog(@"DocumentListTableViewController didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.strataFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Strata Document Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
	int strataFileIndex = 0;
	for (NSString *filename in self.strataFiles) {
		if (strataFileIndex == [indexPath indexAtPosition:1]) {
			cell.textLabel.text = [filename stringByDeletingPathExtension];
			// create the editing text field
			UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 200, 30)];
			textField.tag = kSGTextFieldTagNumber;
			[cell.contentView insertSubview:textField belowSubview:cell.textLabel];
			textField.borderStyle = UITextBorderStyleRoundedRect;
			textField.clearButtonMode = UITextFieldViewModeAlways;
			textField.hidden = YES;
			return cell;
		}
		++strataFileIndex;
	}
	return nil;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

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
	NSInteger index = [indexPath indexAtPosition:1];
	if (self.activeEditingSessionIndex >= 0)
		[self deselectedActiveEditingSession];																// need to handle deselected row BEFORE calling active document setter!
	if ([(NSString *)(self.strataFiles[index]) isEqualToString:self.activeDocument.name]) return;			// user picked current document
	[self.delegate setActiveStrataDocument:self.strataFiles[index]];
	[StrataModelState currentState].dirty = YES;
}

#pragma mark -

- (void)viewDidUnload {
	[self setAddDocument:nil];
	[self setDeleteDocument:nil];
	[self setRenameDocument:nil];
	[self setDuplicateDocument:nil];
	[self setActionDocument:nil];
	[self setToolbar:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super viewDidUnload];
}

- (IBAction)handleDropboxPDFButton:(id)sender
{
	dispatch_queue_t exportQueue = dispatch_queue_create("dropbox queue", NULL);
	dispatch_async(exportQueue, ^{
		[self.delegate handleExportPDFButton:self];
		NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString *pdfFile = [NSString stringWithFormat:@"%@.pdf", _activeDocument.name];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.restClient uploadFile:pdfFile toPath:@"/" withParentRev:nil fromPath:[documentsFolder stringByAppendingPathComponent:pdfFile]];
		});
	});
}

- (DBRestClient *)restClient {
	if (!_restClient) {
		_restClient =
		[[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		_restClient.delegate = self;
	}
	return _restClient;
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
			  from:(NSString*)srcPath metadata:(DBMetadata*)metadata
{
	
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Can\'t access Dropbox." delegate:nil cancelButtonTitle:@"" destructiveButtonTitle:@"OK" otherButtonTitles:@"", nil];
	sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[sheet showInView:[[[UIApplication sharedApplication] keyWindow] rootViewController].view];
}

- (IBAction)handleExportPDFButton:(id)sender
{
	dispatch_queue_t exportQueue = dispatch_queue_create("export queue", NULL);
	dispatch_async(exportQueue, ^{
		[self.delegate handleExportPDFButton:self];
	});
}

- (IBAction)handleEmailPDFButton:(id)sender
{
	dispatch_queue_t exportQueue = dispatch_queue_create("export queue", NULL);
	dispatch_async(exportQueue, ^{
		[self.delegate handleExportPDFButton:self];
		dispatch_async(dispatch_get_main_queue(), ^{[self createEmailWithPDF:self];});
	});
}

- (IBAction)handleEmailFeedbackButton:(id)sender
{
	if (![MFMailComposeViewController canSendMail]) {
		NSLog(@"Can\'t access mail.");
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Can\'t access Mail." delegate:nil cancelButtonTitle:@"" destructiveButtonTitle:@"OK" otherButtonTitles:@"", nil];
		sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		[sheet showInView:[[[UIApplication sharedApplication] keyWindow] rootViewController].view];
	}
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	[picker setSubject:[NSString stringWithFormat:@"Question/request/feedback for Stratigrapher"]];
	[picker setToRecipients:@[@"support@homebodyapps.com"]];
	[self presentViewController:picker animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createEmailWithPDF:(id)sender
{
	if (![MFMailComposeViewController canSendMail]) {
		NSLog(@"Can\'t access mail.");
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Can\'t access Mail." delegate:nil cancelButtonTitle:@"" destructiveButtonTitle:@"OK" otherButtonTitles:@"", nil];
		sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		[sheet showInView:[[[UIApplication sharedApplication] keyWindow] rootViewController].view];
	}
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	[picker setSubject:[NSString stringWithFormat:@"Printable PDF for %@", self.activeDocument.name]];
	NSString *emailBody = @"Please print the attached PDF document.";
	[picker setMessageBody:emailBody isHTML:NO];
	NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *pdfFile = [documentsFolder stringByAppendingFormat:@"/%@.pdf ", self.activeDocument.name];
	if (![[NSFileManager defaultManager] fileExistsAtPath:pdfFile] || ![[NSFileManager defaultManager] contentsAtPath:pdfFile]) {
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Can\'t access PDF \"%@\" for Mail.", pdfFile.lastPathComponent] delegate:nil cancelButtonTitle:@"" destructiveButtonTitle:@"OK" otherButtonTitles:@"", nil];
		sheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		[sheet showInView:[[[UIApplication sharedApplication] keyWindow] rootViewController].view];
		return;
	}
    NSData *myData = [NSData dataWithContentsOfFile:pdfFile];
	[picker addAttachmentData:myData mimeType:@"application/pdf" fileName:[self.activeDocument.name stringByAppendingString:@".pdf"]];
	[self presentViewController:picker animated:YES completion:nil];
}

//	UIActionSheetDelegate method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == actionSheet.cancelButtonIndex) return;									// user canceled
	if (actionSheet == deleteDocumentActionSheet) {
		NSInteger previousSelectionIndex = [self.strataFiles indexOfObject:self.activeDocument.name];
		[self.activeDocument remove];
		[self populateDocumentsList];
		if (previousSelectionIndex >= self.strataFiles.count) --previousSelectionIndex;			// in case user has deleted the last paper in the list
		[self.tableView reloadData];
		if (self.strataFiles.count > 0) {
			[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:previousSelectionIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
			[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:previousSelectionIndex inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
			[self.delegate setActiveStrataDocument:self.strataFiles[previousSelectionIndex]];
		}
		[self setDeleteButtonEnabled];
	} else if (actionSheet == exportDocumentActionSheet) {
		switch (buttonIndex) {
			case 0:
				[self handleEmailFeedbackButton:self];
				break;
			case 1:
				[self handleDropboxPDFButton:self];
				break;
			case 2:
				[self handleEmailPDFButton:self];
				break;
			case 3:
				[self handleExportPDFButton:self];
				break;
		}
	} else
		NSAssert(NO, @"Illegal value for actionSheet.");
}

@end

