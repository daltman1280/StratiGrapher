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
 OK Bar Button Item pressed. We want to update the stratum's material number, using the currently selected
 material row in our table. We want our delegate to dismiss the popover that owns us.
 */

- (IBAction)handleOK:(id)sender {
	int lineNumber = [self.tableView indexPathForSelectedRow].row;
	NSString *descriptions = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"patterns descriptive text" ofType:@"txt"] encoding:NSASCIIStringEncoding error:nil];
	NSString *line = [descriptions componentsSeparatedByString:@"\n"][lineNumber];
	self.stratum.materialNumber = [[line substringToIndex:3] intValue];
	[self.delegate performSelector:@selector(dismissPopoverContainer:) withObject:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	self.clearsSelectionOnViewWillAppear = NO;
 
	NSString *descriptions = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"patterns descriptive text" ofType:@"txt"] encoding:NSASCIIStringEncoding error:nil];
	int i = 0;
	for (NSString *line in [descriptions componentsSeparatedByString:@"\n"]) {
		if (self.stratum.materialNumber == [[line substringToIndex:3] intValue])
			break;
		++i;
	}
	[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
	[self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)didReceiveMemoryWarning
{
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
	NSString *descriptions = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"patterns descriptive text" ofType:@"txt"] encoding:NSASCIIStringEncoding error:nil];
	return [descriptions componentsSeparatedByString:@"\n"].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"datasource = %@", tableView.dataSource);
	NSLog(@"self = %@, tableView = %@, indexPath = %@", self, tableView, indexPath);
	MaterialTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"material" forIndexPath:indexPath];
    // Configure the cell...
	NSString *descriptions = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"patterns descriptive text" ofType:@"txt"] encoding:NSASCIIStringEncoding error:nil];
	NSString *line = [descriptions componentsSeparatedByString:@"\n"][indexPath.row];
    [cell.title setText:[line substringToIndex:3]];
	[cell.subtitle setText:[line substringFromIndex:4]];
	cell.pattern.patternNumber = [[line substringToIndex:3] intValue];
	cell.pattern.patternsPage = self.patternsPage;
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

@end
