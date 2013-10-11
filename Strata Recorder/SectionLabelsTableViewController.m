//
//  SectionLabelsTableViewController.m
//  Strata Recorder
//
//  Created by daltman on 5/28/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import "SectionLabelsTableViewController.h"
#import "SectionLabelCell.h"
#import "AddSectionLabelViewController.h"
#import "SectionLabelDetailTableViewController.h"

@interface SectionLabelsTableViewController ()

@end

@implementation SectionLabelsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)handleSectionLabelsEdit:(id)sender {
	UIBarButtonItem *button = (UIBarButtonItem *) sender;
	if ([button.title isEqualToString:@"Edit"]) {
		[self.tableView setEditing:YES animated:YES];
		button.title = @"Done";
	} else {
		[self.tableView setEditing:NO animated:YES];
		button.title = @"Edit";
	}
}

- (IBAction)handleAddSectionLabel:(id)sender {
	SectionLabel *sectionLabel = [[SectionLabel alloc] init];
	sectionLabel.numberOfStrataSpanned = 1;
	sectionLabel.labelText = ((AddSectionLabelViewController *) sender).sectionLabelText.text;
	if (!self.activeDocument.sectionLabels) self.activeDocument.sectionLabels = [[NSMutableArray alloc] init];
	[self.activeDocument.sectionLabels addObject:sectionLabel];
	[self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	id controller = segue.destinationViewController;
	if ([controller isMemberOfClass:[AddSectionLabelViewController class]]) {
		AddSectionLabelViewController *controller = (AddSectionLabelViewController *) segue.destinationViewController;
		controller.delegate = self;
		
	} else if ([controller isMemberOfClass:[SectionLabelDetailTableViewController class]]) {
		SectionLabelDetailTableViewController *controller = (SectionLabelDetailTableViewController *) segue.destinationViewController;
		controller.sectionLabel = self.activeDocument.sectionLabels[self.tableView.indexPathForSelectedRow.row];
		controller.delegate = self;
	}
}

// delegate function called from SectionLabelDetailTableViewController handleUpdateButton

- (IBAction)handleUpdateButton:(id)sender {
	[self.tableView reloadData];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
	self.title = [NSString stringWithFormat:@"%@ Labels", self.activeDocument.name];
	self.contentSizeForViewInPopover = CGSizeMake(460, 533);		// TODO: get the appropriate size
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return self.activeDocument.sectionLabels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sectionLabel"];
	if (cell == nil)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sectionLabel"];
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.textLabel.text = ((SectionLabel *)self.activeDocument.sectionLabels[indexPath.row]).labelText;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.showsReorderControl = YES;
	return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self.activeDocument.sectionLabels removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	SectionLabel *label = self.activeDocument.sectionLabels[fromIndexPath.row];
	[self.activeDocument.sectionLabels removeObjectAtIndex:fromIndexPath.row];
	[self.activeDocument.sectionLabels insertObject:label atIndex:toIndexPath.row];
}

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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	
}

@end
