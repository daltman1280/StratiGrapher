//
//  StratumMaterialsTableController.m
//  Strata Recorder
//
//  Created by Don Altman on 11/15/12.
//  Copyright (c) 2012 Don Altman. All rights reserved.
//

#import "StratumMaterialsTableController.h"
#import "MaterialTableViewCell.h"

@interface StratumMaterialsTableController ()

@property NSMutableArray *unusedMaterialIndexes;
@property NSMutableArray *unusedMaterialTitles;
@property NSMutableArray *unusedMaterialSubtitles;
@end

@implementation StratumMaterialsTableController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*
 Add bar button item pressed. Add material number to our parent's and active document's palette.
 */

- (IBAction)handleAdd:(id)sender {
	int lineNumber = [self.tableView indexPathForSelectedRow].row;
	[self.materialIndexes addObject:self.unusedMaterialIndexes[lineNumber]];
	[self.activeDocument.materialNumbersPalette addObject:self.unusedMaterialIndexes[lineNumber]];
	[self populateUnusedMaterials];
	[self.tableView reloadData];
	[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (void)populateUnusedMaterials
{
	if (!self.unusedMaterialIndexes) self.unusedMaterialIndexes = [[NSMutableArray alloc] init];
	[self.unusedMaterialIndexes removeAllObjects];
	if (!self.unusedMaterialTitles) self.unusedMaterialTitles = [[NSMutableArray alloc] init];
	[self.unusedMaterialTitles removeAllObjects];
	if (!self.unusedMaterialSubtitles) self.unusedMaterialSubtitles = [[NSMutableArray alloc] init];
	[self.unusedMaterialSubtitles removeAllObjects];
	
	NSString *descriptions = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"patterns descriptive text" ofType:@"txt"] encoding:NSASCIIStringEncoding error:nil];
	for (NSString *line in [descriptions componentsSeparatedByString:@"\n"]) {
		NSNumber *materialNumber = [NSNumber numberWithInt:[[line substringToIndex:3] intValue]];
		if (![self.materialIndexes containsObject:materialNumber]) {
			[self.unusedMaterialIndexes addObject:materialNumber];
			[self.unusedMaterialTitles addObject:[line substringToIndex:3]];
			[self.unusedMaterialSubtitles addObject:[line substringFromIndex:4]];
		}
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.clearsSelectionOnViewWillAppear = NO;
	[self populateUnusedMaterials];
	[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];		// always select first row
	[self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)didReceiveMemoryWarning
{
	NSLog(@"StratumMaterialsTableController didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.unusedMaterialIndexes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	MaterialTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"material"];
    // Configure the cell...
	[cell.title setText:self.unusedMaterialTitles[indexPath.row]];
	[cell.subtitle setText:self.unusedMaterialSubtitles[indexPath.row]];
	cell.pattern.patternNumber = [self.unusedMaterialIndexes[indexPath.row] intValue];
	[cell.pattern setNeedsDisplay];
    return cell;
}

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
	[super viewDidUnload];
}
@end
