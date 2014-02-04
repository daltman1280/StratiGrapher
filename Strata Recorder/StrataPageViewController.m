//
//  StrataPageViewController.m
//  StratiGrapher
//
//  Created by daltman on 1/4/14.
//  Copyright (c) 2014 Don Altman. All rights reserved.
//

/*
 View Controller for StrataPageView, a member of VC list for ContainerPageViewController.
 */

#import "StrataPageViewController.h"

static float gCacheScrollViewHeightPageIndexZero;

@interface StrataPageViewController ()

@end

@implementation StrataPageViewController

- (void)awakeFromNib
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	if (self.parent) {
		[self initializePageView];
		[self adjustMinimumZoom];
		[self maintainScrollView];
	}
}

- (void)setParent:(ContainerPageViewController *)parent
{
	_parent = parent;
	if (self.strataPageView) {
		[self initializePageView];
		[self adjustMinimumZoom];
		[self maintainScrollView];
	}
}

- (void)setPageIndex:(int)pageIndex
{
	_pageIndex = pageIndex;
	self.strataPageView.pageIndex = pageIndex;
	if (self.strataPageView)
		[self maintainScrollView];
}

- (void)adjustMinimumZoom
{
	float widthRatio = self.strataPageView.bounds.size.width/self.strataPageScrollView.bounds.size.width;
	float heightRatio = self.strataPageView.bounds.size.height/self.strataPageScrollView.bounds.size.height;
	if (widthRatio > 1 || heightRatio > 1) {
		float maxRatio = fmaxf(widthRatio, heightRatio);
		self.strataPageScrollView.minimumZoomScale = 1.0/maxRatio;
		self.strataPageScrollView.zoomScale = self.strataPageScrollView.minimumZoomScale;
	}
}

- (void)initializePageView
{
	self.strataPageView.patternsPageArray = self.parent.patternsPageArray;
	self.strataPageView.legendView = self.parent.legendView;
	self.strataPageView.columnNumber = self.parent.columnNumber;
	self.strataPageView.grainSizeLegend = self.parent.grainSizeLegend;
	self.strataPageView.grainSizeLines = self.parent.grainSizeLines;
	self.strataPageView.strataColumn = self.parent.strataColumn;
	self.strataPageView.activeDocument = self.parent.activeDocument;						// updates bounds
	[self.strataPageView setupPages];
	self.maxPages = self.strataPageView.maxPageIndex+1;
	self.strataPageView.pageIndex = _pageIndex;
}

- (void)maintainScrollView
{
	self.strataPageScrollView.contentSize = self.view.bounds.size;
	self.strataPageScrollView.contentOffset = CGPointZero;
	/*
	 Case 1: First instance (page 1):
		viewDidLoad, setParent called in order
	 Case 2: Second (and subsequent) instances:
		setParent, viewDidLoad called in order
	 because of their methods of instantiation. For case 2, the scrollview has not been instantiated, so its vertical dimension is not usable.
	 Use the cached dimension from case 1.
	 */
	if (self.pageIndex == 0)																// cached dimension from page 1
		gCacheScrollViewHeightPageIndexZero = self.strataPageScrollView.bounds.size.height;
	float horizontalInset = fmaxf((self.strataPageScrollView.bounds.size.width-self.strataPageView.bounds.size.width*self.strataPageScrollView.zoomScale)/2.0, 0);
	float verticalInset = fmaxf((gCacheScrollViewHeightPageIndexZero-self.strataPageView.bounds.size.height*self.strataPageScrollView.zoomScale)/2.0, 0);
	self.strataPageScrollView.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
	if (verticalInset > 0 || horizontalInset > 0) self.strataPageScrollView.contentOffset = CGPointMake(-horizontalInset, -verticalInset);
	self.strataPageScrollView.scrollEnabled = (horizontalInset == 0 && verticalInset == 0) ? YES : NO;
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)sender
{
	return self.strataPageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	float horizontalInset = fmaxf((self.strataPageScrollView.bounds.size.width-self.strataPageView.bounds.size.width*self.strataPageScrollView.zoomScale)/2.0, 0);
	float verticalInset = fmaxf((self.strataPageScrollView.bounds.size.height-self.strataPageView.bounds.size.height*self.strataPageScrollView.zoomScale)/2.0, 0);
	self.strataPageScrollView.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
	self.strataPageScrollView.scrollEnabled = (horizontalInset == 0 && verticalInset == 0) ? YES : NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
	[self setStrataPageScrollView:nil];
	[self setStrataPageScrollView:nil];
	[self setStrataPageView:nil];
	[super viewDidUnload];
}
@end
