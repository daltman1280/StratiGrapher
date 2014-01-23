//
//  ContainerPageViewController.m
//  StratiGrapher
//
//  Created by daltman on 1/16/14.
//  Copyright (c) 2014 Don Altman. All rights reserved.
//

/*
 Subclass of UIPageViewController, customized to have properties, so that it can correctly instantiate view controllers for StrataPageView's
 
 It also functions as UIPageViewControllerDelegate and UIPageViewControllerDataSource.
 */

#import "ContainerPageViewController.h"
#import "StrataPageViewController.h"

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

#pragma mark - UIPageViewController delegate methods

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	return UIPageViewControllerSpineLocationMin;
}

//	We maintain our own page control, so as not to require iOS 6

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
	if (completed) self.pageControl.currentPage = ((StrataPageViewController *)self.viewControllers.lastObject).pageIndex;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
	StrataPageViewController *vc = (StrataPageViewController *)viewController;
	if (vc.pageIndex == 0)
		return nil;
	StrataPageViewController *controller = [viewController.storyboard instantiateViewControllerWithIdentifier:@"strataPageViewController"];
	controller.parent = self;
	controller.pageIndex = vc.pageIndex-1;
	return controller;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
	StrataPageViewController *vc = (StrataPageViewController *)viewController;
	if (vc.pageIndex >= vc.strataPageView.maxPageIndex)
		return nil;
	StrataPageViewController *controller = [viewController.storyboard instantiateViewControllerWithIdentifier:@"strataPageViewController"];
	controller.parent = self;
	controller.pageIndex = vc.pageIndex+1;
	return controller;
}

#if 0	// iOS 6
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
	return self.maxPages;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
	
}
#endif

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.delegate = self;
	self.dataSource = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
