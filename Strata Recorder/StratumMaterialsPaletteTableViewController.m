//
//  StratumMaterialsPaletteTableViewController.m
//  Strata Recorder
//
//  Created by daltman on 5/9/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import "StratumMaterialsPaletteTableViewController.h"
#import "StratumMaterialsTableController.h"
#import "MaterialTableViewCell.h"

@interface StratumMaterialsPaletteTableViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *removeButton;

@property NSMutableArray* materialIndexes;										// cached, sorted, material numbers from StrataDocument materialNumbersPalette
@end

@implementation StratumMaterialsPaletteTableViewController

/*
 UINavigationControllerDelegate function
 
 After we pop back from the Materials list, we need to rebuild the Materials Palette, in
 case we've added materials to the palette.
 */

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if (viewController == self) {
		self.materialIndexes = [NSMutableArray arrayWithArray:[self.activeDocument.materialNumbersPalette sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"intValue" ascending:YES]]]];
		[self.tableView reloadData];
		int i = (self.materialNumber) ? [self.materialIndexes indexOfObject:[NSNumber numberWithInt:self.materialNumber]]+1 : 0;
		[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
	}
}

- (IBAction)handleRemoveMaterial:(id)sender {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	StratumMaterialsTableController *controller = (StratumMaterialsTableController *) segue.destinationViewController;
	controller.activeDocument = self.activeDocument;					// so it can manage materials palette
	controller.materialIndexes = self.materialIndexes;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.clearsSelectionOnViewWillAppear = NO;
}

- (void)didReceiveMemoryWarning
{
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
	return self.activeDocument.materialNumbersPalette.count+1;														// first row is for unassigned
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	MaterialTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"material"];
	if (indexPath.row == 0) {																						// first cell is unassigned
		[cell.title setText:@""];
		[cell.subtitle setText:@"Unassigned"];
		cell.pattern.patternNumber = 0;
		[cell.pattern setNeedsDisplay];
		return cell;
	}
    // Configure the cell...
	NSString *descriptions = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"patterns descriptive text" ofType:@"txt"] encoding:NSASCIIStringEncoding error:nil];
	int materialNumber = [self.materialIndexes[indexPath.row-1] intValue];											// convert NSSet to an array, and access indexed value
	for (NSString *line in [descriptions componentsSeparatedByString:@"\n"]) {										// look for a material whose number matches materialNumber
		if ([[line substringToIndex:3] intValue] == materialNumber) {
			[cell.title setText:[line substringToIndex:3]];
			[cell.subtitle setText:[line substringFromIndex:4]];
			cell.pattern.patternNumber = [[line substringToIndex:3] intValue];
			[cell.pattern setNeedsDisplay];
			return cell;
		}
	}
	return nil;
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
	int lineNumber = [self.tableView indexPathForSelectedRow].row;
	int materialNumber;
	if (lineNumber)														// first line is for unassigned materials
		materialNumber = [self.materialIndexes[lineNumber-1] intValue];
	else
		materialNumber = 0;
	[self.stratumInfoTableViewController handleMaterialSelectionChanged:materialNumber];
}

- (void)viewDidUnload {
	[self setAddButton:nil];
	[self setRemoveButton:nil];
	[super viewDidUnload];
}
@end
