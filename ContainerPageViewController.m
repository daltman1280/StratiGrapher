//
//  ContainerPageViewController.m
//  StratiGrapher
//
//  Created by daltman on 1/16/14.
//  Copyright (c) 2014 Don Altman. All rights reserved.
//

/*
 Subclass of UIPageViewController, customized to have properties, so that it can correctly instantiate view controllers for StrataPageView's
 */

#import "ContainerPageViewController.h"

@interface ContainerPageViewController ()

@end

@implementation ContainerPageViewController

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
