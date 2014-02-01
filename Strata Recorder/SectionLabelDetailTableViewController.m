//
//  SectionLabelDetailTableViewController.m
//  Strata Recorder
//
//  Created by daltman on 5/29/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import "SectionLabelDetailTableViewController.h"

@interface SectionLabelDetailTableViewController ()

@end

@implementation SectionLabelDetailTableViewController

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
	self.sectionLabelText.text = self.sectionLabel.labelText;
	self.numberStrataSpanned.text = [NSString stringWithFormat:@"%d", self.sectionLabel.numberOfStrataSpanned];
	self.stratumSpannedStepper.value = self.sectionLabel.numberOfStrataSpanned;
}

/*
 Ad hoc method to be called (by SettingsNavigationController) before we are popped out.
 
 We need to notify our parent (SettingsTableViewController).
 */

- (void)willPopViewController
{
	self.sectionLabel.labelText = self.sectionLabelText.text;
	self.sectionLabel.numberOfStrataSpanned = self.stratumSpannedStepper.value;
	[self.delegate handleUpdateButton:self];
}

- (IBAction)handleStrataSpannedStepper:(id)sender {
	self.numberStrataSpanned.text = [NSString stringWithFormat:@"%d", (int) self.stratumSpannedStepper.value];
}

- (void)didReceiveMemoryWarning
{
	NSLog(@"SectionLabelDetailTableViewController didReceiveMemoryWarning");
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
    [self setSectionLabelText:nil];
    [self setNumberStrataSpanned:nil];
	[self setStratumSpannedStepper:nil];
    [super viewDidUnload];
}
@end
