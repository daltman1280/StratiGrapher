//
//  DocumentListTableViewController.m
//  Strata Recorder
//
//  Created by daltman on 11/18/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import "StrataModel.h"
#import "RenameViewController.h"
#import "DocumentListTableViewController.h"
#import "StrataNotifications.h"

@interface DocumentListTableViewController ()

@property (strong, nonatomic) IBOutlet UIToolbar*	toolbar;
@property (strong, nonatomic) NSMutableArray*		strataFiles;

@end

@implementation DocumentListTableViewController

- (IBAction)handleAddDocument:(id)sender {
	StrataDocument *document = [[StrataDocument alloc] init];
	[document save];
	[self populateDocumentsList];
	[self.tableView reloadData];
	int index = [self.strataFiles indexOfObject:document.name];
	[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
	[self.delegate setActiveStrataDocument:self.strataFiles[index]];
}

- (IBAction)handleDeleteDocument:(id)sender {
	deleteDocumentActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Document" otherButtonTitles:nil];
	[deleteDocumentActionSheet showFromBarButtonItem:self.actionDocument animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	RenameViewController *controller = (RenameViewController *)(segue.destinationViewController);
	controller.currentName = self.activeDocument.name;
	controller.strataFiles = self.strataFiles;
	controller.delegate = self;
}

- (IBAction)handleRenameDocument:(id)sender
{
	NSString *newName = ((RenameViewController *)sender).currentName;
	[self.activeDocument rename:newName];
	[self populateDocumentsList];
	[self.tableView reloadData];
	int index = [self.strataFiles indexOfObject:self.activeDocument.name];
	[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
	[self.delegate setActiveStrataDocument:self.strataFiles[index]];
}

- (IBAction)handleDuplicateDocument:(id)sender
{
	StrataDocument *document = [self.activeDocument duplicate];
	[self populateDocumentsList];
	[self.tableView reloadData];
	int index = [self.strataFiles indexOfObject:document.name];
	[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
	[self.delegate setActiveStrataDocument:self.strataFiles[index]];
}

- (IBAction)handleActionDocument:(id)sender {
	exportDocumentActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Feedback…", @"Email .docx", @"Export .docx", @"Email PDF", @"Export PDF",nil];
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
    self.clearsSelectionOnViewWillAppear = YES;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleActiveDocumentSelectionChanged:) name:SRActiveDocumentSelectionChanged object:nil];
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self.tableView reloadData];
	NSUInteger indexes[2];
	indexes[0] = 0;
	indexes[1] = [self.strataFiles indexOfObject:self.activeDocument.name];
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
	[self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
	self.contentSizeForViewInPopover = CGSizeMake(300, 342);		// TODO: get the appropriate size
	[self setDeleteButtonEnabled];
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
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		int i = [indexPath indexAtPosition:1];
		NSString *filename = [[[StrataDocument documentsFolderPath] stringByAppendingPathComponent:self.strataFiles[i]] stringByAppendingPathExtension:@"strata"];
		[[NSFileManager defaultManager] removeItemAtPath:filename error:nil];
		[self.strataFiles removeObjectAtIndex:i];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
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
	int index = [indexPath indexAtPosition:1];
	if ([(NSString *)(self.strataFiles[index]) isEqualToString:self.activeDocument.name]) return;			// user picked current document
	[self.delegate setActiveStrataDocument:self.strataFiles[index]];
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
	dispatch_queue_t exportQueue = dispatch_queue_create("export queue", NULL);
	dispatch_async(exportQueue, ^{
		[self.delegate handleExportPDFButton:self];
	});
}

//	UIActionSheetDelegate method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
//	exportPaperActionSheetVisible = NO;
	if (buttonIndex == actionSheet.cancelButtonIndex) return;									// user canceled
	if (actionSheet == deleteDocumentActionSheet) {
		int previousSelectionIndex = [self.strataFiles indexOfObject:self.activeDocument.name];
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

