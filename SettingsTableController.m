//
//  SettingsTableController.m
//  Strata Recorder
//
//  Created by daltman on 11/25/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import "SettingsTableController.h"
#import "StrataNotifications.h"

@interface SettingsTableController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelItem;
@property (weak, nonatomic) IBOutlet UISlider *pageScaleSlider;
@property (weak, nonatomic) IBOutlet UITextField *strataHeightText;
@property (weak, nonatomic) IBOutlet UIStepper *strataHeightStepper;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitsSelector;
@property (weak, nonatomic) IBOutlet UITextField *paperWidthText;
@property (weak, nonatomic) IBOutlet UITextField *paperHeightText;
@property (weak, nonatomic) IBOutlet UITextField *marginWidthText;
@property (weak, nonatomic) IBOutlet UITextField *marginHeightText;
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
	// only post notifications for properties that have changed
	if (self.strataHeightText.text.floatValue) {
		if (self.strataHeightText.text.intValue != self.strataHeight) {
			self.strataHeight = self.strataHeightText.text.intValue;
			[[NSNotificationCenter defaultCenter] postNotificationName:SRStrataHeightChangedNotification object:self];
		}
	}
	if (![self.units isEqualToString:(self.unitsSelector.selectedSegmentIndex) ? @"English" : @"Metric"]) {
		self.units = (self.unitsSelector.selectedSegmentIndex) ? @"English" : @"Metric";
		[[NSNotificationCenter defaultCenter] postNotificationName:SRUnitsChangedNotification object:self];
	}
	if (self.paperWidthText.text.floatValue) {
		if (self.paperWidthText.text.floatValue != self.paperWidth) {
			self.paperWidth = self.paperWidthText.text.floatValue;
			[[NSNotificationCenter defaultCenter] postNotificationName:SRPaperWidthChangedNotification object:self];
		}
	}
	if (self.paperHeightText.text.floatValue) {
		if (self.paperHeightText.text.floatValue != self.paperHeight) {
			self.paperHeight = self.paperHeightText.text.floatValue;
			[[NSNotificationCenter defaultCenter] postNotificationName:SRPaperHeightChangedNotification object:self];
		}
	}
	if (self.marginWidthText.text.floatValue) {
		if (self.marginWidthText.text.floatValue != self.marginWidth) {
			self.marginWidth = self.marginWidthText.text.floatValue;
			[[NSNotificationCenter defaultCenter] postNotificationName:SRMarginWidthChangedNotification object:self];
		}
	}
	if (self.marginHeightText.text.floatValue) {
		if (self.marginHeightText.text.floatValue != self.marginHeight) {
			self.marginHeight = self.marginHeightText.text.floatValue;
			[[NSNotificationCenter defaultCenter] postNotificationName:SRMarginHeightChangedNotification object:self];
		}
	}
	if (self.pageScaleText.text.floatValue) {
		if (self.pageScaleText.text.floatValue != self.pageScale) {
			self.pageScale = self.pageScaleText.text.floatValue;
			[[NSNotificationCenter defaultCenter] postNotificationName:SRPageScaleChangedNotification object:self];
		}
	}
	if (self.lineThicknessText.text.intValue) {
		if (self.lineThicknessText.text.floatValue != self.lineThickness) {
			self.lineThickness = self.lineThicknessText.text.intValue;
			[[NSNotificationCenter defaultCenter] postNotificationName:SRLineThicknessChangedNotification object:self];
		}
	}
	[self.delegate performSelector:@selector(handleSettingsTableComplete:) withObject:sender];					// let the delegate deal with the changed properties
}

- (IBAction)handleCancel:(id)sender {
	[self.delegate performSelector:@selector(handleSettingsTableComplete:) withObject:sender];
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
	self.toolbarItems = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], self.cancelItem, self.saveItem, nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	// populate the properties from active document
	self.strataHeight = self.activeDocument.strataHeight;
	self.units = self.activeDocument.units;
	self.paperWidth = self.activeDocument.pageDimension.width;
	self.paperHeight = self.activeDocument.pageDimension.height;
	self.marginWidth = self.activeDocument.pageMargins.width;
	self.marginHeight = self.activeDocument.pageMargins.height;
	self.pageScale = self.activeDocument.scale;
	self.lineThickness = self.activeDocument.lineThickness;
	// populate the table's controls from property values
	self.strataHeightText.text = [NSString stringWithFormat:@"%d", self.strataHeight];
	self.strataHeightStepper.value = self.strataHeight;
	self.unitsSelector.selectedSegmentIndex = [self.units isEqualToString:@"Metric"] ? 0 : 1;
	self.paperWidthText.text = [NSString stringWithFormat:@"%.1f", self.paperWidth];
	self.paperHeightText.text = [NSString stringWithFormat:@"%.1f", self.paperHeight];
	self.marginWidthText.text = [NSString stringWithFormat:@"%.1f", self.marginWidth];
	self.marginHeightText.text = [NSString stringWithFormat:@"%.1f", self.marginHeight];
	self.pageScaleText.text = [NSString stringWithFormat:@"%.1f", self.pageScale];
	self.pageScaleSlider.value = self.pageScale;
	self.lineThicknessText.text = [NSString stringWithFormat:@"%d", self.lineThickness];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.modalInPopover = YES;									// make this view modal (if it's in a popover, ignore outside clicks)
	self.contentSizeForViewInPopover = CGSizeMake(460, 454);		// TODO: get the appropriate size
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
	[self setCancelItem:nil];
	[self setMarginWidthText:nil];
	[self setMarginHeightText:nil];
	[super viewDidUnload];
}
@end
