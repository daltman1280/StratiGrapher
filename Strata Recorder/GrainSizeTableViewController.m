//
//  GrainSizeTableViewController.m
//  Strata Recorder
//
//  Created by daltman on 10/7/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import "GrainSizeTableViewController.h"

@interface GrainSizeTableViewController ()

@end

@implementation GrainSizeTableViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	self.title = [NSString stringWithFormat:@"%@ Active Grain Sizes", self.activeDocument.name];
	int grainSizesMask = self.grainSizesMask;
	self.boulderSwitch.on = grainSizesMask & grainSizeBoulders;
	self.cobblesSwitch.on = grainSizesMask & grainSizeCobbles;
	self.coarseGravelSwitch.on = grainSizesMask & grainSizeCoarseGravel;
	self.fineGravelSwitch.on = grainSizesMask & grainSizeFineGravel;
	self.coarseSandSwitch.on = grainSizesMask & grainSizeCoarseSand;
	self.mediumSandSwitch.on = grainSizesMask & grainSizeMediumSand;
	self.fineSandSwitch.on = grainSizesMask & grainSizeFineSand;
	self.fineSiltAndClaySwitch.on = grainSizesMask & grainSizeFineSiltAndClay;
	self.modalInPopover = YES;									// make this view modal (if it's in a popover, ignore outside clicks)
	self.contentSizeForViewInPopover = CGSizeMake(460, 533);		// TODO: get the appropriate size
}

/*
 Called by our Navigation Bar Delegate, which is a subclass of our Navigation Controller (SettingsNavigationController), to notify we are going away, and to save our settings
 */

- (void)viewDidPop
{
	
}

- (IBAction)handleGrainSizeRadioButton:(id)sender {
	self.grainSizesMask =
		(self.boulderSwitch.on ? grainSizeBoulders : 0) |
		(self.cobblesSwitch.on ? grainSizeCobbles : 0) |
		(self.coarseGravelSwitch.on ? grainSizeCoarseGravel : 0) |
		(self.fineGravelSwitch.on ? grainSizeFineGravel : 0) |
		(self.coarseSandSwitch.on ? grainSizeCoarseSand : 0) |
		(self.mediumSandSwitch.on ? grainSizeMediumSand : 0) |
		(self.fineSandSwitch.on ? grainSizeFineSand : 0) |
		(self.fineSiltAndClaySwitch.on ? grainSizeFineSiltAndClay : 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

/*
 Missing, since this table has static content
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
	[self setBoulderSwitch:nil];
	[self setCobblesSwitch:nil];
	[self setCoarseGravelSwitch:nil];
	[self setFineGravelSwitch:nil];
	[self setCoarseSandSwitch:nil];
	[self setMediumSandSwitch:nil];
	[self setFineSandSwitch:nil];
	[self setFineSiltAndClaySwitch:nil];
	[super viewDidUnload];
}
@end
