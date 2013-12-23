//
//  StratumGranularityViewController.m
//  Strata Recorder
//
//  Created by daltman on 12/16/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import "StratumGranularityViewController.h"
#import "StrataModel.h"

@interface StratumGranularityViewController ()

@end

@implementation StratumGranularityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	[self.granularityPicker selectRow:self.grainSizeIndex-1 inComponent:0 animated:NO];
	self.contentSizeForViewInPopover = CGSizeMake(400, 216);		// TODO: get the appropriate size
}

/*
 Ad hoc method to be called (by StratumInfoNavigationController) before we are popped out.
 
 We need to notify our parent (StratumInfoTableViewController).
 */

- (void)willPopViewController
{
	self.grainSizeIndex = [self.granularityPicker selectedRowInComponent:0]+1;
	[self.parent handleGranularityChanged:self.grainSizeIndex];
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return gGrainSizeNamesCount;
}

#pragma mark UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return (NSString *)gGrainSizeNames[row];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setGranularityPicker:nil];
    [super viewDidUnload];
}

@end
