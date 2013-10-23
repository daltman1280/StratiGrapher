//
//  SettingsNavigationController.m
//  Strata Recorder
//
//  Created by daltman on 10/7/13.
//  Copyright (c) 2013 Don Altman. All rights reserved.
//

/*
 Purpose:
 
 To act as UINavigationControllerDelegate in order to receive notifications when controllers are pushed and popped
 on the navigation stack.
 */

#import "SettingsNavigationController.h"
//#import "GrainSizeTableViewController.h"
#import "SettingsTableController.h"

@interface SettingsNavigationController ()

@end

@implementation SettingsNavigationController

/*
 Any view controllers who wish to be notified need to implement our ad hoc willShowViewController method
 */

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	if ([viewController respondsToSelector:@selector(willShowViewController)])
		[viewController performSelector:@selector(willShowViewController)];
}

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
