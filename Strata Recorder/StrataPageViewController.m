//
//  StrataPageViewController.m
//  StratiGrapher
//
//  Created by daltman on 1/4/14.
//  Copyright (c) 2014 Don Altman. All rights reserved.
//

#import "StrataPageViewController.h"

@interface StrataPageViewController ()

@property UIScrollView*			strataPageScrollView;

@end

@implementation StrataPageViewController

- (void)awakeFromNib
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[(StrataPageView *)self.view setupPages];
}

#pragma mark - UIPageViewController delegate methods

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	return UIPageViewControllerSpineLocationMin;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
	if (((StrataPageViewController *)viewController).pageIndex == 0)
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

#if 0
- (id)initWithEnclosingScrollView:(UIScrollView *)enclosingScrollView
{
	self = [super init];
	if (self) {
		self.strataPageView = [[StrataPageView alloc] initWithFrame:self.view.bounds];
		NSLog(@"initWithEnclosingScrollView view = %@", [self.view class]);
		self.strataPageView.backgroundColor = [UIColor whiteColor];
		self.strataMultiPageScrollView = enclosingScrollView;
		self.strataPageScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
		self.strataPageScrollView.delegate = self;
		self.strataPageScrollView.contentSize = self.view.bounds.size;
		self.strataPageScrollView.contentOffset = CGPointZero;
		self.strataPageScrollView.minimumZoomScale = 1;
		self.strataPageScrollView.maximumZoomScale = 2;
		self.strataPageScrollView.multipleTouchEnabled = YES;
		self.strataPageScrollView.backgroundColor = [UIColor blueColor];
		[self.strataPageScrollView addSubview:self.strataPageView];
		[self.strataMultiPageScrollView addSubview:self.strataPageScrollView];
		self.strataMultiPageScrollView.contentSize = self.view.bounds.size;
	}
	return self;
}

- (void)setPageIndex:(int)pageIndex
{
	_pageIndex = pageIndex;
	[self.strataPageView setupPages];
	self.strataPageView.pageIndex = pageIndex;
//	float horizontalInset = fmaxf((self.strataPageScrollView.bounds.size.width-self.strataPageView.bounds.size.width)/2.0, 0);
//	float verticalInset = fmaxf((self.strataPageScrollView.bounds.size.height-self.strataPageView.bounds.size.height)/2.0, 0);
	float horizontalInset = fmaxf((self.strataPageScrollView.bounds.size.width-self.strataPageView.bounds.size.width*self.strataPageScrollView.zoomScale)/2.0, 0);
	float verticalInset = fmaxf((self.strataPageScrollView.bounds.size.height-self.strataPageView.bounds.size.height*self.strataPageScrollView.zoomScale)/2.0, 0);
	self.strataPageScrollView.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
}

- (int)pageIndex
{
	return self.pageIndex;
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)sender
{
	NSLog(@"StrataPageViewController, viewForZoomingInScrollView");
	return self.strataPageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
//	float horizontalInset = fmaxf((self.strataPageScrollView.bounds.size.width-self.strataPageView.bounds.size.width)/2.0, 0);
//	float verticalInset = fmaxf((self.strataPageScrollView.bounds.size.height-self.strataPageView.bounds.size.height)/2.0, 0);
	float horizontalInset = fmaxf((self.strataPageScrollView.bounds.size.width-self.strataPageView.bounds.size.width*self.strataPageScrollView.zoomScale)/2.0, 0);
	float verticalInset = fmaxf((self.strataPageScrollView.bounds.size.height-self.strataPageView.bounds.size.height*self.strataPageScrollView.zoomScale)/2.0, 0);
	NSLog(@"StrataPageViewController, scrollViewDidEndZooming, height = %f", self.strataPageView.bounds.size.height);
	self.strataPageScrollView.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	NSLog(@"StrataPageViewController, scrollViewDidScroll");
}
#endif

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
