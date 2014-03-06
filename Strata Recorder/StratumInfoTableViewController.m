//
//  StratumInfoTableViewController.m
//  Strata Recorder
//
//  Created by daltman on 5/23/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import "StrataModel.h"
#import "StrataModelState.h"
#import "StratumInfoTableViewController.h"
#import "StratumMaterialsPaletteTableViewController.h"
#import "StrataView.h"
#import "StratumInfoNotesViewController.h"
#import "StratumGranularityViewController.h"

@interface StratumInfoTableViewController ()
@property (strong, nonatomic) IBOutlet UILabel *materialTitleText;
@property (strong, nonatomic) IBOutlet MaterialPatternView *pattern;
@property (strong, nonatomic) IBOutlet UILabel *subtitle;
@property (strong, nonatomic) IBOutlet UITextField *stratumHeightText;
@property (strong, nonatomic) IBOutlet UILabel *grainSizeText;
@property (strong, nonatomic) IBOutlet UILabel *notesText;
@property (strong, nonatomic) IBOutlet UIButton *eraseButton;

@end

@implementation StratumInfoTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)handleSave:(id)sender {
	self.stratum.materialNumber = self.materialNumber;
	if (self.stratumHeightText.text.floatValue != self.stratum.frame.size.height && self.stratumHeightText.text.floatValue > 0)
		[self.activeDocument adjustStratumSize:CGSizeMake(self.stratum.frame.size.width, self.stratumHeightText.text.floatValue) atIndex:[self.activeDocument.strata indexOfObject:self.stratum]];
	if (self.grainSizeIndex != self.stratum.grainSizeIndex) {
		self.stratum.grainSizeIndex = self.grainSizeIndex;
		float width = [StrataDocument stratumWidthFromGrainSize:self.stratum.grainSizeIndex-1];
		[self.activeDocument adjustStratumSize:CGSizeMake(width, self.stratum.frame.size.height) atIndex:[self.activeDocument.strata indexOfObject:self.stratum]];
	}
	[StrataModelState currentState].dirty = YES;
	[self.delegate performSelector:@selector(handleStratumInfoComplete:) withObject:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	id destinationViewController = segue.destinationViewController;
	if ([destinationViewController isKindOfClass:[StratumMaterialsPaletteTableViewController class]]) {
		StratumMaterialsPaletteTableViewController *controller = (StratumMaterialsPaletteTableViewController *) destinationViewController;
		controller.materialNumber = self.materialNumber;
		controller.activeDocument = self.activeDocument;
		controller.stratumInfoTableViewController = self;
		self.stratumInfoNavigationController.delegate = self.stratumInfoNavigationController;				// this is where we setup the UINavigationControllerDelegate (can't do this from IB)
	} else if ([destinationViewController isKindOfClass:[StratumInfoNotesViewController class]]) {
		StratumInfoNotesViewController *controller = (StratumInfoNotesViewController *)destinationViewController;
		controller.stratum = self.stratum;
		controller.notesTextView.text = @"xxx";//self.stratum.notes;
		controller.notes = self.stratum.notes;
		controller.stratumInfoTableViewController = self;
	} else if ([destinationViewController isKindOfClass:[StratumGranularityViewController class]]) {
		StratumGranularityViewController *controller = (StratumGranularityViewController *)destinationViewController;
		controller.grainSizeIndex = self.stratum.grainSizeIndex;
		controller.parent = self;
	}
}

- (IBAction)handleEraseOutline:(id)sender {
	[self.stratum initializeOutline];
	self.eraseButton.enabled = NO;
}

/*
 Called from UITableView:didSelectRowAtIndexPath in response to selecting a material from the palette table.
 */

- (void)handleMaterialSelectionChanged:(int)materialNumber
{
	self.materialNumber = materialNumber;
	[self initializeTable];
}

- (void)handleGranularityChanged:(grainSizeEnum)grainSizeIndex
{
	self.grainSizeIndex = grainSizeIndex;
	[self initializeTable];
}

- (void)initializeTable
{
	if (self.materialNumber == 0) {
		self.materialTitleText.text = @"";
		self.subtitle.text = @"Unassigned";
		self.pattern.patternNumber = 0;
		self.notesText.text = @"";
		[self.pattern setNeedsDisplay];
	} else {
		NSString *descriptions = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"patterns descriptive text" ofType:@"txt"] encoding:NSASCIIStringEncoding error:nil];
		for (NSString *line in [descriptions componentsSeparatedByString:@"\n"]) {										// look for a material whose number matches materialNumber
			if ([[line substringToIndex:3] intValue] == self.materialNumber) {
				self.materialTitleText.text = [line substringToIndex:3];
				self.subtitle.text = [line substringFromIndex:4];
				self.pattern.patternNumber = [[line substringToIndex:3] intValue];
				[self.pattern setNeedsDisplay];
				break;
			}
		}
	}
	self.stratumHeightText.text = [NSString stringWithFormat:@"%.2f", self.stratum.frame.size.height];
	NSAssert1(self.stratum.grainSizeIndex >= 1 && (int) self.stratum.grainSizeIndex <= grainSizeBoulders+1, @"Illegal grain size index = %d", self.stratum.grainSizeIndex);
	self.grainSizeText.text = (NSString *)gGrainSizeNames[self.stratum.grainSizeIndex-1];
	self.notesText.text = self.stratum.notes;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	// following gives false positive if outline has been previously erased
	[self initializeTable];
	self.eraseButton.enabled = self.stratum.outline != nil && self.stratum.outline.count > 0;
}

- (void)didReceiveMemoryWarning
{
	NSLog(@"StratumInfoTableViewController didReceiveMemoryWarning");
	[super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

#if 0
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 2;
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

#endif
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
	[self setMaterialTitleText:nil];
	[self setNotesText:nil];
	[self setTitle:nil];
	[self setPattern:nil];
	[self setSubtitle:nil];
	[self setStratumHeightText:nil];
	[self setGrainSizeText:nil];
	[self setEraseButton:nil];
	[super viewDidUnload];
}
@end
