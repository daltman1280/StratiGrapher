//
//  StratumInfoNotesViewController.m
//  Strata Recorder
//
//  Created by daltman on 12/15/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

#import "StratumInfoNotesViewController.h"

@interface StratumInfoNotesViewController ()

@end

@implementation StratumInfoNotesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*
 Ad hoc method to be called (by StratumInfoNavigationController) before we are popped out.
 
 We need to notify our parent (StratumInfoTableViewController).
 */

- (void)willPopViewController
{
	self.stratum.notes = self.notesTextView.text;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSLog(@"self.notes = %@", self.notesTextView);
	self.notesTextView.text = self.notes;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
	[self setNotesTextView:nil];
	[super viewDidUnload];
}
@end
