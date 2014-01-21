//
//  BlueViewController.m
//  StratiGrapher
//
//  Created by daltman on 1/7/14.
//  Copyright (c) 2014 Don Altman. All rights reserved.
//

#import "BlueViewController.h"

@interface BlueViewController ()

@end

@implementation BlueView

- (void)drawRect:(CGRect)rect
{
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(currentContext, 3);
	CGContextStrokeRect(currentContext, self.bounds);
}

@end

@implementation BlueViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#if 0
- (void)loadView
{
//	self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 400, 500)];
	self.view.backgroundColor = [UIColor redColor];
}
#endif

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.pageNumberLabel.text = [NSString stringWithFormat:@"Page %d", self.pageNumber];
	// Do any additional setup after loading the view.
	CGRect pageViewRect = self.view.bounds;
//	pageViewRect = CGRectInset(pageViewRect, 120.0, 120.0);
	self.view.frame = pageViewRect;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPageViewController delegate methods

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	return UIPageViewControllerSpineLocationMin;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
	if (((BlueViewController *)viewController).pageNumber == 1)
		return nil;
	BlueViewController *controller = [viewController.storyboard instantiateViewControllerWithIdentifier:@"blueViewController"];
	controller.pageNumber = ((BlueViewController *)viewController).pageNumber-1;
	return controller;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
	BlueViewController *controller = [viewController.storyboard instantiateViewControllerWithIdentifier:@"blueViewController"];
	controller.pageNumber = ((BlueViewController *)viewController).pageNumber+1;
	return controller;
}

- (void)viewDidUnload {
	[self setPageNumberLabel:nil];
	[super viewDidUnload];
}
@end
