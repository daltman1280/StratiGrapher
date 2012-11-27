//
//  SettingsTableController.m
//  Strata Recorder
//
//  Created by daltman on 11/25/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import "SettingsTableController.h"

@interface SettingsTableController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveItem;
@property (weak, nonatomic) IBOutlet UISlider *pageScaleSlider;
@property (weak, nonatomic) IBOutlet UITextField *strataHeightText;
@property (weak, nonatomic) IBOutlet UIStepper *strataHeightStepper;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitsSelector;
@property (weak, nonatomic) IBOutlet UITextField *paperWidthText;
@property (weak, nonatomic) IBOutlet UITextField *paperHeightText;
@property (weak, nonatomic) IBOutlet UITextField *pageScaleText;
@property (weak, nonatomic) IBOutlet UITextField *lineThicknessText;
@property (weak, nonatomic) IBOutlet UITextField *patternPitchText;

@end

@implementation SettingsTableController

- (IBAction)handleStrataHeightStepper:(id)sender {
	self.strataHeightText.text = [NSString stringWithFormat:@"%d", (int) self.strataHeightStepper.value];
}
- (IBAction)handleStrataHeightText:(id)sender {
	self.strataHeightText.text = [NSString stringWithFormat:@"%d", (int) self.strataHeightText.text.floatValue];
	self.strataHeightStepper.value = (int) self.strataHeightText.text.floatValue;
}

- (IBAction)handlePageScaleText:(id)sender {
	self.pageScaleSlider.value = self.pageScaleText.text.floatValue;
}

- (IBAction)handleSave:(id)sender {
	// initialize our properties from our current control settings, so our SettingsControllerDelegate can use them to propagate changes made
	if (self.strataHeightText.text.floatValue)
		self.strataHeight = self.strataHeightText.text.intValue;
	self.units = (self.unitsSelector.selectedSegmentIndex) ? @"English" : @"Metric";
	if (self.paperWidthText.text.floatValue)
		self.paperWidth = self.paperWidthText.text.floatValue;
	if (self.paperHeightText.text.floatValue)
		self.paperHeight = self.paperHeightText.text.floatValue;
	if (self.pageScaleText.text.floatValue)
		self.pageScale = self.pageScaleText.text.floatValue;
	if (self.lineThicknessText.text.intValue)
		self.lineThickness = self.lineThicknessText.text.intValue;
	// now, update user preferences from current property values
	[[NSUserDefaults standardUserDefaults] setFloat:self.strataHeight forKey:@"strataHeight"];
	[[NSUserDefaults standardUserDefaults] setFloat:self.paperWidth forKey:@"paperWidth"];
	[[NSUserDefaults standardUserDefaults] setFloat:self.paperHeight forKey:@"paperHeight"];
	[[NSUserDefaults standardUserDefaults] setFloat:self.pageScale forKey:@"pageScale"];
	[[NSUserDefaults standardUserDefaults] setInteger:self.lineThickness forKey:@"lineThickness"];
	
	[self.delegate performSelector:@selector(dismissSettingsPopoverContainer:) withObject:self];
}

- (IBAction)handlePageScaleSlider:(id)sender {
	self.pageScaleText.text = [NSString stringWithFormat:@"%.1f", self.pageScaleSlider.value];
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

	self.toolbarItems = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
						 self.saveItem, nil];
	// populate the properties from user preferences
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"strataHeight"])
		self.strataHeight = [[[NSUserDefaults standardUserDefaults] objectForKey:@"strataHeight"] intValue];
	else
		self.strataHeight = 10;
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"units"])
		self.units = [[NSUserDefaults standardUserDefaults] objectForKey:@"units"];
	else
		self.units = @"Metric";
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"paperWidth"])
		self.paperWidth = [[[NSUserDefaults standardUserDefaults] objectForKey:@"paperWidth"] floatValue];
	else
		self.paperWidth = 8.5;
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"paperHeight"])
		self.paperHeight = [[[NSUserDefaults standardUserDefaults] objectForKey:@"paperHeight"] floatValue];
	else
		self.paperHeight = 11;
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"pageScale"])
		self.pageScale = [[[NSUserDefaults standardUserDefaults] objectForKey:@"pageScale"] floatValue];
	else
		self.pageScale = 1;
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"lineThickness"])
		self.lineThickness = [[[NSUserDefaults standardUserDefaults] objectForKey:@"lineThickness"] intValue];
	else
		self.lineThickness = 3;
	// populate the table's controls from property values
	self.strataHeightText.text = [NSString stringWithFormat:@"%d", self.strataHeight];
	self.strataHeightStepper.value = self.strataHeight;
	self.unitsSelector.selectedSegmentIndex = [self.units isEqualToString:@"Metric"] ? 0 : 1;
	self.paperWidthText.text = [NSString stringWithFormat:@"%.1f", self.paperWidth];
	self.paperHeightText.text = [NSString stringWithFormat:@"%.1f", self.paperHeight];
	self.pageScaleText.text = [NSString stringWithFormat:@"%.1f", self.pageScale];
	self.pageScaleSlider.value = self.pageScale;
	self.lineThicknessText.text = [NSString stringWithFormat:@"%d", self.lineThickness];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	self.contentSizeForViewInPopover = CGSizeMake(460, 410);		// TODO: get the appropriate size
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
#if 0
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 3;
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
	[self setStrataHeightText:nil];
	[self setUnitsSelector:nil];
	[self setPaperWidthText:nil];
	[self setPaperHeightText:nil];
	[self setPageScaleText:nil];
	[self setSaveItem:nil];
	[self setPageScaleSlider:nil];
	[self setLineThicknessText:nil];
	[self setPatternPitchText:nil];
	[self setStrataHeightStepper:nil];
	[super viewDidUnload];
}
@end
