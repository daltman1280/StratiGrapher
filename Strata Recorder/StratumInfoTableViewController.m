//
//  StratumInfoTableViewController.m
//  Strata Recorder
//
//  Created by daltman on 5/23/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import "StrataModel.h"
#import "StratumInfoTableViewController.h"
#import "StratumMaterialsPaletteTableViewController.h"

@interface StratumInfoTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *materialTitleText;
@property (strong, nonatomic) IBOutlet MaterialPatternView *pattern;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;
@property (weak, nonatomic) IBOutlet UITextField *stratumWidthText;
@property (weak, nonatomic) IBOutlet UITextField *stratumHeightText;

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
	if (self.stratumHeightText.text.floatValue != self.stratum.frame.size.height || self.stratumWidthText.text.floatValue != self.stratum.frame.size.width)
		[self.activeDocument adjustStratumSize:CGSizeMake(self.stratumWidthText.text.floatValue, self.stratumHeightText.text.floatValue) atIndex:[self.activeDocument.strata indexOfObject:self.stratum]];
	[self.delegate performSelector:@selector(handleStratumInfoComplete:) withObject:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	StratumMaterialsPaletteTableViewController *controller = (StratumMaterialsPaletteTableViewController *) segue.destinationViewController;
	controller.materialNumber = self.materialNumber;
	controller.activeDocument = self.activeDocument;
	controller.stratumInfoTableViewController = self;
	self.stratumInfoNavigationController.delegate = self.stratumInfoNavigationController;				// this is where we setup the UINavigationControllerDelegate (can't do this from IB)
}

- (IBAction)handleEraseOutline:(id)sender {
	[self.stratum initializeOutline];
}

- (void)handleMaterialSelectionChanged:(int)materialNumber
{
	self.materialNumber = materialNumber;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (self.materialNumber == 0) {
		self.materialTitleText.text = @"";
		self.subtitle.text = @"Unassigned";
		self.pattern.patternNumber = 0;
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
	self.stratumWidthText.text = [NSString stringWithFormat:@"%.2f", self.stratum.frame.size.width];
	self.stratumHeightText.text = [NSString stringWithFormat:@"%.2f", self.stratum.frame.size.height];
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
	[self setTitle:nil];
	[self setPattern:nil];
	[self setSubtitle:nil];
	[self setStratumWidthText:nil];
	[self setStratumHeightText:nil];
	[super viewDidUnload];
}
@end
